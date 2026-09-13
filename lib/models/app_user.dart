class AppUser {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String phone;
  final String gender;
  final String dob;
  final String nic;
  final String address;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.nic,
    required this.address,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      dob: data['dob'] ?? '',
      nic: data['nic'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'nic': nic,
      'address': address,
    };
  }
}