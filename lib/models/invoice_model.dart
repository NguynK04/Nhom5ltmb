import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String orderId;
  final String orderCode;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String staffId;
  final String staffName;
  final List<InvoiceItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus; // paid, unpaid, partial
  final DateTime issueDate;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.orderId,
    required this.orderCode,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.staffId,
    required this.staffName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.issueDate,
    this.dueDate,
    this.paidDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return InvoiceModel(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      orderId: data['orderId'] ?? '',
      orderCode: data['orderCode'] ?? '',
      customerId: data['customerId'],
      customerName: data['customerName'],
      customerPhone: data['customerPhone'],
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      issueDate: data['issueDate'] != null
          ? (data['issueDate'] as Timestamp).toDate()
          : DateTime.now(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      paidDate: data['paidDate'] != null
          ? (data['paidDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
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
      'invoiceNumber': invoiceNumber,
      'orderId': orderId,
      'orderCode': orderCode,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'staffId': staffId,
      'staffName': staffName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'issueDate': Timestamp.fromDate(issueDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Generate invoice number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    return 'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }
}

class InvoiceItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? notes;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.notes,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'notes': notes,
    };
  }
}
