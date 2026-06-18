import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/home_controller.dart';

class EmployeeDrawer extends StatelessWidget {
  const EmployeeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Responsive.h(24)),
            // Header: Avatar, Name, Role
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              controller.userName.value,
                              style: TextStyle(
                                  fontSize: Responsive.sp(18),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        SizedBox(height: Responsive.h(4)),
                        Text(
                          'Field Employee',
                          style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(32)),
            Divider(color: Colors.white24, thickness: 1, indent: Responsive.w(24), endIndent: Responsive.w(24)),
            SizedBox(height: Responsive.h(16)),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                children: [
                  _buildDrawerItem(Icons.settings_outlined, 'Settings', () {}),
                  _buildDrawerItem(Icons.help_outline, 'Help & Support', () {}),
                  _buildDrawerItem(Icons.description_outlined, 'Terms & Conditions', () {}),
                  _buildDrawerItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                ],
              ),
            ),
            
            // Logout Button
            Padding(
              padding: EdgeInsets.all(Responsive.w(24)),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.logout(),
                  icon: Icon(Icons.logout, color: Colors.white, size: Responsive.w(20)),
                  label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(12))),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: Responsive.w(24)),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: Responsive.sp(16))),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(12))),
      hoverColor: AppColors.surface,
    );
  }
}
