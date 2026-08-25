class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
