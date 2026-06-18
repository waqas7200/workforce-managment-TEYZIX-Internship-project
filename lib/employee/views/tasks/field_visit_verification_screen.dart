import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/field_verification_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';

class FieldVisitVerificationScreen extends StatelessWidget {
  const FieldVisitVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Expecting TaskModel to be passed, but let's safely handle taskId
    final dynamic args = Get.arguments;
    final String taskId = args is String 
        ? args 
        : ((args != null && args is Map && args.containsKey('id')) 
            ? args['id'] 
            : (args?.id ?? ''));

    final controller = Get.put(FieldVerificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Visit Verification', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: Responsive.w(20)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Proof',
                style: TextStyle(fontSize: Responsive.sp(24), fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: Responsive.h(8)),
              Text(
                'Please attach site photos and any necessary remarks to complete this task.',
                style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.textSecondary),
              ),
              SizedBox(height: Responsive.h(24)),
              
              // Image Picker Box
              GestureDetector(
                onTap: () => controller.takePhoto(),
                child: Obx(() => CustomCard(
                  height: controller.imagePath.value.isEmpty ? Responsive.h(150) : Responsive.h(250),
                  child: controller.imagePath.value.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: Responsive.w(40)),
                            SizedBox(height: Responsive.h(12)),
                            Text('Tap to Capture Photos', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(14))),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(Responsive.w(24)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(File(controller.imagePath.value), fit: BoxFit.cover),
                            Positioned(
                              top: Responsive.w(10),
                              right: Responsive.w(10),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => controller.imagePath.value = '',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                )),
              ),
              SizedBox(height: Responsive.h(24)),
              
              Text(
                'Visit Notes / Remarks',
                style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: Responsive.h(16)),
              
              // Notes Text Field
              TextFormField(
                controller: controller.notesController,
                maxLines: 4,
                style: TextStyle(color: Colors.white, fontSize: Responsive.sp(14)),
                decoration: InputDecoration(
                  hintText: 'Enter your findings here...',
                  hintStyle: TextStyle(fontSize: Responsive.sp(14), color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.w(16)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              SizedBox(height: Responsive.h(32)),
              
              // Info Text about GPS
              Row(
                children: [
                  Icon(Icons.gps_fixed, color: AppColors.primary, size: Responsive.w(20)),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text(
                      'Your GPS coordinates will be captured automatically upon submission for verification.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: Responsive.h(40)),
              
              Obx(() => CustomButton(
                text: 'Submit & Complete',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.submitVerification(taskId),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
