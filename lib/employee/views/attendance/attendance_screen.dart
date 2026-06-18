import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/attendance_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Current Date & Time display
              Text(
                'Today',
                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(16)),
              ),
              SizedBox(height: Responsive.h(8)),
              Text(
                '12 June, 2026', // Ideally format from DateTime.now()
                style: TextStyle(color: Colors.white, fontSize: Responsive.sp(24), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: Responsive.h(40)),
              
              // Big Check-In/Out Button
              Obx(() => GestureDetector(
                    onTap: controller.toggleAttendance,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: Responsive.w(200),
                      height: Responsive.w(200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isCheckedIn.value ? AppColors.surface : AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: (controller.isCheckedIn.value ? Colors.black : AppColors.primary).withOpacity(0.3),
                            blurRadius: Responsive.w(30),
                            spreadRadius: Responsive.w(10),
                          ),
                        ],
                        border: Border.all(
                          color: controller.isCheckedIn.value ? AppColors.error : Colors.transparent,
                          width: Responsive.w(4),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.isCheckedIn.value ? Icons.fingerprint : Icons.touch_app,
                              size: Responsive.w(60),
                              color: controller.isCheckedIn.value ? AppColors.error : Colors.black,
                            ),
                            SizedBox(height: Responsive.h(12)),
                            Text(
                              controller.isCheckedIn.value ? 'CHECK OUT' : 'CHECK IN',
                              style: TextStyle(
                                fontSize: Responsive.sp(20),
                                fontWeight: FontWeight.bold,
                                color: controller.isCheckedIn.value ? AppColors.error : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              
              SizedBox(height: Responsive.h(40)),
              
              // Status Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.sp(16))),
                    SizedBox(height: Responsive.h(16)),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary, size: Responsive.w(20)),
                        SizedBox(width: Responsive.w(12)),
                        Expanded(
                          child: Obx(() => Text(
                                controller.currentLocation.value,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(16)),
                    Row(
                      children: [
                        Icon(Icons.phone_android, color: AppColors.primary, size: Responsive.w(20)),
                        SizedBox(width: Responsive.w(12)),
                        Obx(() => Text(
                              controller.deviceId.value,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: Responsive.h(24)),
              
              // Timestamps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeCard('Check In', controller.checkInTime),
                  _buildTimeCard('Check Out', controller.checkOutTime),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, Rxn<DateTime> timeObx) {
    return Expanded(
      child: CustomCard(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14))),
            SizedBox(height: Responsive.h(8)),
            Obx(() {
                  final time = timeObx.value;
                  return Text(
                    time != null 
                      ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}" 
                      : "--:--",
                    style: TextStyle(color: Colors.white, fontSize: Responsive.sp(20), fontWeight: FontWeight.bold),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
