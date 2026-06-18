import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/admin/views/dashboard/admin_dashboard_screen.dart';
import 'package:tryzx_workfoce_mangment/admin/views/users/admin_user_management_screen.dart';
import 'package:tryzx_workfoce_mangment/admin/views/tasks/admin_global_tasks_screen.dart';
import 'package:tryzx_workfoce_mangment/admin/views/attendance/admin_attendance_screen.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';

class AdminShellController extends GetxController {
  var selectedIndex = 0.obs;
  
  var adminName = 'Admin'.obs;
  var adminAvatar = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('id', user.id)
            .maybeSingle();
        if (profile != null) {
          adminName.value = profile['full_name'] ?? 'Admin';
          adminAvatar.value = profile['avatar_url'] ?? '';
        }
      } catch (e) {
        print("Error fetching admin profile: $e");
      }
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    // Removed Get.back() so tapping bottom nav doesn't try to close a non-existent drawer
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Users';
      case 2: return 'Global Tasks';
      case 3: return 'Attendance Reports';
      default: return 'Admin Panel';
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;

    final controller = Get.put(AdminShellController());

    final screens = [
      const AdminDashboardScreen(),
      const AdminUserManagementScreen(),
      const AdminGlobalTasksScreen(),
      const AdminAttendanceScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Responsive.isMobile 
          ? AppBar(
              title: Obx(() => Text(_getAppBarTitle(controller.selectedIndex.value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              backgroundColor: AppColors.background,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      drawer: Responsive.isMobile ? _buildMobileDrawer(controller) : null,
      body: Responsive.isDesktop || Responsive.isTablet
          ? Row(
              children: [
                _buildSideNav(controller),
                Expanded(
                  child: Obx(() => IndexedStack(
                        index: controller.selectedIndex.value,
                        children: screens,
                      )),
                ),
              ],
            )
          : Obx(() => IndexedStack(
                index: controller.selectedIndex.value,
                children: screens,
              )),
      // Bottom Navigation Bar is back for mobile!
      bottomNavigationBar: Responsive.isMobile ? _buildBottomNav(controller) : null,
    );
  }

  Widget _buildBottomNav(AdminShellController controller) {
    return Obx(() => BottomNavigationBar(
          backgroundColor: AppColors.surface,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12.0,
          unselectedFontSize: 10.0,
          iconSize: 24.0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Attendance'),
          ],
        ));
  }

  Widget _buildMobileDrawer(AdminShellController controller) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => CircleAvatar(
                      radius: Responsive.aw(30),
                      backgroundColor: AppColors.primary,
                      backgroundImage: controller.adminAvatar.value.isNotEmpty ? NetworkImage(controller.adminAvatar.value) : null,
                      child: controller.adminAvatar.value.isEmpty ? const Icon(Icons.person, color: Colors.black) : null,
                    )),
                SizedBox(width: Responsive.aw(16)),
                Expanded(
                  child: Obx(() => Text(
                        controller.adminName.value,
                        style: TextStyle(color: Colors.white, fontSize: Responsive.asp(18), fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0, controller),
          _buildDrawerItem(Icons.people_outline, Icons.people, 'Users', 1, controller),
          _buildDrawerItem(Icons.task_alt, Icons.task_alt, 'Global Tasks', 2, controller),
          _buildDrawerItem(Icons.fingerprint, Icons.fingerprint, 'Attendance Reports', 3, controller),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent, size: Responsive.aw(24)),
            title: Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: Responsive.asp(16))),
            onTap: controller.logout,
            contentPadding: EdgeInsets.symmetric(horizontal: Responsive.aw(24), vertical: Responsive.ah(12)),
          ),
          SizedBox(height: Responsive.ah(20)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, IconData activeIcon, String title, int index, AdminShellController controller) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return ListTile(
        leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : Colors.white54, size: Responsive.aw(24)),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: Responsive.asp(16),
          ),
        ),
        selected: isSelected,
        onTap: () {
          controller.changeTab(index);
          if (Responsive.isMobile) Get.back(); // Close drawer only when clicked from drawer
        },
        contentPadding: EdgeInsets.symmetric(horizontal: Responsive.aw(24), vertical: Responsive.ah(4)),
      );
    });
  }

  Widget _buildSideNav(AdminShellController controller) {
    return Obx(() => NavigationRail(
          backgroundColor: AppColors.surface,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeTab,
          selectedIconTheme: const IconThemeData(color: Colors.black),
          unselectedIconTheme: const IconThemeData(color: Colors.white54),
          selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
          useIndicator: true,
          indicatorColor: AppColors.primary,
          minExtendedWidth: 220,
          extended: Responsive.isDesktop,
          leading: Column(
            children: [
              SizedBox(height: Responsive.ah(24)),
              CircleAvatar(
                radius: Responsive.aw(24),
                backgroundColor: AppColors.primary,
                backgroundImage: controller.adminAvatar.value.isNotEmpty ? NetworkImage(controller.adminAvatar.value) : null,
                child: controller.adminAvatar.value.isEmpty ? const Icon(Icons.person, color: Colors.black) : null,
              ),
              if (Responsive.isDesktop) ...[
                SizedBox(height: Responsive.ah(12)),
                Text(
                  controller.adminName.value,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(14)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: Responsive.ah(32)),
            ],
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Users'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.task_alt),
              selectedIcon: Icon(Icons.task_alt),
              label: Text('Global Tasks'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.fingerprint),
              selectedIcon: Icon(Icons.fingerprint),
              label: Text('Attendance'),
            ),
          ],
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: Responsive.ah(20)),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: controller.logout,
                  tooltip: 'Logout',
                ),
              ),
            ),
          ),
        ));
  }
}
