import 'package:get/get.dart';

class Responsive {
  // Using standard iPhone X design dimensions as base
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  /// Responsive width based on design width
  static double w(double value) {
    return (value / _designWidth) * Get.width;
  }

  /// Responsive height based on design height
  static double h(double value) {
    return (value / _designHeight) * Get.height;
  }

  /// Responsive font size (scales based on width)
  static double sp(double value) {
    return (value / _designWidth) * Get.width;
  }

  // Breakpoints
  static bool get isMobile => Get.width < 600;
  static bool get isTablet => Get.width >= 600 && Get.width < 1024;
  static bool get isDesktop => Get.width >= 1024;

  // Safe sizes for Admin panel (scales on mobile, fixed on desktop/tablet)
  static double aw(double value) => isMobile ? w(value) : value; 
  static double ah(double value) => isMobile ? h(value) : value;
  static double asp(double value) => isMobile ? sp(value) : value;
}
