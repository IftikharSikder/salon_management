// class Customer {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//   final String gender;
//
//   Customer({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.gender,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       id: json['id']?.toString() ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       gender: json['gender'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'address': address,
//       'gender': gender,
//     };
//   }
// }

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final DateTime? createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    this.createdAt,
  });

  // Factory constructor from your existing code
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  // Added to support Firestore conversion
  factory Customer.fromMap(Map<String, dynamic> map, String docId) {
    return Customer(
      id: map['id'] ?? docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      createdAt: map['created_at'] != null
          ? (map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  // Original toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Added to support Firestore conversions
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  // Create a copy with optional new values
  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gender,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, email: $email, phone: $phone, address: $address, gender: $gender)';
  }
}