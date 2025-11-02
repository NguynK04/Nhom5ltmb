import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueModel {
  final String id;
  final DateTime date; // Ngày doanh thu (chỉ ngày, không giờ)
  final double totalRevenue; // Tổng doanh thu
  final double totalDiscount; // Tổng giảm giá
  final double totalTax; // Tổng thuế
  final double netRevenue; // Doanh thu ròng
  final int totalOrders; // Tổng số đơn hàng
  final int totalCustomers; // Tổng số khách hàng
  final Map<String, double> revenueByCategory; // Doanh thu theo danh mục
  final Map<String, int>
  ordersByPaymentMethod; // Đơn hàng theo phương thức thanh toán
  final Map<String, double>
  revenueByPaymentMethod; // Doanh thu theo phương thức thanh toán
  final Map<String, double> revenueByStaff; // Doanh thu theo nhân viên
  final List<TopProduct> topProducts; // Top sản phẩm bán chạy
  final DateTime createdAt;
  final DateTime updatedAt;

  RevenueModel({
    required this.id,
    required this.date,
    required this.totalRevenue,
    required this.totalDiscount,
    required this.totalTax,
    required this.netRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.revenueByCategory,
    required this.ordersByPaymentMethod,
    required this.revenueByPaymentMethod,
    required this.revenueByStaff,
    required this.topProducts,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory RevenueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RevenueModel(
      id: doc.id,
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      totalDiscount: (data['totalDiscount'] ?? 0).toDouble(),
      totalTax: (data['totalTax'] ?? 0).toDouble(),
      netRevenue: (data['netRevenue'] ?? 0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
      totalCustomers: data['totalCustomers'] ?? 0,
      revenueByCategory: Map<String, double>.from(
        data['revenueByCategory'] ?? {},
      ),
      ordersByPaymentMethod: Map<String, int>.from(
        data['ordersByPaymentMethod'] ?? {},
      ),
      revenueByPaymentMethod: Map<String, double>.from(
        data['revenueByPaymentMethod'] ?? {},
      ),
      revenueByStaff: Map<String, double>.from(data['revenueByStaff'] ?? {}),
      topProducts:
          (data['topProducts'] as List<dynamic>?)
              ?.map((item) => TopProduct.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
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
      'date': Timestamp.fromDate(date),
      'totalRevenue': totalRevenue,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'netRevenue': netRevenue,
      'totalOrders': totalOrders,
      'totalCustomers': totalCustomers,
      'revenueByCategory': revenueByCategory,
      'ordersByPaymentMethod': ordersByPaymentMethod,
      'revenueByPaymentMethod': revenueByPaymentMethod,
      'revenueByStaff': revenueByStaff,
      'topProducts': topProducts.map((product) => product.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Generate date key for daily revenue
  static String generateDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class TopProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopProduct.fromMap(Map<String, dynamic> map) {
    return TopProduct(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantitySold: map['quantitySold'] ?? 0,
      revenue: (map['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'revenue': revenue,
    };
  }
}
