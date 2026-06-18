import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_text_field.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

import '../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: Responsive.aw(20)),
          onPressed: () => Get.back(),
        ),
      ),
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
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: Responsive.asp(32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.ah(8)),
                    Text(
                      'Enter your email address to receive a password reset link.',
                      style: TextStyle(
                        fontSize: Responsive.asp(16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.ah(40)),
                    CustomTextField(
                      controller: controller.forgotEmailController,
                      hintText: 'Enter your registered email',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Responsive.ah(32)),
                    Obx(() => CustomButton(
                      text: 'Send Link',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.resetPassword,
                    )),
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
