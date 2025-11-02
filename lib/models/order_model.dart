import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/models/order_item_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String? customerName;
  final String staffId;
  final String staffName;
  final String? tableNumber;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double? discount;
  final double? tax;
  final double finalAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    required this.staffId,
    required this.staffName,
    this.tableNumber,
    required this.items,
    required this.totalAmount,
    this.discount,
    this.tax,
    required this.finalAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  // Calculate total amount from items
  static double calculateTotalAmount(List<OrderItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Calculate final amount with discount and tax
  static double calculateFinalAmount(
    double totalAmount, {
    double? discount,
    double? tax,
  }) {
    double amount = totalAmount;

    // Apply discount
    if (discount != null && discount > 0) {
      amount -= discount;
    }

    // Apply tax
    if (tax != null && tax > 0) {
      amount += (amount * tax);
    }

    return amount;
  }

  // From Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final itemsList = (data['items'] as List<dynamic>)
        .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      customerId: data['customerId'],
      customerName: data['customerName'],
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      tableNumber: data['tableNumber'],
      items: itemsList,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      discount: data['discount']?.toDouble(),
      tax: data['tax']?.toDouble(),
      finalAmount: (data['finalAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'staffId': staffId,
      'staffName': staffName,
      'tableNumber': tableNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'discount': discount,
      'tax': tax,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  // CopyWith
  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? staffId,
    String? staffName,
    String? tableNumber,
    List<OrderItemModel>? items,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    String? paymentMethod,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
