import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';

class AdminGlobalTasksController extends GetxController {
  final _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  
  var pendingTasks = <Map<String, dynamic>>[].obs;
  var completedTasks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      
      final response = await _supabase
          .from('tasks')
          .select('*, profiles(full_name, avatar_url)')
          .order('created_at', ascending: false);
          
      final List<Map<String, dynamic>> allTasks = List<Map<String, dynamic>>.from(response);
      
      pendingTasks.clear();
      completedTasks.clear();
      
      for (var task in allTasks) {
        if (task['status'] == 'Completed' || task['status'] == 'Verified') {
          completedTasks.add(task);
        } else {
          pendingTasks.add(task);
        }
      }
      
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to fetch global tasks: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
