import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/manager_map_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

class ManagerMapScreen extends StatelessWidget {
  const ManagerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagerMapController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.w(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Tracking',
                    style: TextStyle(
                      fontSize: Responsive.sp(28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Responsive.h(8)),
                  Text(
                    'Monitor active field staff locations in real-time.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                return ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Responsive.w(30)),
                    topRight: Radius.circular(Responsive.w(30)),
                  ),
                  child: GoogleMap(
                    onMapCreated: controller.onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(31.5204, 74.3587), // Default fallback location (Lahore)
                      zoom: 10,
                    ),
                    markers: controller.markers.toSet(),
                    myLocationEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
