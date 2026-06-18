import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tryzx_workfoce_mangment/manager/controllers/create_task_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_button.dart';
import 'package:tryzx_workfoce_mangment/core/widgets/custom_text_field.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateTaskController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assign New Task', style: TextStyle(color: Colors.white)),
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
              Text('Task Information', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.h(16)),
              
              CustomTextField(
                controller: controller.titleController,
                hintText: 'e.g. Inspect site at Block 4',
                prefixIcon: Icon(Icons.title, color: AppColors.textSecondary, size: Responsive.w(20)),
              ),
              SizedBox(height: Responsive.h(16)),
              
              CustomTextField(
                controller: controller.descriptionController,
                hintText: 'Detailed description (Optional)',
                prefixIcon: Icon(Icons.description, color: AppColors.textSecondary, size: Responsive.w(20)),
                maxLines: 4,
              ),
              SizedBox(height: Responsive.h(32)),

              Text('Assign To', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.h(16)),
              
              GestureDetector(
                onTap: () {
                  if (Get.isBottomSheetOpen ?? false) return;
                  _showMultiSelectBottomSheet(context, controller);
                },
                child: Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(16)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Responsive.w(12)),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          controller.selectedEmployeeIds.isEmpty 
                              ? 'Select Field Employees' 
                              : '${controller.selectedEmployeeIds.length} Employee(s) Selected',
                          style: TextStyle(
                            color: controller.selectedEmployeeIds.isEmpty ? AppColors.textSecondary : Colors.white, 
                            fontSize: Responsive.sp(14)
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white, size: Responsive.w(24)),
                    ],
                  ),
                )),
              ),
              SizedBox(height: Responsive.h(32)),

              Text('Deadline', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.h(16)),
              
              GestureDetector(
                onTap: () => controller.selectDate(context),
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(16)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Responsive.w(12)),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary, size: Responsive.w(20)),
                      SizedBox(width: Responsive.w(16)),
                      Obx(() => Text(
                        controller.selectedDeadline.value == null
                            ? 'Select Date & Time'
                            : DateFormat('dd MMM yyyy, hh:mm a').format(controller.selectedDeadline.value!),
                        style: TextStyle(
                          color: controller.selectedDeadline.value == null ? AppColors.textSecondary : Colors.white,
                          fontSize: Responsive.sp(14),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: Responsive.h(48)),
              
              Obx(() => CustomButton(
                text: 'Create & Assign Task',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.createTask(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultiSelectBottomSheet(BuildContext context, CreateTaskController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Responsive.w(16)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.w(24))),
        ),
        child: Column(
          children: [
            Text('Select Employees', style: TextStyle(color: Colors.white, fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.h(16)),
            Expanded(
              child: ListView.builder(
                itemCount: controller.employees.length,
                itemBuilder: (context, index) {
                  final emp = controller.employees[index];
                  return Obx(() {
                    final isSelected = controller.selectedEmployeeIds.contains(emp['id']);
                    return CheckboxListTile(
                      title: Text(emp['full_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                      value: isSelected,
                      activeColor: AppColors.primary,
                      checkColor: Colors.black,
                      onChanged: (val) {
                        controller.toggleEmployeeSelection(emp['id']);
                      },
                    );
                  });
                },
              ),
            ),
            SizedBox(height: Responsive.h(16)),
            CustomButton(text: 'Done', onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }
}
