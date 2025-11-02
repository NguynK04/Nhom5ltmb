import 'package:cloud_firestore/cloud_firestore.dart';

class StaffActivityModel {
  final String id;
  final String staffId;
  final String staffName;
  final String
  action; // 'login', 'logout', 'create_order', 'update_order', 'cancel_order', 'create_customer', etc.
  final String?
  targetId; // ID của đối tượng bị tác động (orderId, customerId, productId, etc.)
  final String? targetType; // 'order', 'customer', 'product', 'category'
  final String? description; // Mô tả chi tiết hành động
  final Map<String, dynamic>? metadata; // Dữ liệu bổ sung
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;

  StaffActivityModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.action,
    this.targetId,
    this.targetType,
    this.description,
    this.metadata,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
  });

  // From Firestore
  factory StaffActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StaffActivityModel(
      id: doc.id,
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      action: data['action'] ?? '',
      targetId: data['targetId'],
      targetType: data['targetType'],
      description: data['description'],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      ipAddress: data['ipAddress'],
      deviceInfo: data['deviceInfo'],
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'action': action,
      'targetId': targetId,
      'targetType': targetType,
      'description': description,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }

  // Activity types
  static const String ACTION_LOGIN = 'login';
  static const String ACTION_LOGOUT = 'logout';
  static const String ACTION_CREATE_ORDER = 'create_order';
  static const String ACTION_UPDATE_ORDER = 'update_order';
  static const String ACTION_CANCEL_ORDER = 'cancel_order';
  static const String ACTION_COMPLETE_ORDER = 'complete_order';
  static const String ACTION_CREATE_CUSTOMER = 'create_customer';
  static const String ACTION_UPDATE_CUSTOMER = 'update_customer';
  static const String ACTION_DELETE_CUSTOMER = 'delete_customer';
  static const String ACTION_CREATE_PRODUCT = 'create_product';
  static const String ACTION_UPDATE_PRODUCT = 'update_product';
  static const String ACTION_DELETE_PRODUCT = 'delete_product';
  static const String ACTION_CREATE_CATEGORY = 'create_category';
  static const String ACTION_UPDATE_CATEGORY = 'update_category';
  static const String ACTION_DELETE_CATEGORY = 'delete_category';
  static const String ACTION_GENERATE_REPORT = 'generate_report';
  static const String ACTION_EXPORT_DATA = 'export_data';
}

class StaffStatistics {
  final String staffId;
  final String staffName;
  final DateTime date;
  final int totalOrders;
  final double totalRevenue;
  final int totalCustomersServed;
  final double averageOrderValue;
  final int totalActions;
  final Map<String, int> actionCounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffStatistics({
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCustomersServed,
    required this.averageOrderValue,
    required this.totalActions,
    required this.actionCounts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffStatistics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StaffStatistics(
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      totalOrders: data['totalOrders'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      totalCustomersServed: data['totalCustomersServed'] ?? 0,
      averageOrderValue: (data['averageOrderValue'] ?? 0).toDouble(),
      totalActions: data['totalActions'] ?? 0,
      actionCounts: Map<String, int>.from(data['actionCounts'] ?? {}),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'date': Timestamp.fromDate(date),
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'totalCustomersServed': totalCustomersServed,
      'averageOrderValue': averageOrderValue,
      'totalActions': totalActions,
      'actionCounts': actionCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
