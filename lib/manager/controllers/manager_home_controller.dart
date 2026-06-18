import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';

class ManagerHomeController extends GetxController {
  final _supabase = Supabase.instance.client;

  var userName = ''.obs;
  var userAvatar = ''.obs;
  var selectedIndex = 0.obs;

  // Stats
  var activeStaffCount = 0.obs;
  var totalTasksCount = 0.obs;
  var completedTasksCount = 0.obs;
  var completionRate = 0.obs;

  // Recent Tasks
  var recentTasks = <Map<String, dynamic>>[].obs;
  var allTasks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _fetchStats();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    _supabase.channel('public:profiles').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'profiles',
      callback: (payload) {
        _fetchStats(); // Auto-update when new employee signs up
      },
    ).subscribe();

    _supabase.channel('public:tasks').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tasks',
      callback: (payload) {
        _fetchStats(); // Auto-update when task status changes
      },
    ).subscribe();
  }

  Future<void> _loadUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final profile = await _supabase.from('profiles').select('full_name, avatar_url').eq('id', user.id).maybeSingle();
        if (profile != null) {
          userName.value = profile['full_name'] ?? 'Manager';
          userAvatar.value = profile['avatar_url'] ?? '';
        }
      } catch(e) {
        // fallback
        final prefs = await SharedPreferences.getInstance();
        userName.value = prefs.getString('user_name') ?? 'Manager';
        userAvatar.value = prefs.getString('user_avatar') ?? '';
      }
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    // Handle navigation later
  }

  Future<void> _fetchStats() async {
    try {
      // 1. Fetch Total Staff (All Field Employees)
      final activeStaffRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'Field Employee');
          
      activeStaffCount.value = (activeStaffRes as List).length;

      // 2. Fetch Tasks Stats
      final tasksRes = await _supabase
          .from('tasks')
          .select('id, status, title, deadline, progress_percentage, supervisor:profiles!tasks_assigned_by_fkey(full_name), task_assignments(profiles(full_name, avatar_url))')
          .order('created_at', ascending: false);

      final tasksList = tasksRes as List;
      totalTasksCount.value = tasksList.length;
      
      final completed = tasksList.where((t) => t['status'] == 'Completed' || t['status'] == 'Verified').toList();
      completedTasksCount.value = completed.length;
      
      if (totalTasksCount.value > 0) {
        completionRate.value = ((completedTasksCount.value / totalTasksCount.value) * 100).round();
      } else {
        completionRate.value = 0;
      }

      // 3. Set Tasks
      final allTasksMapped = tasksList.map((e) => e as Map<String, dynamic>).toList();
      allTasks.value = allTasksMapped;
      recentTasks.value = allTasksMapped.take(3).toList();

    } catch (e) {
      print("Error fetching manager stats: $e");
    }
  }

  Future<void> logout() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').update({'fcm_token': null}).eq('id', user.id);
      }
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print("Logout error: $e");
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
