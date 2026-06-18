import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerMapController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  var markers = <Marker>{}.obs;
  var isLoading = true.obs;

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    _fetchEmployeeLocations();
  }

  Future<void> _fetchEmployeeLocations() async {
    try {
      isLoading.value = true;
      // Get today's attendance records to find current locations
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

      final res = await _supabase
          .from('attendance')
          .select('check_in_lat, check_in_lng, employee_id, profiles(full_name, avatar_url)')
          .gte('check_in_time', startOfDay)
          .isFilter('check_out_time', null); // Only currently checked-in employees

      final newMarkers = <Marker>{};

      for (var record in res as List) {
        if (record['check_in_lat'] != null && record['check_in_lng'] != null) {
          final lat = record['check_in_lat'] as double;
          final lng = record['check_in_lng'] as double;
          final profile = record['profiles'];
          final name = profile != null ? profile['full_name'] : 'Unknown';

          newMarkers.add(
            Marker(
              markerId: MarkerId(record['employee_id'].toString()),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name, snippet: 'Active on field'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            )
          );
        }
      }

      markers.value = newMarkers;

      if (newMarkers.isNotEmpty && mapController != null) {
        // Move camera to the first active employee
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newMarkers.first.position, 12.0)
        );
      }
    } catch (e) {
      print("Error fetching employee locations: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (markers.isNotEmpty) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(markers.first.position, 12.0)
      );
    }
  }
}
