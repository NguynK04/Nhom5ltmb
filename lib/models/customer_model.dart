import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final String customerType; // 'regular', 'silver', 'gold', 'diamond'
  final double totalSpent;
  final int visitCount;
  final int loyaltyPoints; // Điểm tích lũy
  final String membershipLevel; // 'bronze', 'silver', 'gold', 'diamond'
  final DateTime? lastVisit;
  final double discountPercent; // Phần trám giảm giá cho thành viên
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    required this.customerType,
    required this.totalSpent,
    required this.visitCount,
    required this.loyaltyPoints,
    required this.membershipLevel,
    this.lastVisit,
    required this.discountPercent,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tính cấp độ thành viên dựa trên tổng chi tiêu
  static String calculateMembershipLevel(double totalSpent) {
    if (totalSpent >= 10000000) return 'diamond'; // 10 triệu+
    if (totalSpent >= 5000000) return 'gold'; // 5 triệu+
    if (totalSpent >= 2000000) return 'silver'; // 2 triệu+
    return 'bronze'; // Dưới 2 triệu
  }

  // Tính phần trăm giảm giá theo cấp độ
  static double calculateDiscountPercent(String membershipLevel) {
    switch (membershipLevel) {
      case 'diamond':
        return 15.0;
      case 'gold':
        return 10.0;
      case 'silver':
        return 5.0;
      case 'bronze':
        return 0.0;
      default:
        return 0.0;
    }
  }

  // Màu sắc theo cấp độ thành viên
  static String getMembershipColor(String membershipLevel) {
    switch (membershipLevel) {
      case 'diamond':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      case 'bronze':
        return '🥉';
      default:
        return '👤';
    }
  }

  // Tên hiển thị cấp độ
  static String getMembershipDisplayName(String membershipLevel) {
    switch (membershipLevel) {
      case 'diamond':
        return 'Kim Cương';
      case 'gold':
        return 'Vàng';
      case 'silver':
        return 'Bạc';
      case 'bronze':
        return 'Đồng';
      default:
        return 'Thường';
    }
  }

  // From Firestore
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final totalSpent = (data['totalSpent'] ?? 0).toDouble();
    final membershipLevel =
        data['membershipLevel'] ?? calculateMembershipLevel(totalSpent);

    return CustomerModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      address: data['address'],
      customerType: data['customerType'] ?? 'regular',
      totalSpent: totalSpent,
      visitCount: data['visitCount'] ?? 0,
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      membershipLevel: membershipLevel,
      lastVisit: data['lastVisit'] != null
          ? (data['lastVisit'] as Timestamp).toDate()
          : null,
      discountPercent:
          data['discountPercent'] ?? calculateDiscountPercent(membershipLevel),
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'customerType': customerType,
      'totalSpent': totalSpent,
      'visitCount': visitCount,
      'loyaltyPoints': loyaltyPoints,
      'membershipLevel': membershipLevel,
      'lastVisit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'discountPercent': discountPercent,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // CopyWith
  CustomerModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? address,
    String? customerType,
    double? totalSpent,
    int? visitCount,
    int? loyaltyPoints,
    String? membershipLevel,
    DateTime? lastVisit,
    double? discountPercent,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      totalSpent: totalSpent ?? this.totalSpent,
      visitCount: visitCount ?? this.visitCount,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      lastVisit: lastVisit ?? this.lastVisit,
      discountPercent: discountPercent ?? this.discountPercent,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
