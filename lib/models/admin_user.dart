// lib/models/admin_user.dart
class AdminUser {
  final String uid;
  final String email;
  final String role;
  final String name;

  AdminUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
  });

  factory AdminUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AdminUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
    };
  }
}