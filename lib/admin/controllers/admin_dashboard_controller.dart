import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/employee/models/task_model.dart';

class AdminDashboardController extends GetxController {
  final _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  
  var totalEmployees = 0.obs;
  var activeManagers = 0.obs;
  var tasksCompleted = 0.obs;
  var activeTasks = 0.obs;
  
  var recentActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      
      // 1. Fetch Users
      final usersRes = await _supabase.from('profiles').select('id, role');
      int empCount = 0;
      int mgrCount = 0;
      for (var u in usersRes) {
        if (u['role'] == 'Field Employee') empCount++;
        if (u['role'] == 'Field Supervisor') mgrCount++;
      }
      totalEmployees.value = empCount;
      activeManagers.value = mgrCount;

      // 2. Fetch Tasks
      final tasksRes = await _supabase.from('tasks').select('id, status, updated_at');
      int completedCount = 0;
      int activeCount = 0;
      for (var t in tasksRes) {
        if (t['status'] == 'Completed' || t['status'] == 'Verified') {
          completedCount++;
        } else {
          activeCount++;
        }
      }
      tasksCompleted.value = completedCount;
      activeTasks.value = activeCount;

      // 3. Fetch Recent Activity (e.g. latest 5 tasks updated)
      final recentTasksRes = await _supabase
          .from('tasks')
          .select('id, title, status, updated_at, profiles(full_name)')
          .order('updated_at', ascending: false)
          .limit(5);

      recentActivities.value = List<Map<String, dynamic>>.from(recentTasksRes);
      
    } catch (e) {
      print("Error fetching admin stats: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
