import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/task_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/task_card_widget.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Task History', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (taskController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Filter completed and verified tasks
          final completedTasks = taskController.taskList.where((task) => 
            task.status == 'Completed' || task.status == 'Verified'
          ).toList();

          // Sort by newly completed first
          completedTasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (completedTasks.isEmpty) {
            return Center(
              child: Text(
                'No completed tasks found.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(16)),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(Responsive.w(24)),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(16)),
                child: TaskCardWidget(task: task),
              );
            },
          );
        }),
      ),
    );
  }
}
