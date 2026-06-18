import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/manager_task_detail_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:intl/intl.dart';

class ManagerTaskDetailScreen extends StatelessWidget {
  const ManagerTaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagerTaskDetailController());
    final task = controller.task;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Task Verification', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: Responsive.w(20)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(fontSize: Responsive.sp(24), fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: Responsive.h(16)),
              _buildInfoRow(Icons.info_outline, 'Status', task.status, _getStatusColor(task.status)),
              SizedBox(height: Responsive.h(8)),
              _buildInfoRow(Icons.access_time, 'Deadline', DateFormat('dd MMM yyyy, hh:mm a').format(task.deadline), Colors.white70),
              
              SizedBox(height: Responsive.h(24)),
              Text('Description', style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: Responsive.h(8)),
              Text(
                task.description ?? 'No description provided.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14), height: 1.5),
              ),
              
              if (task.status == 'Completed' || task.status == 'Verified') ...[
                SizedBox(height: Responsive.h(32)),
                Text('Completion Proof', style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: Responsive.h(16)),
                // In a real app, you'd load the image URL from task model or related table
                Container(
                  width: double.infinity,
                  height: Responsive.h(200),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Responsive.w(16)),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: Colors.white24, size: Responsive.w(64)),
                        SizedBox(height: Responsive.h(8)),
                        Text('Proof Image Available in DB', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: Responsive.h(40)),
              
              if (task.status == 'Completed') ...[
                Obx(() => controller.isLoading.value 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.verifyTask(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(12))),
                            ),
                            child: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: Responsive.w(16)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.verifyTask(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(12))),
                            ),
                            child: const Text('Verify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: Responsive.w(20)),
        SizedBox(width: Responsive.w(8)),
        Text('$label: ', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14))),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontSize: Responsive.sp(14), fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Completed': return Colors.teal;
      case 'Verified': return Colors.green;
      default: return Colors.white;
    }
  }
}
