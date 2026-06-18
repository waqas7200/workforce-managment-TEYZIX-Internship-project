import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/admin/controllers/admin_dashboard_controller.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild UI when screen size changes
    MediaQuery.of(context).size;

    final controller = Get.put(AdminDashboardController());

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.aw(24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Overview',
              style: TextStyle(fontSize: Responsive.asp(28), fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: Responsive.ah(8)),
            Text(
              'Welcome Admin, here is the live status.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(16)),
            ),
            SizedBox(height: Responsive.ah(32)),

            // Stats Grid
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = Responsive.isDesktop ? 4 : (Responsive.isTablet ? 2 : 2);
                  double aspectRatio = Responsive.isDesktop ? 1.6 : (Responsive.isTablet ? 1.3 : 1.1);
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: Responsive.aw(16),
                    mainAxisSpacing: Responsive.ah(16),
                    childAspectRatio: aspectRatio,
                    children: [
                      _buildStatCard('Total Employees', controller.totalEmployees.value.toString(), Icons.people, Colors.blue),
                      _buildStatCard('Active Managers', controller.activeManagers.value.toString(), Icons.admin_panel_settings, Colors.orange),
                      _buildStatCard('Tasks Completed', controller.tasksCompleted.value.toString(), Icons.task_alt, Colors.green),
                      _buildStatCard('Active Tasks', controller.activeTasks.value.toString(), Icons.pending_actions, Colors.purple),
                    ],
                  );
                }
              );
            }),

            SizedBox(height: Responsive.ah(40)),
            
            // Recent Activity Section
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: Responsive.asp(20), fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: Responsive.ah(16)),
            CustomCard(
              padding: EdgeInsets.all(Responsive.aw(16)),
              child: Obx(() {
                if (controller.recentActivities.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(Responsive.aw(16)),
                    child: Text('No recent activity', style: TextStyle(color: Colors.white54, fontSize: Responsive.asp(14))),
                  );
                }
                return Column(
                  children: controller.recentActivities.map((activity) {
                    final userName = activity['profiles']?['full_name'] ?? 'Unknown User';
                    final title = activity['title'] ?? 'Task';
                    final status = activity['status'] ?? 'Updated';
                    final timeStr = activity['updated_at'];
                    final time = timeStr != null ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(timeStr).toLocal()) : '';

                    return Column(
                      children: [
                        _buildActivityRow(userName, '$status: $title', time),
                        Divider(color: Colors.white24, height: Responsive.ah(24)),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      padding: EdgeInsets.all(Responsive.aw(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.aw(8)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(Responsive.aw(8)),
                ),
                child: Icon(icon, color: color, size: Responsive.aw(24)),
              ),
              Icon(Icons.more_horiz, color: AppColors.textSecondary, size: Responsive.aw(20)),
            ],
          ),
          SizedBox(height: Responsive.ah(16)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(color: Colors.white, fontSize: Responsive.asp(28), fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: Responsive.ah(4)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(14))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String user, String action, String time) {
    return Row(
      children: [
        CircleAvatar(
          radius: Responsive.aw(20),
          backgroundColor: AppColors.surface,
          child: Icon(Icons.person, color: Colors.white, size: Responsive.aw(20)),
        ),
        SizedBox(width: Responsive.aw(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(16))),
              SizedBox(height: Responsive.ah(4)),
              Text(action, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(14))),
            ],
          ),
        ),
        Text(time, style: TextStyle(color: AppColors.primary, fontSize: Responsive.asp(12))),
      ],
    );
  }
}
