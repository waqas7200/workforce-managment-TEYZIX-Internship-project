import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/admin/controllers/admin_user_management_controller.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild UI when screen size changes
    MediaQuery.of(context).size;

    final controller = Get.put(AdminUserManagementController());

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(Responsive.aw(24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'User Management',
                      style: TextStyle(fontSize: Responsive.asp(20), fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.aw(10)),
                SizedBox(
                  width: Responsive.isMobile ? Responsive.aw(130) : Responsive.aw(180),
                  child: CustomButton(
                    text: '+ Add User',
                    onPressed: () {
                      _showAddUserDialog(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.ah(24)),
            
            // Search Bar
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search employees or managers...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.aw(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: Responsive.ah(24)),

            // Users List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = controller.filteredUsers;
                if (users.isEmpty) {
                  return const Center(child: Text("No users found.", style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final name = user['full_name'] ?? 'Unknown';
                    final role = user['role'] ?? 'Unknown Role';
                    final isActive = user['is_active'] ?? true;
                    final avatarUrl = user['avatar_url'] as String?;

                    return Padding(
                    padding: EdgeInsets.only(bottom: Responsive.ah(16)),
                    child: CustomCard(
                      padding: EdgeInsets.all(Responsive.aw(16)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: Responsive.aw(24),
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl == null || avatarUrl.isEmpty 
                                ? Icon(Icons.person, color: AppColors.primary, size: Responsive.aw(24))
                                : null,
                          ),
                          SizedBox(width: Responsive.aw(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(16))),
                                SizedBox(height: Responsive.ah(4)),
                                Text(role, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(14))),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.aw(12), vertical: Responsive.ah(6)),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(Responsive.aw(20)),
                            ),
                            child: Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: Responsive.asp(12), fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: Responsive.aw(16)),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white54),
                            tooltip: 'Change Role',
                            onPressed: () {
                              controller.showRoleSelectionDialog(user['id'], role);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            )
          ]
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Information', style: TextStyle(color: Colors.white)),
          content: Text(
            'New users should sign up directly from the app. Once they sign up, you can change their role to Manager or Admin from this list using the Edit button.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Okay', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      }
    );
  }
}
