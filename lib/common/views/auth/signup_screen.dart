import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/common/controllers/auth_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_text_field.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.aw(24.0)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                padding: EdgeInsets.all(Responsive.aw(32.0)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Responsive.aw(24)),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Responsive.ah(10)),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: Responsive.asp(32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.ah(8)),
                    Text(
                      'Join Teyzix Workforce Management',
                      style: TextStyle(
                        fontSize: Responsive.asp(16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.ah(32)),

                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: controller.showImagePickerOptions,
                        child: Obx(() {
                          return Stack(
                            children: [
                              Container(
                                width: Responsive.aw(100),
                                height: Responsive.aw(100),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: Responsive.aw(2)),
                                  image: controller.profileImagePath.value.isNotEmpty
                                      ? DecorationImage(
                                          image: FileImage(File(controller.profileImagePath.value)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: controller.profileImagePath.value.isEmpty
                                    ? Icon(Icons.person, color: AppColors.textSecondary, size: Responsive.aw(40))
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(Responsive.aw(8)),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.background, width: Responsive.aw(2)),
                                  ),
                                  child: Icon(Icons.camera_alt, color: Colors.black, size: Responsive.aw(16)),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: Responsive.ah(12)),
                    Center(
                      child: Text('Upload Profile Photo', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(14))),
                    ),

                    SizedBox(height: Responsive.ah(32)),

                    CustomTextField(
                      controller: controller.signupNameController,
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: Responsive.ah(16)),
                    CustomTextField(
                      controller: controller.signupEmailController,
                      hintText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Responsive.ah(16)),
                    CustomTextField(
                      controller: controller.signupPhoneController,
                      hintText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: Responsive.ah(16)),
                    Obx(() => CustomTextField(
                          controller: controller.signupPasswordController,
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                          isPassword: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        )),
                    SizedBox(height: Responsive.ah(40)),
                    Obx(() => CustomButton(
                      text: 'Sign Up',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.signup,
                    )),
                    SizedBox(height: Responsive.ah(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(14)),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.asp(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
