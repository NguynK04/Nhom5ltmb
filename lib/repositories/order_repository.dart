import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/core/constants/app_constants.dart';
import 'package:korderr/models/order_model.dart';
import 'package:korderr/services/firestore_service.dart';
import 'package:korderr/core/utils/formatters.dart';

class OrderRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = AppConstants.ordersCollection;

  // Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: ${e.toString()}');
    }
  }

  // Get orders by staff
  Future<List<OrderModel>> getOrdersByStaff(String staffId) async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'staffId',
        staffId,
      );
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: ${e.toString()}');
    }
  }

  // Get orders by customer
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'customerId',
        customerId,
      );
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: ${e.toString()}');
    }
  }

  // Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'status',
        status,
      );
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: ${e.toString()}');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, orderId);
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin đơn hàng: ${e.toString()}');
    }
  }

  // Create order
  Future<String> createOrder(OrderModel order) async {
    try {
      return await _firestoreService.createDocument(_collection, order.toMap());
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: ${e.toString()}');
    }
  }

  // Update order
  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestoreService.updateDocument(_collection, orderId, data);
    } catch (e) {
      throw Exception('Lỗi cập nhật đơn hàng: ${e.toString()}');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final data = {
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // If completed, set completedAt
      if (status == AppConstants.orderStatusCompleted) {
        data['completedAt'] = Timestamp.fromDate(DateTime.now());
      }

      await _firestoreService.updateDocument(_collection, orderId, data);
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái: ${e.toString()}');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, AppConstants.orderStatusCancelled);
    } catch (e) {
      throw Exception('Lỗi hủy đơn hàng: ${e.toString()}');
    }
  }

  // Stream orders
  Stream<List<OrderModel>> streamOrders() {
    return _firestoreService
        .streamCollection(_collection)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream orders by staff
  Stream<List<OrderModel>> streamOrdersByStaff(String staffId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('staffId', isEqualTo: staffId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get orders by date range
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng theo ngày: ${e.toString()}');
    }
  }

  // Get today's orders
  Future<List<OrderModel>> getTodayOrders() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return await getOrdersByDateRange(start, end);
  }

  // Generate order number
  Future<String> generateOrderNumber() async {
    try {
      final today = DateTime.now();
      final todayOrders = await getTodayOrders();
      final sequence = todayOrders.length + 1;
      return Formatters.generateOrderNumber(today, sequence);
    } catch (e) {
      // Fallback if error
      final now = DateTime.now();
      return Formatters.generateOrderNumber(
        now,
        now.millisecondsSinceEpoch % 1000,
      );
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final todayOrders = await getTodayOrders();

      double totalRevenue = 0;
      int completedCount = 0;
      int totalItems = 0;

      for (var order in todayOrders) {
        if (order.status == AppConstants.orderStatusCompleted) {
          totalRevenue += order.finalAmount;
          completedCount++;
          totalItems += order.items.fold(0, (sum, item) => sum + item.quantity);
        }
      }

      return {
        'totalOrders': todayOrders.length,
        'completedOrders': completedCount,
        'totalRevenue': totalRevenue,
        'totalItems': totalItems,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê: ${e.toString()}');
    }
  }
}
