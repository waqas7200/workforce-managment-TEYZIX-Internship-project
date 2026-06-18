import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeProfileController extends GetxController {
  final _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  
  var completedTasks = 0.obs;
  var loggedHours = 0.0.obs;
  var attendanceScore = 0.obs;

  var monthlyAttendanceList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchRealTimeData();
  }

  Future<void> _fetchRealTimeData() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Fetch Completed Tasks for the employee
      // Tasks that are assigned to the employee and have status Completed/Verified
      final tasksRes = await _supabase
          .from('task_assignments')
          .select('task_id, tasks!inner(status)')
          .eq('employee_id', user.id);
      
      int count = 0;
      for (var row in tasksRes as List) {
        final status = row['tasks']['status'];
        if (status == 'Completed' || status == 'Verified') {
          count++;
        }
      }
      completedTasks.value = count;

      // 2. Fetch Attendance for Current Month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1).toUtc().toIso8601String();
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toUtc().toIso8601String();

      final attRes = await _supabase
          .from('attendance')
          .select()
          .eq('employee_id', user.id)
          .gte('check_in_time', startOfMonth)
          .lte('check_in_time', endOfMonth)
          .order('check_in_time', ascending: false);

      final records = List<Map<String, dynamic>>.from(attRes);
      monthlyAttendanceList.value = records;

      // Calculate Hours
      double totalHours = 0;
      int daysPresent = 0;
      
      // Use a set to track unique days present
      final uniqueDays = <String>{};

      for (var record in records) {
        if (record['check_in_time'] != null && record['check_out_time'] != null) {
          final checkIn = DateTime.parse(record['check_in_time']);
          final checkOut = DateTime.parse(record['check_out_time']);
          final diff = checkOut.difference(checkIn);
          totalHours += diff.inMinutes / 60.0;
        }

        if (record['check_in_time'] != null) {
          final checkIn = DateTime.parse(record['check_in_time']).toLocal();
          uniqueDays.add("${checkIn.year}-${checkIn.month}-${checkIn.day}");
        }
      }

      loggedHours.value = double.parse(totalHours.toStringAsFixed(1));
      daysPresent = uniqueDays.length;

      // Calculate Score (Assuming 22 working days in a month)
      int workingDaysInMonth = 22; 
      // Cap at 100%
      int score = ((daysPresent / workingDaysInMonth) * 100).round();
      attendanceScore.value = score > 100 ? 100 : score;

    } catch (e) {
      print("Error fetching profile real time data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
