import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:intl/intl.dart';

class AdminAttendanceController extends GetxController {
  final _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var isGraphLoading = false.obs;
  
  var allUsers = <Map<String, dynamic>>[].obs;
  var selectedUserId = ''.obs;
  
  var attendanceRecords = <Map<String, dynamic>>[].obs;
  var weeklyGraphData = <int, double>{}.obs; // Day of week -> Working Hours
  
  var totalPresent = 0.obs;
  var totalAbsent = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await _supabase.from('profiles').select('id, full_name, role');
      allUsers.value = List<Map<String, dynamic>>.from(response);
      
      if (allUsers.isNotEmpty) {
        selectedUserId.value = allUsers.first['id'];
        fetchAttendanceForUser(selectedUserId.value);
      }
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to fetch users: $e', isError: true);
      isLoading.value = false;
    }
  }

  void onUserSelected(String userId) {
    selectedUserId.value = userId;
    fetchAttendanceForUser(userId);
  }

  Future<void> fetchAttendanceForUser(String userId) async {
    try {
      isGraphLoading.value = true;
      
      final response = await _supabase
          .from('attendance')
          .select()
          .eq('employee_id', userId)
          .order('check_in_time', ascending: false)
          .limit(30); // Last 30 records
          
      attendanceRecords.value = List<Map<String, dynamic>>.from(response);
      
      _calculateGraphData();
      _calculateStats();
      
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to fetch attendance: $e', isError: true);
    } finally {
      isGraphLoading.value = false;
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    int present = 0;
    int absent = 0; // Assuming we calculate absent based on some logic, or just count 'Check-In' as present.
    
    for (var record in attendanceRecords) {
      if (record['check_in_time'] != null) {
        present++;
      }
    }
    
    totalPresent.value = present;
    // Dummy logic for absent (e.g. 30 days - present days)
    totalAbsent.value = attendanceRecords.isEmpty ? 0 : (30 - present).clamp(0, 30);
  }

  void _calculateGraphData() {
    Map<int, double> graphData = {};
    
    // Group attendance by weekday for the graph (0 = Monday, 6 = Sunday)
    for (var record in attendanceRecords) {
      if (record['check_in_time'] != null && record['check_out_time'] != null) {
        DateTime checkIn = DateTime.parse(record['check_in_time']);
        DateTime checkOut = DateTime.parse(record['check_out_time']);
        
        int weekday = checkIn.weekday - 1; // 0-indexed
        
        double hours = checkOut.difference(checkIn).inMinutes / 60.0;
        if (hours < 0) hours = hours.abs(); // Safety for timezone mistakes
        if (hours > 16) hours = 16.0; // Clamp to max 16 hours to prevent UI overflow
        
        // Take the latest/average or sum. Let's just store the latest working hours for that weekday in the view
        if (!graphData.containsKey(weekday)) {
          graphData[weekday] = hours;
        }
      }
    }
    
    // Fill empty days with 0
    for (int i = 0; i < 7; i++) {
      if (!graphData.containsKey(i)) {
        graphData[i] = 0.0;
      }
    }
    
    weeklyGraphData.value = graphData;
  }
}
