import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/employee/models/task_model.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/manager_home_controller.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:tryzx_workfoce_mangment/core/utils/sync_controller.dart';

class ManagerTaskDetailController extends GetxController {
  final _supabase = Supabase.instance.client;
  var isLoading = false.obs;

  late TaskModel task;

  @override
  void onInit() {
    super.onInit();
    task = Get.arguments as TaskModel;
  }

  Future<void> verifyTask(bool isApproved) async {
    try {
      isLoading.value = true;
      final newStatus = isApproved ? 'Verified' : 'Pending'; // Or 'Rejected' if that status exists
      
      // Update in Supabase
      if (Get.find<SyncController>().isOnline.value) {
        await _supabase.from('tasks').update({'status': newStatus}).eq('id', task.id);
      } else {
        await Get.find<SyncController>().queueAction('update_task_status', {
          'task_id': task.id,
          'status': newStatus,
        });
      }

      Helpers.showSnackbar('Success', isApproved ? 'Task verified successfully!' : 'Task returned to Pending.');
      
      // Refresh manager dashboard tasks
      if (Get.isRegistered<ManagerHomeController>()) {
        Get.find<ManagerHomeController>().onInit();
      }

      Get.back();
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to update task: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
