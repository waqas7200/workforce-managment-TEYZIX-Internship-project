import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_card.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/notification_controller.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/task_controller.dart';
import 'package:tryzx_workfoce_mangment/core/routes.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDate(String? isoString) {
    if (isoString == null) return 'Unknown time';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Put controller so it's initialized if not already
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: Responsive.w(20)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: AppColors.primary, size: Responsive.w(24)),
            onPressed: () {
              controller.markAllAsRead();
            },
            tooltip: 'Mark all as read',
          )
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, color: AppColors.textSecondary, size: Responsive.w(64)),
                  SizedBox(height: Responsive.h(16)),
                  Text(
                    'No new notifications',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(16)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(Responsive.w(24.0)),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              final isRead = notification['is_read'] ?? false;

              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(16)),
                child: GestureDetector(
                  onTap: () {
                    if (!isRead) {
                      controller.markAsRead(notification['id']);
                    }
                    if (notification['task_id'] != null) {
                      try {
                        final taskCtrl = Get.find<TaskController>();
                        final task = taskCtrl.taskList.firstWhereOrNull((t) => t.id == notification['task_id']);
                        if (task != null) {
                          Get.toNamed(AppRoutes.taskDetail, arguments: task);
                        } else {
                          Get.snackbar('Error', 'Task not found or already completed.', backgroundColor: Colors.redAccent, colorText: Colors.white);
                        }
                      } catch (e) {
                        // TaskController might not be initialized
                      }
                    }
                  },
                  child: CustomCard(
                    padding: EdgeInsets.all(Responsive.w(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(Responsive.w(12)),
                          decoration: BoxDecoration(
                            color: isRead 
                                ? Colors.grey.withOpacity(0.2) 
                                : AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: isRead ? Colors.grey : AppColors.primary,
                            size: Responsive.w(24),
                          ),
                        ),
                        SizedBox(width: Responsive.w(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification['title'] ?? 'Notification',
                                      style: TextStyle(
                                        color: isRead ? Colors.white70 : Colors.white,
                                        fontSize: Responsive.sp(16),
                                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: Responsive.w(8),
                                      height: Responsive.w(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                ],
                              ),
                              SizedBox(height: Responsive.h(8)),
                              Text(
                                notification['body'] ?? '',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: Responsive.sp(14),
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: Responsive.h(8)),
                              Text(
                                _formatDate(notification['created_at']),
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                  fontSize: Responsive.sp(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
