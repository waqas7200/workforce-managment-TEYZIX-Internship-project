import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/manager_home_controller.dart';

class CreateTaskController extends GetxController {
  final _supabase = Supabase.instance.client;

  var isLoading = false.obs;
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Selected values
  var selectedEmployeeIds = <String>[].obs;
  var selectedDeadline = Rxn<DateTime>();

  // Dropdown list
  var employees = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('id, full_name, role')
          .eq('role', 'Field Employee');
      
      employees.value = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  void toggleEmployeeSelection(String id) {
    if (selectedEmployeeIds.contains(id)) {
      selectedEmployeeIds.remove(id);
    } else {
      selectedEmployeeIds.add(id);
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4FF00),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
               colorScheme: const ColorScheme.dark(
                primary: Color(0xFFD4FF00),
                onPrimary: Colors.black,
                surface: Color(0xFF1E1E1E),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (timePicked != null) {
        selectedDeadline.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
      }
    }
  }

  Future<void> createTask() async {
    if (titleController.text.trim().isEmpty) {
      Helpers.showSnackbar('Error', 'Task title is required', isError: true);
      return;
    }
    if (selectedEmployeeIds.isEmpty) {
      Helpers.showSnackbar('Error', 'Please assign the task to at least one employee', isError: true);
      return;
    }
    if (selectedDeadline.value == null) {
      Helpers.showSnackbar('Error', 'Please set a deadline', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("Supervisor not logged in");

      // Insert task
      final taskRes = await _supabase.from('tasks').insert({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': 'Pending',
        'deadline': selectedDeadline.value!.toUtc().toIso8601String(),
        'assigned_by': user.id,
        'progress_percentage': 0,
      }).select('id').single();

      final taskId = taskRes['id'];

      // Insert assignments
      final assignments = selectedEmployeeIds.map((empId) => {
        'task_id': taskId,
        'employee_id': empId,
      }).toList();
      await _supabase.from('task_assignments').insert(assignments);

      // Insert notifications safely
      try {
        final notifications = selectedEmployeeIds.map((empId) => {
          'employee_id': empId,
          'task_id': taskId,
          'title': 'New Task Assigned',
          'body': 'You have been assigned a new task: ${titleController.text.trim()}',
        }).toList();
        await _supabase.from('notifications').insert(notifications);
      } catch (e) {
        print("RLS error on notifications: $e");
      }

      Helpers.showSnackbar('Success', 'Task successfully created and assigned!');
      
      // Refresh manager dashboard
      if (Get.isRegistered<ManagerHomeController>()) {
        Get.find<ManagerHomeController>().onInit();
      }

      Get.back(); // Go back to manager dashboard

    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to create task: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
