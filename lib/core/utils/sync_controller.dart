import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SyncController extends GetxController {
  final _supabase = Supabase.instance.client;
  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results);
      }
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isOnline.value = false;
      print("Device is Offline");
    } else {
      isOnline.value = true;
      print("Device is Online");
      _syncPendingData();
    }
  }

  Future<void> _syncPendingData() async {
    if (!isOnline.value) return;

    try {
      var box = await Hive.openBox('offline_actions');
      
      List<dynamic> keysToDelete = [];

      for (var key in box.keys) {
        var action = box.get(key);
        if (action != null) {
          bool success = await _executeActionOnSupabase(action);
          if (success) {
            keysToDelete.add(key);
          }
        }
      }

      // Cleanup synced items
      for (var key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      print("Sync error: $e");
    }
  }

  Future<bool> _executeActionOnSupabase(Map<dynamic, dynamic> action) async {
    try {
      final type = action['type'];
      final payload = action['payload'];

      if (type == 'attendance_checkin') {
        await _supabase.from('attendance').insert(Map<String, dynamic>.from(payload));
        return true;
      } else if (type == 'attendance_checkout') {
        final attendanceId = payload['id'];
        final updatePayload = Map<String, dynamic>.from(payload);
        updatePayload.remove('id');
        await _supabase.from('attendance').update(updatePayload).eq('id', attendanceId);
        return true;
      } else if (type == 'update_task_status') {
        final taskId = payload['task_id'];
        final status = payload['status'];
        await _supabase.from('tasks').update({'status': status}).eq('id', taskId);
        return true;
      }
      
      return false;
    } catch (e) {
      print("Error executing action on Supabase: $e");
      return false;
    }
  }

  // Use this function across the app to perform network requests
  Future<void> queueAction(String type, Map<String, dynamic> payload) async {
    if (isOnline.value) {
      // Execute immediately if online
      await _executeActionOnSupabase({'type': type, 'payload': payload});
    } else {
      // Queue in Hive if offline
      var box = await Hive.openBox('offline_actions');
      await box.add({
        'type': type,
        'payload': payload,
        'timestamp': DateTime.now().toIso8601String()
      });
      Get.snackbar('Offline Mode', 'Action saved locally. Will sync when online.');
    }
  }
}
