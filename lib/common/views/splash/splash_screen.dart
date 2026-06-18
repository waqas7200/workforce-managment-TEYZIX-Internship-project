import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/common/controllers/splash_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    
    // Using standard iPhone X design dimensions as base for responsive scaling
    final size = MediaQuery.of(context).size;
    final widthScale = size.width / 375.0;
    final heightScale = size.height / 812.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline_rounded,
              size: 100 * widthScale,
              color: AppColors.primary,
            ),
            SizedBox(height: 24 * heightScale),
            Text(
              'Teyzix Core',
              style: TextStyle(
                fontSize: 32 * widthScale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5 * widthScale,
              ),
            ),
            SizedBox(height: 8 * heightScale),
            Text(
              'Workforce Management',
              style: TextStyle(
                fontSize: 16 * widthScale,
                color: AppColors.textSecondary,
                letterSpacing: 1.0 * widthScale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
