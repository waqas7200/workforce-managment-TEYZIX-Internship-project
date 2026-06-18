import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/common/controllers/auth_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_text_field.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size; // Listen to resizes
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: Responsive.asp(32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.ah(8)),
                    Text(
                      'Login to continue your daily tasks.',
                      style: TextStyle(
                        fontSize: Responsive.asp(16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.ah(40)),
                    CustomTextField(
                      controller: controller.loginEmailController,
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Responsive.ah(16)),
                    Obx(() => CustomTextField(
                          controller: controller.loginPasswordController,
                          hintText: 'Password',
                          isPassword: !controller.isPasswordVisible.value,
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        )),
                    SizedBox(height: Responsive.ah(16)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        child: Text('Forgot Password?', style: TextStyle(fontSize: Responsive.asp(14))),
                      ),
                    ),
                    SizedBox(height: Responsive.ah(24)),
                    Obx(() => CustomButton(
                      text: 'Login',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.login,
                    )),
                    SizedBox(height: Responsive.ah(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(14))),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.signup),
                          child: Text('Sign Up', style: TextStyle(fontSize: Responsive.asp(14))),
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
