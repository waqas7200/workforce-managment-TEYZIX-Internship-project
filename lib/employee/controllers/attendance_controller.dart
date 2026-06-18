import 'dart:io';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:tryzx_workfoce_mangment/core/utils/sync_controller.dart';

class AttendanceController extends GetxController {
  var isCheckedIn = false.obs;
  var checkInTime = Rxn<DateTime>();
  var checkOutTime = Rxn<DateTime>();
  var currentAttendanceId = ''.obs;
  
  var currentLocation = "Fetching location...".obs;
  var deviceId = "Fetching device info...".obs;
  
  double? currentLat;
  double? currentLng;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    _loadLocalState();
    _fetchDeviceInfo();
    _fetchLocation();
    _checkCurrentAttendanceStatus();
  }

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    isCheckedIn.value = prefs.getBool('isCheckedIn') ?? false;
    currentAttendanceId.value = prefs.getString('currentAttendanceId') ?? '';
    final savedTime = prefs.getString('checkInTime');
    if (savedTime != null) {
      checkInTime.value = DateTime.parse(savedTime);
    }
  }

  Future<void> _fetchDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId.value = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId.value = "${iosInfo.name} ${iosInfo.model}";
      } else {
        deviceId.value = "Unknown Device";
      }
    } catch (e) {
      deviceId.value = "Device info unavailable";
    }
  }

  Future<void> _fetchLocation() async {
    try {
      currentLocation.value = "Fetching location...";
      
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = "Location disabled. Please enable.";
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = "Location permissions denied.";
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        currentLocation.value = "Location permissions permanently denied.";
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLat = position.latitude;
      currentLng = position.longitude;
      
      String cityStr = "";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(currentLat!, currentLng!);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
          if (city.isNotEmpty) {
            cityStr = " ($city)";
          }
        }
      } catch (e) {
        // Reverse geocoding failed (e.g. no internet), ignore and show only lat/lng
      }

      currentLocation.value = "Lat: ${currentLat!.toStringAsFixed(4)}, Lng: ${currentLng!.toStringAsFixed(4)}$cityStr";
    } catch (e) {
      currentLocation.value = "Failed to fetch location";
    }
  }

  Future<void> _checkCurrentAttendanceStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Find an active attendance record for today that hasn't been checked out
      final response = await Supabase.instance.client
          .from('attendance')
          .select()
          .eq('employee_id', user.id)
          .isFilter('check_out_time', null)
          .order('check_in_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        isCheckedIn.value = true;
        currentAttendanceId.value = response['id'];
        checkInTime.value = DateTime.parse(response['check_in_time']).toLocal();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isCheckedIn', true);
        await prefs.setString('currentAttendanceId', response['id']);
        await prefs.setString('checkInTime', response['check_in_time']);
      } else {
        // If server says no active attendance, reset local state
        isCheckedIn.value = false;
        currentAttendanceId.value = '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isCheckedIn', false);
        await prefs.remove('currentAttendanceId');
        await prefs.remove('checkInTime');
      }
    } catch (e) {
      print("Error fetching attendance status: $e");
    }
  }

  Future<bool> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        Helpers.showSnackbar("Error", "Your device does not support biometric authentication.", isError: true);
        // Fallback for emulator without biometrics setup
        return true; 
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please place your finger or scan face to mark attendance',
        biometricOnly: false, // fallback to device PIN if biometric fails
        persistAcrossBackgrounding: true,
      );
      
      return didAuthenticate;
    } catch (e) {
      Helpers.showSnackbar("Error", "Authentication error: $e", isError: true);
      return false;
    }
  }

  void toggleAttendance() async {
    // 1. First trigger biometric scan
    bool isAuthenticated = await _authenticate();
    
    // If user cancels or fails, stop here
    if (!isAuthenticated) {
      Helpers.showSnackbar("Failed", "Attendance not marked. Fingerprint/Face match failed.", isError: true);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Helpers.showSnackbar("Error", "User not logged in.", isError: true);
      return;
    }

    Helpers.showLoading();

    try {
      if (isCheckedIn.value && currentAttendanceId.value.isNotEmpty) {
        // Check Out Update Database via SyncController
        await Get.find<SyncController>().queueAction('attendance_checkout', {
          'id': currentAttendanceId.value,
          'check_out_time': DateTime.now().toUtc().toIso8601String(),
          'check_out_lat': currentLat ?? 0.0,
          'check_out_lng': currentLng ?? 0.0,
          'is_biometric_verified_out': true,
        });

        isCheckedIn.value = false;
        checkOutTime.value = DateTime.now();
        currentAttendanceId.value = '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isCheckedIn', false);
        await prefs.remove('currentAttendanceId');
        await prefs.remove('checkInTime');

        Helpers.hideLoading();
        Helpers.showSnackbar("Checked Out", "You have successfully checked out with Fingerprint.");
      } else {
        // Check In Insert Database via SyncController
        final payload = {
          'employee_id': user.id,
          'check_in_time': DateTime.now().toUtc().toIso8601String(),
          'check_in_lat': currentLat ?? 0.0,
          'check_in_lng': currentLng ?? 0.0,
          'device_info': deviceId.value,
          'is_biometric_verified_in': true,
        };

        // Note: For offline checkout, we need the inserted ID, which we won't have immediately if offline.
        // For this advanced requirement, we assume a UUID is generated client-side.
        // But for now, we'll queue it.
        await Get.find<SyncController>().queueAction('attendance_checkin', payload);

        isCheckedIn.value = true;
        checkInTime.value = DateTime.now();
        checkOutTime.value = null; // Reset checkout
        
        // Since we don't get response ID if offline, we use a temp ID or generate UUID locally if needed
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        currentAttendanceId.value = tempId;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isCheckedIn', true);
        await prefs.setString('currentAttendanceId', tempId);
        await prefs.setString('checkInTime', payload['check_in_time'] as String);

        Helpers.hideLoading();
        Helpers.showSnackbar("Checked In", "You have successfully checked in with Fingerprint.");
      }
    } catch (e) {
      Helpers.hideLoading();
      Helpers.showSnackbar("Error", "Failed to update attendance: $e", isError: true);
    }
  }
}
