class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String status; // Pending, In Progress, Completed
  final int progressPercentage;
  final String supervisorName;
  final List<Map<String, dynamic>> assignedEmployees;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.progressPercentage,
    required this.updatedAt,
    this.supervisorName = 'Supervisor',
    this.assignedEmployees = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Extract supervisor info
    String supName = 'Supervisor';
    if (json['supervisor'] != null) {
      supName = json['supervisor']['full_name'] ?? 'Supervisor';
    }

    // Extract assigned employees from junction table
    List<Map<String, dynamic>> employees = [];
    if (json['task_assignments'] != null && json['task_assignments'] is List) {
      for (var assignment in json['task_assignments']) {
        final profile = assignment['profiles'];
        if (profile != null) {
          employees.add({
            'name': profile['full_name'] ?? 'Employee',
            'avatar': profile['avatar_url'] ?? '',
          });
        }
      }
    }

    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline']).toLocal() 
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      progressPercentage: json['progress_percentage'] ?? json['progressPercentage'] ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']).toLocal() 
          : DateTime.now(),
      supervisorName: supName,
      assignedEmployees: employees,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'progressPercentage': progressPercentage,
      'updatedAt': updatedAt.toIso8601String(),
      'supervisorName': supervisorName,
      'assignedEmployees': assignedEmployees,
    };
  }
}
