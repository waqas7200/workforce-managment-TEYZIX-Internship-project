import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/manager_home_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/task_card_widget.dart';
import 'package:tryzx_workfoce_mangment/employee/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:tryzx_workfoce_mangment/manager/views/reports/analytics_screen.dart';
import 'package:tryzx_workfoce_mangment/manager/views/employees/manager_map_screen.dart';

class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagerHomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white, size: Responsive.w(24)),
            onPressed: () {},
          ),
          SizedBox(width: Responsive.w(16)),
        ],
      ),
      drawer: _buildDrawer(controller),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.toNamed(AppRoutes.createTask);
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
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
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.selectedIndex.value == 0) return _buildDashboard(controller);
          if (controller.selectedIndex.value == 1) return _buildAllTasks(controller);
          if (controller.selectedIndex.value == 2) return const ManagerMapScreen();
          if (controller.selectedIndex.value == 3) return const AnalyticsScreen();
          return Center(child: Text('Coming Soon...', style: TextStyle(color: AppColors.textSecondary)));
        }),
      ),
    );
  }

  Widget _buildDashboard(ManagerHomeController controller) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.h(16)),
            
            // Greeting
                Obx(() => RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: Responsive.sp(32),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: 'Supervisor '),
                      TextSpan(text: controller.userName.value, style: const TextStyle(color: AppColors.primary)),
                    ],
                  ),
                )),
                SizedBox(height: Responsive.h(8)),
                Text(
                  'Here is your team\'s performance today.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
                ),
                SizedBox(height: Responsive.h(32)),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildStatCard(
                        'Total Staff',
                        controller.activeStaffCount.value.toString(),
                        Icons.group_outlined,
                        Colors.blueAccent,
                      )),
                    ),
                    SizedBox(width: Responsive.w(16)),
                    Expanded(
                      child: Obx(() => _buildStatCard(
                        'Completion',
                        '${controller.completionRate.value}%',
                        Icons.insights,
                        Colors.green,
                      )),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildStatCard(
                        'Total Tasks',
                        controller.totalTasksCount.value.toString(),
                        Icons.assignment_outlined,
                        AppColors.primary,
                      )),
                    ),
                    SizedBox(width: Responsive.w(16)),
                    Expanded(
                      child: Obx(() => _buildStatCard(
                        'Completed',
                        controller.completedTasksCount.value.toString(),
                        Icons.check_circle_outline,
                        Colors.teal,
                      )),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(32)),
                
                // Recent Tasks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Tasks',
                      style: TextStyle(fontSize: Responsive.sp(20), fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Text(
                        'View All',
                        style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(16)),
                Obx(() {
                  if (controller.recentTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.w(32)),
                        child: Text("No tasks created yet.", style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    );
                  }
                  return Column(
                    children: controller.recentTasks.map((taskMap) {
                      final task = TaskModel.fromJson(taskMap);
                      return Padding(
                        padding: EdgeInsets.only(bottom: Responsive.h(16)),
                        child: TaskCardWidget(
                          task: task,
                          onTap: () {
                            Get.toNamed(AppRoutes.managerTaskDetail, arguments: task);
                          },
                        ),
                      );
                    }).toList(),
                  );
                }),
                
                SizedBox(height: Responsive.h(100)), // Bottom nav spacing
              ],
            ),
          ),
        
    );
  }

  Widget _buildAllTasks(ManagerHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Responsive.w(24), right: Responsive.w(24), top: Responsive.w(24), bottom: Responsive.w(16)),
          child: Text('All Tasks', style: TextStyle(fontSize: Responsive.sp(24), fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Expanded(
          child: Obx(() {
            if (controller.allTasks.isEmpty) {
              return Center(child: Text("No tasks found.", style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(24.0)),
              itemCount: controller.allTasks.length,
              itemBuilder: (context, index) {
                final task = TaskModel.fromJson(controller.allTasks[index]);
                return Padding(
                  padding: EdgeInsets.only(bottom: Responsive.h(16)),
                  child: TaskCardWidget(
                    task: task,
                    onTap: () {
                      Get.toNamed(AppRoutes.managerTaskDetail, arguments: task);
                    },
                  ),
                );
              },
            );
          }),
        ),
        SizedBox(height: Responsive.h(100)),
      ],
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

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(20)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Responsive.w(20)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.w(8)),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: Responsive.w(20)),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(16)),
          Text(
            value,
            style: TextStyle(fontSize: Responsive.sp(28), fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ManagerHomeController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Responsive.w(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.dashboard, 0, controller),
          _buildNavItem(Icons.assignment_ind, 1, controller), // Tasks
          _buildNavItem(Icons.group, 2, controller), // Employees
          _buildNavItem(Icons.bar_chart, 3, controller), // Reports
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, ManagerHomeController controller) {
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

  Widget _buildDrawer(ManagerHomeController controller) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.background,
            ),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                  radius: Responsive.w(30),
                  backgroundColor: AppColors.surface,
                  backgroundImage: controller.userAvatar.value.isNotEmpty
                      ? NetworkImage(controller.userAvatar.value)
                      : null,
                  child: controller.userAvatar.value.isEmpty 
                      ? Icon(Icons.person, color: Colors.white, size: Responsive.w(30))
                      : null,
                )),
                SizedBox(width: Responsive.w(16)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        controller.userName.value,
                        style: TextStyle(color: Colors.white, fontSize: Responsive.sp(18), fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      SizedBox(height: Responsive.h(4)),
                      Text(
                        'Field Supervisor',
                        style: TextStyle(color: AppColors.primary, fontSize: Responsive.sp(14)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white, size: Responsive.w(24)),
            title: Text('Settings', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(16))),
            onTap: () {
              // Get.back(); Get.toNamed(...)
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.white, size: Responsive.w(24)),
            title: Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(16))),
            onTap: () {},
          ),
          const Spacer(),
          Divider(color: Colors.white.withOpacity(0.1)),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent, size: Responsive.w(24)),
            title: Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: Responsive.sp(16))),
            onTap: () {
              Get.back(); // Close drawer
              controller.logout();
            },
          ),
          SizedBox(height: Responsive.h(24)),
        ],
      ),
    );
  }
}
