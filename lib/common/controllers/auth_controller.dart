import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tryzx_workfoce_mangment/core/utils/app_exceptions.dart' hide AuthException;
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';

import '../../core/theme.dart';
import '../../core/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Signup Controllers
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();
  var profileImagePath = ''.obs;

  // Forgot Password Controller
  final forgotEmailController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<String?> _getFcmToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      String? token = await messaging.getToken();
      print("++++++++++++========== YAHAN HAI MERA FCM TOKEN: $token ==========++++++++++++");
      return token;
    } catch (e) {
      print("Error getting FCM Token: $e");
      return null;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Responsive.w(20)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(20))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary, size: Responsive.w(24)),
              title: Text('Take a Photo (Camera)', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(16))),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary, size: Responsive.w(24)),
              title: Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(16))),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to pick image', isError: true);
    }
  }

  void _validateEmail(String email) {
    if (email.isEmpty) throw ValidationException("Email cannot be empty");
    
    // Regex enforces: contains at least one number, contains at least one special character, and ends with @gmail.com
    final emailRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*.,_-])[a-zA-Z0-9!@#$%^&*.,_-]+@gmail\.com$');
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException("Email must be a @gmail.com address and contain at least one number and one special character.");
    }
  }

  void _validatePhone(String phone) {
    if (phone.isEmpty) throw ValidationException("Phone number cannot be empty");
    
    // Pakistani format: 03XXXXXXXXX or +923XXXXXXXXX
    final phoneRegex = RegExp(r'^(?:\+92|0)[3][0-9]{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      throw ValidationException("Invalid phone number format. Use 03XXXXXXXXX or +923XXXXXXXXX");
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) throw ValidationException("Password cannot be empty");
    if (password.length < 6) throw ValidationException("Password must be at least 6 characters long");
  }

  void _validateName(String name) {
    if (name.isEmpty) throw ValidationException("Name cannot be empty");
    if (name.length < 3) throw ValidationException("Name must be at least 3 characters long");
  }

  void login() async {
    try {
      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text;

      _validateEmail(email);
      _validatePassword(password);

      isLoading.value = true;

      // 1. Supabase Auth Login
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception("Login failed. Please check your credentials.");
      }

      // 2. Fetch User Role from 'profiles' table
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .maybeSingle();
      
      final String role = profile != null ? (profile['role'] ?? 'Field Employee') : 'Field Employee';

      // 3. Update FCM Token on Login
      final fcmToken = await _getFcmToken();
      if (fcmToken != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': fcmToken})
            .eq('id', res.user!.id);
      }

      isLoading.value = false;

      // 3. Save login state & role locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userRole', role);

      Helpers.showSnackbar('Success', 'Logged in successfully!');
      
      // Route based on role
      if (role == 'Admin') {
        Get.offAllNamed(AppRoutes.adminShell);
      } else if (role == 'Field Supervisor') {
        Get.offAllNamed(AppRoutes.managerHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Login Failed', e.message, isError: true);
    } on ValidationException catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Validation Failed', e.message, isError: true);
    } catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Error', e.toString(), isError: true);
    }
  }

  void signup() async {
    try {
      final name = signupNameController.text.trim();
      final email = signupEmailController.text.trim();
      final phone = signupPhoneController.text.trim();
      final password = signupPasswordController.text;

      if (profileImagePath.value.isEmpty) {
        throw ValidationException("Please upload a profile image");
      }
      _validateName(name);
      _validateEmail(email);
      _validatePhone(phone);
      _validatePassword(password);

      isLoading.value = true;

      // 0. Pre-check if phone number already exists in 'profiles'
      final existingUser = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('phone_number', phone)
          .maybeSingle();

      if (existingUser != null) {
        throw ValidationException("This phone number is already registered with another account.");
      }

      // 1. Supabase Auth Signup
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception("Signup failed. Please try again.");
      }

      // 2. Upload Profile Image to 'avatars' bucket
      final avatarFile = File(profileImagePath.value);
      final fileExt = avatarFile.path.split('.').last;
      final fileName = '${res.user!.id}.$fileExt'; // Use user ID for unique name
      
      await Supabase.instance.client.storage.from('avatars').upload(
        fileName, 
        avatarFile,
        fileOptions: const FileOptions(upsert: true),
      );
      
      // Get the public URL of the uploaded image
      final avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      // 3. Insert user data into 'profiles' table
      final fcmToken = await _getFcmToken();
      
      await Supabase.instance.client.from('profiles').insert({
        'id': res.user!.id,
        'full_name': name,
        'phone_number': phone,
        'avatar_url': avatarUrl,
        'role': 'Field Employee',
        'is_active': true,
        'fcm_token': fcmToken,
      });

      isLoading.value = false;

      // Save login state locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Helpers.showSnackbar('Success', 'Account created successfully!');
      Get.offAllNamed(AppRoutes.home); // Navigate to home directly

    } on AuthException catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Authentication Error', e.message, isError: true);
    } on ValidationException catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Validation Failed', e.message, isError: true);
    } catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Error', e.toString(), isError: true);
    }
  }

  void resetPassword() async {
    try {
      final email = forgotEmailController.text.trim();
      _validateEmail(email);

      isLoading.value = true;

      // Supabase Reset Password Logic
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      isLoading.value = false;

      Helpers.showSnackbar('Success', 'Password reset link sent to your email.');
      Get.back();
    } on AuthException catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Error', e.message, isError: true);
    } on ValidationException catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Validation Failed', e.message, isError: true);
    } catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Error', e.toString(), isError: true);
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPhoneController.dispose();
    signupPasswordController.dispose();
    forgotEmailController.dispose();
    super.onClose();
  }
}
