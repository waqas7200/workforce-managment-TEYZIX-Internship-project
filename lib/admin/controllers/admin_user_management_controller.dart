import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';

class AdminUserManagementController extends GetxController {
  final _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var usersList = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      usersList.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to fetch users: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.value.isEmpty) return usersList;
    return usersList.where((user) {
      final name = (user['full_name'] ?? '').toString().toLowerCase();
      final phone = (user['phone_number'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.value) || phone.contains(searchQuery.value);
    }).toList();
  }

  Future<void> changeUserRole(String userId, String currentRole) async {
    try {
      String newRole = currentRole == 'Field Employee' ? 'Field Supervisor' : 'Field Employee';
      
      // Allow assigning 'Admin' role via UI if requested, but for now toggle between Emp/Mgr
      // If we want to allow Admin, we should open a dialog to select the exact role.
      
      await _supabase
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);

      // Refresh list locally
      final index = usersList.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        final updatedUser = Map<String, dynamic>.from(usersList[index]);
        updatedUser['role'] = newRole;
        usersList[index] = updatedUser;
        usersList.refresh();
      }
      
      Helpers.showSnackbar('Success', 'Role updated to $newRole');
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to update role: $e', isError: true);
    }
  }

  void showRoleSelectionDialog(String userId, String currentRole) {
    Get.defaultDialog(
      title: 'Change Role',
      titleStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFF1E1E2C),
      content: Column(
        children: ['Field Employee', 'Field Supervisor', 'Admin'].map((role) {
          return ListTile(
            title: Text(role, style: const TextStyle(color: Colors.white)),
            leading: Radio<String>(
              value: role,
              groupValue: currentRole,
              activeColor: const Color(0xFF00FFD1),
              onChanged: (value) async {
                Get.back();
                if (value != null && value != currentRole) {
                  try {
                    await _supabase
                        .from('profiles')
                        .update({'role': value})
                        .eq('id', userId);
                    
                    final index = usersList.indexWhere((u) => u['id'] == userId);
                    if (index != -1) {
                      final updatedUser = Map<String, dynamic>.from(usersList[index]);
                      updatedUser['role'] = value;
                      usersList[index] = updatedUser;
                      usersList.refresh();
                    }
                    Helpers.showSnackbar('Success', 'Role updated to $value');
                  } catch (e) {
                    Helpers.showSnackbar('Error', 'Failed to update role: $e', isError: true);
                  }
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
