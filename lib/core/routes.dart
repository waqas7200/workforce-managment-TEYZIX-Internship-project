import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/common/views/auth/forgot_password_screen.dart';
import 'package:tryzx_workfoce_mangment/common/views/auth/login_screen.dart';
import 'package:tryzx_workfoce_mangment/common/views/auth/signup_screen.dart';
import 'package:tryzx_workfoce_mangment/common/views/onboarding/onboarding_screen.dart';
import 'package:tryzx_workfoce_mangment/common/views/splash/splash_screen.dart';
// Employee Module
import 'package:tryzx_workfoce_mangment/employee/views/home/home_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/attendance/attendance_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/tasks/task_detail_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/tasks/field_visit_verification_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/notifications/notifications_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/profile/employee_profile_screen.dart';
import 'package:tryzx_workfoce_mangment/employee/views/tasks/completed_tasks_screen.dart';

// Manager Module
import 'package:tryzx_workfoce_mangment/manager/views/home/manager_home_screen.dart';
import 'package:tryzx_workfoce_mangment/manager/views/tasks/create_task_screen.dart';
import 'package:tryzx_workfoce_mangment/manager/views/tasks/manager_task_detail_screen.dart';

// Admin Module
import 'package:tryzx_workfoce_mangment/admin/views/admin_shell.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  
  // Employee Routes
  static const home = '/home';
  static const attendance = '/attendance';
  static const taskDetail = '/task-detail';
  static const fieldVisitVerification = '/field-visit-verification';
  static const notifications = '/notifications';
  static const employeeProfile = '/employee-profile';
  static const completedTasks = '/completed-tasks';

  // Manager Routes
  static const managerHome = '/manager-home';
  static const createTask = '/create-task';
  static const managerTaskDetail = '/manager-task-detail';
  
  // Admin Routes
  static const adminShell = '/admin-shell';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    
    // Employee Pages
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: attendance, page: () => const AttendanceScreen()),
    GetPage(name: taskDetail, page: () => const TaskDetailScreen()),
    GetPage(name: fieldVisitVerification, page: () => const FieldVisitVerificationScreen()),
    GetPage(name: notifications, page: () => const NotificationsScreen()),
    GetPage(name: employeeProfile, page: () => const EmployeeProfileScreen()),
    GetPage(name: completedTasks, page: () => const CompletedTasksScreen()),

    // Manager Pages
    GetPage(name: managerHome, page: () => const ManagerHomeScreen()),
    GetPage(name: createTask, page: () => const CreateTaskScreen()),
    GetPage(name: managerTaskDetail, page: () => const ManagerTaskDetailScreen()),

    // Admin Pages
    GetPage(name: adminShell, page: () => const AdminShell()),
  ];
}
