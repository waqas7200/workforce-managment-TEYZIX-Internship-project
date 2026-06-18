import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/admin/controllers/admin_attendance_controller.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    final controller = Get.put(AdminAttendanceController());

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.aw(24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Reports',
                  style: TextStyle(fontSize: Responsive.asp(24), fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: Responsive.ah(16)),
                
                // User Dropdown
                Obx(() {
                  if (controller.allUsers.isEmpty) {
                    return const SizedBox();
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.aw(16)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(Responsive.aw(12)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        value: controller.selectedUserId.value.isEmpty ? null : controller.selectedUserId.value,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                        items: controller.allUsers.map((user) {
                          return DropdownMenuItem<String>(
                            value: user['id'],
                            child: Text(user['full_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.onUserSelected(val);
                        },
                      ),
                    ),
                  );
                }),
                
                SizedBox(height: Responsive.ah(24)),
                
                // Graph Card
                Obx(() {
                  if (controller.isGraphLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  return CustomCard(
                    padding: EdgeInsets.all(Responsive.aw(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Working Hours', style: TextStyle(color: Colors.white, fontSize: Responsive.asp(16), fontWeight: FontWeight.bold)),
                        SizedBox(height: Responsive.ah(24)),
                        SizedBox(
                          height: Responsive.ah(200),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 16, // Max 16 hours
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      const style = TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12);
                                      String text;
                                      switch (value.toInt()) {
                                        case 0: text = 'Mon'; break;
                                        case 1: text = 'Tue'; break;
                                        case 2: text = 'Wed'; break;
                                        case 3: text = 'Thu'; break;
                                        case 4: text = 'Fri'; break;
                                        case 5: text = 'Sat'; break;
                                        case 6: text = 'Sun'; break;
                                        default: text = ''; break;
                                      }
                                      return SideTitleWidget(meta: meta, child: Text(text, style: style));
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => Text('${value.toInt()}h', style: const TextStyle(color: Colors.white54, fontSize: 10))),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.white12, strokeWidth: 1),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: controller.weeklyGraphData.entries.map((e) {
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      color: AppColors.primary,
                                      width: Responsive.aw(16),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // List Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.aw(24)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Attendance History', style: TextStyle(color: Colors.white, fontSize: Responsive.asp(18), fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: Responsive.ah(16)),
          
          // History List
          Expanded(
            child: Obx(() {
              if (controller.isGraphLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.attendanceRecords.isEmpty) {
                return const Center(child: Text('No attendance records found.', style: TextStyle(color: Colors.white54)));
              }
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: Responsive.aw(24)),
                itemCount: controller.attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = controller.attendanceRecords[index];
                  final checkInTime = record['check_in_time'];
                  final checkOutTime = record['check_out_time'];
                  
                  final date = checkInTime != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(checkInTime).toLocal()) : 'Unknown Date';
                  final checkIn = checkInTime != null ? DateFormat('hh:mm a').format(DateTime.parse(checkInTime).toLocal()) : '--';
                  final checkOut = checkOutTime != null ? DateFormat('hh:mm a').format(DateTime.parse(checkOutTime).toLocal()) : '--';
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: Responsive.ah(12)),
                    child: CustomCard(
                      padding: EdgeInsets.all(Responsive.aw(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(date, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(14))),
                              SizedBox(height: Responsive.ah(4)),
                              Row(
                                children: [
                                  Icon(Icons.login, color: Colors.green, size: Responsive.aw(14)),
                                  SizedBox(width: Responsive.aw(4)),
                                  Text(checkIn, style: TextStyle(color: Colors.white70, fontSize: Responsive.asp(12))),
                                  SizedBox(width: Responsive.aw(16)),
                                  Icon(Icons.logout, color: Colors.redAccent, size: Responsive.aw(14)),
                                  SizedBox(width: Responsive.aw(4)),
                                  Text(checkOut, style: TextStyle(color: Colors.white70, fontSize: Responsive.asp(12))),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.aw(12), vertical: Responsive.ah(6)),
                            decoration: BoxDecoration(
                              color: checkOutTime != null ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(Responsive.aw(20)),
                            ),
                            child: Text(
                              checkOutTime != null ? 'Completed' : 'Working',
                              style: TextStyle(color: checkOutTime != null ? Colors.green : Colors.orange, fontSize: Responsive.asp(10), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
