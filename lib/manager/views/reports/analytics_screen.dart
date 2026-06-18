import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/manager_home_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagerHomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Analytics',
                style: TextStyle(
                  fontSize: Responsive.sp(28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: Responsive.h(8)),
              Text(
                'Monitor team productivity and task completion rates.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
              ),
              SizedBox(height: Responsive.h(32)),

              // Completion Rate Pie Chart
              Container(
                padding: EdgeInsets.all(Responsive.w(24)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Responsive.w(20)),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Task Completion Rate',
                      style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: Responsive.h(24)),
                    SizedBox(
                      height: Responsive.h(200),
                      child: Obx(() {
                        final completed = controller.completedTasksCount.value.toDouble();
                        final total = controller.totalTasksCount.value.toDouble();
                        final pending = total - completed;
                        
                        if (total == 0) {
                          return Center(child: Text("No tasks data available", style: TextStyle(color: AppColors.textSecondary)));
                        }

                        return PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: [
                              PieChartSectionData(
                                color: Colors.teal,
                                value: completed,
                                title: '${((completed/total)*100).round()}%',
                                radius: 40,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: AppColors.primary,
                                value: pending,
                                title: '${((pending/total)*100).round()}%',
                                radius: 40,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: Responsive.h(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.teal, 'Completed'),
                        SizedBox(width: Responsive.w(24)),
                        _buildLegendItem(AppColors.primary, 'Pending'),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: Responsive.h(24)),
              
              // Bar Chart for Attendance (Mock data for now, ideally fetch from DB)
              Container(
                padding: EdgeInsets.all(Responsive.w(24)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Responsive.w(20)),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance This Week',
                      style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: Responsive.h(24)),
                    SizedBox(
                      height: Responsive.h(200),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: controller.activeStaffCount.value.toDouble() > 0 ? controller.activeStaffCount.value.toDouble() : 10,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0: text = const Text('Mon', style: style); break;
                                    case 1: text = const Text('Tue', style: style); break;
                                    case 2: text = const Text('Wed', style: style); break;
                                    case 3: text = const Text('Thu', style: style); break;
                                    case 4: text = const Text('Fri', style: style); break;
                                    default: text = const Text('', style: style); break;
                                  }
                                  return SideTitleWidget(meta: meta, space: 4, child: text);
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _buildBarGroup(0, controller.activeStaffCount.value * 0.9),
                            _buildBarGroup(1, controller.activeStaffCount.value * 0.8),
                            _buildBarGroup(2, controller.activeStaffCount.value * 1.0),
                            _buildBarGroup(3, controller.activeStaffCount.value * 0.7),
                            _buildBarGroup(4, controller.activeStaffCount.value * 0.95),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.h(100)), // Bottom nav spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: Responsive.w(12),
          height: Responsive.w(12),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(text, style: TextStyle(color: Colors.white70, fontSize: Responsive.sp(14))),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blueAccent,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10, // Assuming max 10 staff for mock, dynamically it's activeStaffCount
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }
}
