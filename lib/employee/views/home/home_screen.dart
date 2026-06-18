import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/home_controller.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/task_controller.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/notification_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/task_card_widget.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/employee/views/home/widgets/employee_drawer.dart';
import 'package:tryzx_workfoce_mangment/employee/views/attendance/attendance_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/tasks/completed_tasks_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/profile/employee_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final taskController = Get.put(TaskController());
    final notificationController = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      drawer: const EmployeeDrawer(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: Responsive.w(24),
            right: Responsive.w(24),
            bottom: Responsive.h(8),
          ),
          child: _buildBottomNav(controller),
        ),
      ),
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: [
          _buildHomeTab(controller, taskController, notificationController),
          const AttendanceScreen(),
          const CompletedTasksScreen(),
          const EmployeeProfileScreen(),
        ],
      )),
    );
  }

  Widget _buildHomeTab(HomeController controller, TaskController taskController, NotificationController notificationController) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: _buildIconButton(Icons.menu),
                    );
                  }
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                      child: Obx(() {
                        final count = notificationController.unreadCount.value;
                        return Stack(
                          children: [
                            _buildIconButton(Icons.notifications_none),
                            if (count > 0)
                              Positioned(
                                right: Responsive.w(8),
                                top: Responsive.w(8),
                                child: Container(
                                  padding: EdgeInsets.all(Responsive.w(4)),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Responsive.sp(10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    Obx(() => CircleAvatar(
                      radius: Responsive.w(20),
                      backgroundColor: AppColors.surface,
                      backgroundImage: controller.userAvatar.value.isNotEmpty
                          ? NetworkImage(controller.userAvatar.value)
                          : null,
                      child: controller.userAvatar.value.isEmpty 
                          ? Icon(Icons.person, color: Colors.white, size: Responsive.w(20))
                          : null,
                    )),
                  ],
                )
              ],
            ),
            SizedBox(height: Responsive.h(32)),
            // Greeting
            Obx(() => RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: Responsive.sp(32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'Hello, '),
                  TextSpan(text: controller.userName.value, style: const TextStyle(color: AppColors.primary)),
                ],
              ),
            )),
            SizedBox(height: Responsive.h(8)),
            Text(
              '${DateFormat('MMM dd').format(DateTime.now())} you have 2 meetings',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
            ),
            SizedBox(height: Responsive.h(24)),
            // Filter Chips
            Row(
              children: [
                _buildChip('HRD Meeting', true),
                SizedBox(width: Responsive.w(12)),
                _buildChip('Developer Team', false),
              ],
            ),
            SizedBox(height: Responsive.h(32)),
            Text(
              'My Task',
              style: TextStyle(fontSize: Responsive.sp(20), fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: Responsive.h(16)),
            // Task List Rendering
            Obx(() {
              final activeTasks = taskController.taskList.where((task) => 
                task.status != 'Completed' && task.status != 'Verified'
              ).toList();
              
              if (activeTasks.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(100)),
                  child: Center(
                    child: Text("No active tasks.", style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }
              
              return Column(
                children: activeTasks.map((task) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.h(16)),
                  child: TaskCardWidget(task: task),
                )).toList(),
              );
            }),
            SizedBox(height: Responsive.h(100)), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(10)),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: Responsive.w(24)),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(10)),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.w(20)),
        border: Border.all(color: isSelected ? Colors.transparent : AppColors.surface),
      ),
      child: Row(
        children: [
          if (isSelected) ...[
            Icon(Icons.search, color: Colors.white, size: Responsive.w(16)),
            SizedBox(width: Responsive.w(8)),
          ],
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: Responsive.sp(14)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(HomeController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Responsive.w(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_filled, 0, controller),
          _buildNavItem(Icons.fingerprint, 1, controller), // Attendance
          _buildNavItem(Icons.task_alt, 2, controller), // Tasks (anchor later if needed)
          _buildNavItem(Icons.analytics_outlined, 3, controller), // Profile / Analytics
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, HomeController controller) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(12)),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.black : Colors.white,
            size: Responsive.w(24),
          ),
        ),
      );
    });
  }
}
