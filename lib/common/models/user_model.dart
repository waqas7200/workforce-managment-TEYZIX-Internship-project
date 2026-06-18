class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // Admin, Field Supervisor, Field Employee

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Example fromJson method for API integration later
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Field Employee',
    );
  }

  // Example toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
