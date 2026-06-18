import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/admin/controllers/admin_global_tasks_controller.dart';
import 'package:intl/intl.dart';

class AdminGlobalTasksScreen extends StatelessWidget {
  const AdminGlobalTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    final controller = Get.put(AdminGlobalTasksController());

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.aw(24.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Tasks Overview',
                    style: TextStyle(fontSize: Responsive.asp(24), fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: Responsive.ah(16)),
                  
                  // Graph & Stats Section
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    
                    int pending = controller.pendingTasks.length;
                    int completed = controller.completedTasks.length;
                    int total = pending + completed;
                    
                    return CustomCard(
                      padding: EdgeInsets.all(Responsive.aw(16)),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: Responsive.ah(150),
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: Responsive.aw(30),
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.purple,
                                      value: pending.toDouble(),
                                      title: pending > 0 ? '$pending' : '',
                                      radius: Responsive.aw(40),
                                      titleStyle: TextStyle(fontSize: Responsive.asp(16), fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: completed.toDouble(),
                                      title: completed > 0 ? '$completed' : '',
                                      radius: Responsive.aw(40),
                                      titleStyle: TextStyle(fontSize: Responsive.asp(16), fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem('Total Tasks', total.toString(), Colors.blue),
                                SizedBox(height: Responsive.ah(12)),
                                _buildLegendItem('Running/Pending', pending.toString(), Colors.purple),
                                SizedBox(height: Responsive.ah(12)),
                                _buildLegendItem('Completed', completed.toString(), Colors.green),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            // TabBar
            TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Running Tasks'),
                Tab(text: 'Completed Tasks'),
              ],
            ),
            
            // TabBarView for Lists
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return TabBarView(
                  children: [
                    _buildTaskList(controller.pendingTasks),
                    _buildTaskList(controller.completedTasks),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: Responsive.aw(12),
          height: Responsive.aw(12),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: Responsive.aw(8)),
        Expanded(
          child: Text(title, style: TextStyle(color: Colors.white70, fontSize: Responsive.asp(14))),
        ),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(16))),
      ],
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks found.', style: TextStyle(color: Colors.white54)));
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.aw(16)),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final userName = task['profiles']?['full_name'] ?? 'Unassigned';
        final title = task['title'] ?? 'No Title';
        final status = task['status'] ?? 'Pending';
        final deadlineStr = task['deadline'];
        final deadline = deadlineStr != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(deadlineStr).toLocal()) : 'No Deadline';
        
        return Padding(
          padding: EdgeInsets.only(bottom: Responsive.ah(12)),
          child: CustomCard(
            padding: EdgeInsets.all(Responsive.aw(16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: Responsive.aw(20),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(Icons.task, color: AppColors.primary, size: Responsive.aw(20)),
                ),
                SizedBox(width: Responsive.aw(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(16))),
                      SizedBox(height: Responsive.ah(4)),
                      Text('Assigned to: $userName', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(12))),
                      SizedBox(height: Responsive.ah(4)),
                      Text('Deadline: $deadline', style: TextStyle(color: Colors.redAccent, fontSize: Responsive.asp(12))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.aw(10), vertical: Responsive.ah(4)),
                  decoration: BoxDecoration(
                    color: status == 'Completed' ? Colors.green.withOpacity(0.2) : Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Responsive.aw(12)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Completed' ? Colors.green : Colors.purpleAccent,
                      fontSize: Responsive.asp(10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
