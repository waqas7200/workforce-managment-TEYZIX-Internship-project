import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';

class LocationDialog {
  static bool isShowing = false;

  static void show() {
    if (isShowing) return;
    isShowing = true;

    Get.dialog(
      PopScope(
        canPop: false, // Prevent dismissing by back button
        child: Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.w(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off,
                  size: Responsive.w(60),
                  color: AppColors.error,
                ),
                SizedBox(height: Responsive.h(16)),
                Text(
                  'Location is Disabled',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                Text(
                  'Please enable your GPS location to continue using the application and marking attendance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(14),
                  ),
                ),
                SizedBox(height: Responsive.h(24)),
                CustomButton(
                  text: 'Enable Location',
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    // We don't close the dialog here. The timer will close it once location is enabled.
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      isShowing = false;
    });
  }

  static void hide() {
    if (isShowing) {
      Get.back();
      isShowing = false;
    }
  }
}
