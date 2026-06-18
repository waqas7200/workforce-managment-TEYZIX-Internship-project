import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/employee_profile_controller.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/home_controller.dart' as tryzx_home;
import 'package:intl/intl.dart';

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<tryzx_home.HomeController>();
    final profileController = Get.put(EmployeeProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Analytics', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Analytics Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Productivity (This Month)',
                  style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: Responsive.h(16)),
              Obx(() {
                if (profileController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard('Tasks\nCompleted', '${profileController.completedTasks.value}', Icons.task_alt),
                        SizedBox(width: Responsive.w(16)),
                        _buildStatCard('Hours\nLogged', '${profileController.loggedHours.value}h', Icons.access_time),
                      ],
                    ),
                    SizedBox(height: Responsive.h(16)),
                    CustomCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Attendance Score', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(14))),
                              SizedBox(height: Responsive.h(8)),
                              Text('${profileController.attendanceScore.value}%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: Responsive.sp(24))),
                            ],
                          ),
                          Icon(Icons.trending_up, color: Colors.green, size: Responsive.w(40)),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: Responsive.h(32)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Monthly Attendance',
                        style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: Responsive.h(16)),
                    
                    if (profileController.monthlyAttendanceList.isEmpty)
                      const Text('No attendance records found for this month.', style: TextStyle(color: Colors.grey))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: profileController.monthlyAttendanceList.length,
                        itemBuilder: (context, index) {
                          final record = profileController.monthlyAttendanceList[index];
                          final checkIn = record['check_in_time'] != null ? DateTime.parse(record['check_in_time']).toLocal() : null;
                          final checkOut = record['check_out_time'] != null ? DateTime.parse(record['check_out_time']).toLocal() : null;
                          
                          return Padding(
                            padding: EdgeInsets.only(bottom: Responsive.h(12)),
                            child: CustomCard(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(12)),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(Responsive.w(8)),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(Responsive.w(8)),
                                    ),
                                    child: Icon(Icons.calendar_today, color: AppColors.primary, size: Responsive.w(20)),
                                  ),
                                  SizedBox(width: Responsive.w(16)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          checkIn != null ? DateFormat('MMM dd, yyyy').format(checkIn) : 'Unknown Date',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.sp(14)),
                                        ),
                                        SizedBox(height: Responsive.h(4)),
                                        Text(
                                          'In: ${checkIn != null ? DateFormat('hh:mm a').format(checkIn) : '--'} | Out: ${checkOut != null ? DateFormat('hh:mm a').format(checkOut) : '--'}',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }),
              
              SizedBox(height: Responsive.h(80)), // Add padding for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: CustomCard(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: Responsive.w(24)),
            SizedBox(height: Responsive.h(12)),
            Text(value, style: TextStyle(color: Colors.white, fontSize: Responsive.sp(24), fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.h(4)),
            Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12))),
          ],
        ),
      ),
    );
  }
}
