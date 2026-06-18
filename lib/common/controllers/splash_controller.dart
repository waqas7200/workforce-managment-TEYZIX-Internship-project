import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));
    
    // Check states
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (isLoggedIn) {
      final user = Supabase.instance.client.auth.currentUser;
      String role = prefs.getString('userRole') ?? 'Field Employee'; // Fallback

      if (user != null) {
        try {
          // Fetch fresh role from database
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle();
          
          if (profile != null) {
            role = profile['role'] ?? 'Field Employee';
            await prefs.setString('userRole', role); // Update local cache
          }
        } catch (e) {
          print("Error fetching role on splash: $e");
        }
      }

      if (role == 'Admin') {
        Get.offAllNamed(AppRoutes.adminShell);
      } else if (role == 'Field Supervisor') {
        Get.offAllNamed(AppRoutes.managerHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } else if (seenOnboarding) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
