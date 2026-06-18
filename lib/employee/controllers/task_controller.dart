import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/employee/models/task_model.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class TaskController extends GetxController {
  final _supabase = Supabase.instance.client;
  var taskList = <TaskModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) {
        isLoading.value = false;
        return;
      }
      
      final res = await _supabase
          .from('tasks')
          .select('id, title, description, deadline, status, progress_percentage, updated_at, supervisor:profiles!tasks_assigned_by_fkey(full_name), task_assignments!inner(profiles(full_name, avatar_url))')
          .eq('task_assignments.employee_id', user.id)
          .order('created_at', ascending: false);
          
      final List<TaskModel> fetchedTasks = (res as List).map((json) => TaskModel.fromJson(json)).toList();
      taskList.assignAll(fetchedTasks);
    } catch (e) {
      print("Error fetching tasks: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateTaskStatus(String id, String newStatus, int progress) async {
    try {
      await _supabase.from('tasks').update({
        'status': newStatus,
        'progress_percentage': progress,
      }).eq('id', id);

      int index = taskList.indexWhere((task) => task.id == id);
      if(index != -1) {
        var task = taskList[index];
        taskList[index] = TaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          deadline: task.deadline,
          status: newStatus,
          progressPercentage: progress,
          updatedAt: DateTime.now(),
          assignedEmployees: task.assignedEmployees,
          supervisorName: task.supervisorName,
        );
      }
    } catch (e) {
      print("Error updating task status: $e");
    }
  }
}
