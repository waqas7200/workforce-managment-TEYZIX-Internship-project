import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';

class OnboardingController extends GetxController {
  void getStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Get.offAllNamed(AppRoutes.login);
  }
}
