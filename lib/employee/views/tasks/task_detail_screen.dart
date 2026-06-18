import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/task_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/employee/models/task_model.dart';

import '../../../core/routes.dart';


class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskModel task = Get.arguments as TaskModel;
    final TaskController controller = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Task Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: Responsive.w(20)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(6)),
                          decoration: BoxDecoration(
                            color: task.status == 'Completed' ? Colors.green.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(Responsive.w(12)),
                          ),
                          child: Text(
                            task.status,
                            style: TextStyle(
                              color: task.status == 'Completed' ? Colors.green : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.sp(12),
                            ),
                          ),
                        ),
                        Text(
                          "Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(16)),
                    Text(
                      task.title.replaceAll('\n', ' '),
                      style: TextStyle(fontSize: Responsive.sp(24), fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: Responsive.h(16)),
                    Text(
                      'Description',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.sp(16)),
                    ),
                    SizedBox(height: Responsive.h(8)),
                    Text(
                      task.description,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14), height: 1.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(24)),
              
              if (task.status != 'Completed') ...[
                Text(
                  'Update Task Status',
                  style: TextStyle(fontSize: Responsive.sp(20), fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: Responsive.h(16)),
                CustomCard(
                  child: Column(
                    children: [
                      if (task.status == 'Pending')
                        CustomButton(
                          text: 'Accept Task',
                          onPressed: () {
                            controller.updateTaskStatus(task.id, 'In Progress', 10);
                            Get.back();
                          },
                        ),
                      if (task.status == 'In Progress') ...[
                        CustomButton(
                          text: 'Upload Proof & Complete',
                          onPressed: () {
                            Get.toNamed(AppRoutes.fieldVisitVerification, arguments: task.id);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: Responsive.w(64)),
                      SizedBox(height: Responsive.h(8)),
                      Text("Task Completed", style: TextStyle(color: Colors.white, fontSize: Responsive.sp(18))),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
