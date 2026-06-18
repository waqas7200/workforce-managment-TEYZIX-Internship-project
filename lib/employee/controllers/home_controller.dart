import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/location_dialog.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;

  Timer? _locationTimer;

  @override
  void onInit() {
    super.onInit();
    _fetchUserProfile();
    _startLocationMonitor();
  }

  void _startLocationMonitor() {
    // Check every 3 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        LocationDialog.show();
      } else {
        LocationDialog.hide();
      }
    });
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    super.onClose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          String fullName = profile['full_name'] ?? 'User';
          userName.value = fullName; 
          userAvatar.value = profile['avatar_url'] ?? '';
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> logout() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // 1. Remove FCM Token from database
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': null})
            .eq('id', user.id);
      }

      // 2. Sign out from Supabase Auth
      await Supabase.instance.client.auth.signOut();

      // 3. Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Helpers.showSnackbar('Success', 'Logged out successfully');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to log out: $e', isError: true);
    }
  }
}
