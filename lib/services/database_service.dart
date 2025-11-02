import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../models/invoice_model.dart';
import '../models/revenue_model.dart';
import '../models/staff_activity_model.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String COLLECTION_CUSTOMERS = 'customers';
  static const String COLLECTION_ORDERS = 'orders';
  static const String COLLECTION_INVOICES = 'invoices';
  static const String COLLECTION_REVENUE = 'revenue';
  static const String COLLECTION_STAFF_ACTIVITIES = 'staff_activities';
  static const String COLLECTION_STAFF_STATISTICS = 'staff_statistics';
  static const String COLLECTION_PRODUCTS = 'products';
  static const String COLLECTION_CATEGORIES = 'categories';

  // ==== CUSTOMER OPERATIONS ====

  /// Tạo khách hàng mới
  static Future<String> createCustomer(CustomerModel customer) async {
    try {
      final docRef = await _firestore
          .collection(COLLECTION_CUSTOMERS)
          .add(customer.toMap());

      // Log activity
      await logStaffActivity(
        staffId: 'current_staff_id', // Thay bằng ID staff hiện tại
        staffName: 'Current Staff', // Thay bằng tên staff hiện tại
        action: StaffActivityModel.ACTION_CREATE_CUSTOMER,
        targetId: docRef.id,
        targetType: 'customer',
        description: 'Tạo khách hàng mới: ${customer.fullName}',
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo khách hàng: $e');
    }
  }

  /// Cập nhật khách hàng
  static Future<void> updateCustomer(
    String customerId,
    CustomerModel customer,
  ) async {
    try {
      await _firestore
          .collection(COLLECTION_CUSTOMERS)
          .doc(customerId)
          .update(customer.toMap());

      // Log activity
      await logStaffActivity(
        staffId: 'current_staff_id',
        staffName: 'Current Staff',
        action: StaffActivityModel.ACTION_UPDATE_CUSTOMER,
        targetId: customerId,
        targetType: 'customer',
        description: 'Cập nhật thông tin khách hàng: ${customer.fullName}',
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật khách hàng: $e');
    }
  }

  /// Xóa khách hàng
  static Future<void> deleteCustomer(
    String customerId,
    String customerName,
  ) async {
    try {
      await _firestore
          .collection(COLLECTION_CUSTOMERS)
          .doc(customerId)
          .delete();

      // Log activity
      await logStaffActivity(
        staffId: 'current_staff_id',
        staffName: 'Current Staff',
        action: StaffActivityModel.ACTION_DELETE_CUSTOMER,
        targetId: customerId,
        targetType: 'customer',
        description: 'Xóa khách hàng: $customerName',
      );
    } catch (e) {
      throw Exception('Lỗi xóa khách hàng: $e');
    }
  }

  // ==== ORDER OPERATIONS ====

  /// Tạo đơn hàng mới
  static Future<String> createOrder(OrderModel order) async {
    final batch = _firestore.batch();

    try {
      // 1. Tạo đơn hàng
      final orderRef = _firestore.collection(COLLECTION_ORDERS).doc();
      batch.set(orderRef, order.toMap());

      // 2. Cập nhật thông tin khách hàng (nếu có)
      if (order.customerId != null) {
        final customerRef = _firestore
            .collection(COLLECTION_CUSTOMERS)
            .doc(order.customerId);
        final customerDoc = await customerRef.get();

        if (customerDoc.exists) {
          final customer = CustomerModel.fromFirestore(customerDoc);
          final pointsEarned = (order.finalAmount / 1000).floor();

          batch.update(customerRef, {
            'totalSpent': customer.totalSpent + order.finalAmount,
            'visitCount': customer.visitCount + 1,
            'loyaltyPoints': customer.loyaltyPoints + pointsEarned,
            'lastVisit': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Tạo hóa đơn
      final invoice = InvoiceModel(
        id: '',
        invoiceNumber: InvoiceModel.generateInvoiceNumber(),
        orderId: orderRef.id,
        orderCode: order.orderNumber,
        customerId: order.customerId,
        customerName: order.customerName,
        customerPhone: null, // Có thể lấy từ customer nếu cần
        staffId: order.staffId,
        staffName: order.staffName,
        items: order.items
            .map(
              (item) => InvoiceItem(
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.price,
                subtotal: item.subtotal,
                notes: item.notes,
              ),
            )
            .toList(),
        subtotal: order.totalAmount,
        discountAmount: order.discount ?? 0,
        taxAmount: order.tax ?? 0,
        totalAmount: order.finalAmount,
        paymentMethod: order.paymentMethod,
        paymentStatus: 'paid',
        issueDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final invoiceRef = _firestore.collection(COLLECTION_INVOICES).doc();
      batch.set(invoiceRef, invoice.toMap());

      // 4. Cập nhật doanh thu
      await _updateDailyRevenue(order);

      // Commit batch
      await batch.commit();

      // 5. Log activity
      await logStaffActivity(
        staffId: order.staffId,
        staffName: order.staffName,
        action: StaffActivityModel.ACTION_CREATE_ORDER,
        targetId: orderRef.id,
        targetType: 'order',
        description: 'Tạo đơn hàng mới: ${order.orderNumber}',
        metadata: {
          'orderAmount': order.finalAmount,
          'itemCount': order.items.length,
          'customerId': order.customerId,
        },
      );

      return orderRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<void> updateOrderStatus(
    String orderId,
    String status,
    String staffId,
    String staffName,
  ) async {
    try {
      await _firestore.collection(COLLECTION_ORDERS).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });

      // Log activity
      await logStaffActivity(
        staffId: staffId,
        staffName: staffName,
        action: StaffActivityModel.ACTION_UPDATE_ORDER,
        targetId: orderId,
        targetType: 'order',
        description: 'Cập nhật trạng thái đơn hàng: $status',
        metadata: {'newStatus': status},
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật đơn hàng: $e');
    }
  }

  // ==== REVENUE OPERATIONS ====

  /// Cập nhật doanh thu hàng ngày
  static Future<void> _updateDailyRevenue(OrderModel order) async {
    final dateKey = RevenueModel.generateDateKey(order.createdAt);
    final revenueRef = _firestore.collection(COLLECTION_REVENUE).doc(dateKey);

    try {
      await _firestore.runTransaction((transaction) async {
        final revenueDoc = await transaction.get(revenueRef);

        if (revenueDoc.exists) {
          // Cập nhật doanh thu hiện có
          final currentRevenue = RevenueModel.fromFirestore(revenueDoc);

          // Tính toán doanh thu theo danh mục
          final Map<String, double> newRevenueByCategory = Map.from(
            currentRevenue.revenueByCategory,
          );
          for (final item in order.items) {
            // Giả sử có thông tin category trong item, nếu không thì cần query thêm
            final categoryName =
                'General'; // Thay bằng logic lấy category thực tế
            newRevenueByCategory[categoryName] =
                (newRevenueByCategory[categoryName] ?? 0) + item.subtotal;
          }

          // Cập nhật doanh thu theo nhân viên
          final Map<String, double> newRevenueByStaff = Map.from(
            currentRevenue.revenueByStaff,
          );
          newRevenueByStaff[order.staffId] =
              (newRevenueByStaff[order.staffId] ?? 0) + order.finalAmount;

          // Cập nhật phương thức thanh toán
          final Map<String, int> newOrdersByPayment = Map.from(
            currentRevenue.ordersByPaymentMethod,
          );
          final Map<String, double> newRevenueByPayment = Map.from(
            currentRevenue.revenueByPaymentMethod,
          );

          newOrdersByPayment[order.paymentMethod] =
              (newOrdersByPayment[order.paymentMethod] ?? 0) + 1;
          newRevenueByPayment[order.paymentMethod] =
              (newRevenueByPayment[order.paymentMethod] ?? 0) +
              order.finalAmount;

          final updatedRevenue = RevenueModel(
            id: currentRevenue.id,
            date: currentRevenue.date,
            totalRevenue: currentRevenue.totalRevenue + order.finalAmount,
            totalDiscount: currentRevenue.totalDiscount + (order.discount ?? 0),
            totalTax: currentRevenue.totalTax + (order.tax ?? 0),
            netRevenue: currentRevenue.netRevenue + order.finalAmount,
            totalOrders: currentRevenue.totalOrders + 1,
            totalCustomers:
                currentRevenue.totalCustomers +
                (order.customerId != null ? 1 : 0),
            revenueByCategory: newRevenueByCategory,
            ordersByPaymentMethod: newOrdersByPayment,
            revenueByPaymentMethod: newRevenueByPayment,
            revenueByStaff: newRevenueByStaff,
            topProducts:
                currentRevenue.topProducts, // Cần logic cập nhật top products
            createdAt: currentRevenue.createdAt,
            updatedAt: DateTime.now(),
          );

          transaction.update(revenueRef, updatedRevenue.toMap());
        } else {
          // Tạo mới doanh thu cho ngày
          final newRevenue = RevenueModel(
            id: dateKey,
            date: DateTime(
              order.createdAt.year,
              order.createdAt.month,
              order.createdAt.day,
            ),
            totalRevenue: order.finalAmount,
            totalDiscount: order.discount ?? 0,
            totalTax: order.tax ?? 0,
            netRevenue: order.finalAmount,
            totalOrders: 1,
            totalCustomers: order.customerId != null ? 1 : 0,
            revenueByCategory: {
              'General': order.finalAmount,
            }, // Cần logic category thực tế
            ordersByPaymentMethod: {order.paymentMethod: 1},
            revenueByPaymentMethod: {order.paymentMethod: order.finalAmount},
            revenueByStaff: {order.staffId: order.finalAmount},
            topProducts: [], // Cần logic tính top products
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          transaction.set(revenueRef, newRevenue.toMap());
        }
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật doanh thu: $e');
    }
  }

  // ==== STAFF ACTIVITY OPERATIONS ====

  /// Log hoạt động của nhân viên
  static Future<void> logStaffActivity({
    required String staffId,
    required String staffName,
    required String action,
    String? targetId,
    String? targetType,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final activity = StaffActivityModel(
        id: '',
        staffId: staffId,
        staffName: staffName,
        action: action,
        targetId: targetId,
        targetType: targetType,
        description: description,
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection(COLLECTION_STAFF_ACTIVITIES)
          .add(activity.toMap());
    } catch (e) {
      // Log activity không nên làm crash app
      print('Lỗi log activity: $e');
    }
  }

  // ==== QUERY OPERATIONS ====

  /// Lấy doanh thu theo khoảng thời gian
  static Future<List<RevenueModel>> getRevenueByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(COLLECTION_REVENUE)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RevenueModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu doanh thu: $e');
    }
  }

  /// Lấy hoạt động nhân viên theo khoảng thời gian
  static Future<List<StaffActivityModel>> getStaffActivities({
    String? staffId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collection(COLLECTION_STAFF_ACTIVITIES);

      if (staffId != null) {
        query = query.where('staffId', isEqualTo: staffId);
      }

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (action != null) {
        query = query.where('action', isEqualTo: action);
      }

      query = query.orderBy('timestamp', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => StaffActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy hoạt động nhân viên: $e');
    }
  }

  /// Lấy thống kê tổng quan
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final today = DateTime.now();
      final todayKey = RevenueModel.generateDateKey(today);

      // Doanh thu hôm nay
      final todayRevenueDoc = await _firestore
          .collection(COLLECTION_REVENUE)
          .doc(todayKey)
          .get();
      final todayRevenue = todayRevenueDoc.exists
          ? RevenueModel.fromFirestore(todayRevenueDoc)
          : null;

      // Tổng số khách hàng
      final customersSnapshot = await _firestore
          .collection(COLLECTION_CUSTOMERS)
          .count()
          .get();
      final totalCustomers = customersSnapshot.count;

      // Đơn hàng hôm nay
      final ordersToday = await _firestore
          .collection(COLLECTION_ORDERS)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(today.year, today.month, today.day),
            ),
          )
          .where(
            'createdAt',
            isLessThan: Timestamp.fromDate(
              DateTime(today.year, today.month, today.day + 1),
            ),
          )
          .count()
          .get();

      return {
        'todayRevenue': todayRevenue?.totalRevenue ?? 0,
        'todayOrders': todayRevenue?.totalOrders ?? 0,
        'totalCustomers': totalCustomers,
        'todayOrdersCount': ordersToday.count,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê dashboard: $e');
    }
  }
}
