import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/employee/models/task_model.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(20)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.w(24)),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assigned By Supervisor', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12))),
                    Text(task.supervisorName, style: TextStyle(color: Colors.white, fontSize: Responsive.sp(14), fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(Responsive.w(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Responsive.w(12)),
                  ),
                  child: Icon(Icons.calendar_today, color: Colors.white, size: Responsive.w(16)),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(12)),
            Text(
              DateFormat('MMM dd, yyyy  hh:mm a').format(task.deadline),
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
            ),
            SizedBox(height: Responsive.h(16)),
            Text(
              task.title,
              style: TextStyle(fontSize: Responsive.sp(24), fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            ),
            SizedBox(height: Responsive.h(24)),
            if (task.status != 'Completed' && task.status != 'Verified') ...[
              Text('Assigned Team', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(12))),
              SizedBox(height: Responsive.h(8)),
              Row(
                children: [
                  _buildAvatarStack(),
                  const Spacer(),
                ],
              ),
              SizedBox(height: Responsive.h(24)),
              const Divider(color: Colors.grey, thickness: 0.2),
              SizedBox(height: Responsive.h(16)),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.status, style: TextStyle(color: Colors.white, fontSize: Responsive.sp(14))),
                Text(
                  '${task.progressPercentage}%',
                  style: TextStyle(
                    color: (task.progressPercentage == 100 || task.status == 'Verified') ? Colors.green : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(16),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(8)),
            // Progress bar
            Container(
              height: Responsive.h(6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Responsive.w(3)),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (task.progressPercentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: (task.progressPercentage == 100 || task.status == 'Verified') ? Colors.green : AppColors.primary,
                    borderRadius: BorderRadius.circular(Responsive.w(3)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    final employees = task.assignedEmployees;
    if (employees.isEmpty) return _buildAvatar('');
    
    final displayCount = employees.length > 10 ? 10 : employees.length;
    final extraCount = employees.length - 10;
    
    return SizedBox(
      width: Responsive.w(20 * displayCount + (extraCount > 0 ? 30 : 10)),
      height: Responsive.w(30),
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: Responsive.w(20 * i.toDouble()),
              child: _buildAvatar(employees[i]['avatar'] ?? ''),
            ),
          if (extraCount > 0)
            Positioned(
              left: Responsive.w(20 * 10.0),
              child: Container(
                width: Responsive.w(30),
                height: Responsive.w(30),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: Responsive.w(2)),
                ),
                child: Center(
                  child: Text('+$extraCount', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(10), fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: Responsive.w(2)),
      ),
      child: CircleAvatar(
        radius: Responsive.w(15),
        backgroundColor: AppColors.surface,
        backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
        child: url.isEmpty ? Icon(Icons.person, color: AppColors.textSecondary, size: Responsive.w(15)) : null,
      ),
    );
  }
}
