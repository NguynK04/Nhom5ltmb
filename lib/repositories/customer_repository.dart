import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/core/constants/app_constants.dart';
import 'package:korderr/models/customer_model.dart';
import 'package:korderr/services/firestore_service.dart';
import 'package:korderr/core/utils/helpers.dart';

class CustomerRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = AppConstants.customersCollection;

  // Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      return snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách khách hàng: ${e.toString()}');
    }
  }

  // Get active customers
  Future<List<CustomerModel>> getActiveCustomers() async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'isActive',
        true,
      );
      return snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách khách hàng: ${e.toString()}');
    }
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, customerId);
      if (doc.exists) {
        return CustomerModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin khách hàng: ${e.toString()}');
    }
  }

  // Get customer by phone
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'phone',
        phone,
      );
      if (snapshot.docs.isNotEmpty) {
        return CustomerModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi tìm khách hàng: ${e.toString()}');
    }
  }

  // Create customer
  Future<String> createCustomer(CustomerModel customer) async {
    try {
      return await _firestoreService.createDocument(
        _collection,
        customer.toMap(),
      );
    } catch (e) {
      throw Exception('Lỗi tạo khách hàng: ${e.toString()}');
    }
  }

  // Update customer
  Future<void> updateCustomer(
    String customerId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());

      // Update customer type based on totalSpent and visitCount
      if (data.containsKey('totalSpent') || data.containsKey('visitCount')) {
        final customer = await getCustomerById(customerId);
        if (customer != null) {
          final totalSpent = data['totalSpent'] ?? customer.totalSpent;
          final visitCount = data['visitCount'] ?? customer.visitCount;
          data['customerType'] = Helpers.determineCustomerType(
            totalSpent.toDouble(),
            visitCount,
          );
        }
      }

      await _firestoreService.updateDocument(_collection, customerId, data);
    } catch (e) {
      throw Exception('Lỗi cập nhật khách hàng: ${e.toString()}');
    }
  }

  // Delete customer (soft delete)
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestoreService.updateDocument(_collection, customerId, {
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Lỗi xóa khách hàng: ${e.toString()}');
    }
  }

  // Update customer spending
  Future<void> updateCustomerSpending(String customerId, double amount) async {
    try {
      final customer = await getCustomerById(customerId);
      if (customer != null) {
        final newTotalSpent = customer.totalSpent + amount;
        final newVisitCount = customer.visitCount + 1;
        await updateCustomer(customerId, {
          'totalSpent': newTotalSpent,
          'visitCount': newVisitCount,
        });
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật chi tiêu: ${e.toString()}');
    }
  }

  // Revert customer spending (when order is cancelled)
  Future<void> revertCustomerSpending(String customerId, double amount) async {
    try {
      final customer = await getCustomerById(customerId);
      if (customer != null) {
        final newTotalSpent = (customer.totalSpent - amount).clamp(
          0,
          double.infinity,
        );
        final newVisitCount = (customer.visitCount - 1).clamp(0, 999999);
        await updateCustomer(customerId, {
          'totalSpent': newTotalSpent,
          'visitCount': newVisitCount,
        });
      }
    } catch (e) {
      throw Exception('Lỗi hoàn chi tiêu: ${e.toString()}');
    }
  }

  // Stream customers
  Stream<List<CustomerModel>> streamCustomers() {
    return _firestoreService
        .streamCollection(_collection)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Search customers by name or phone
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      final customers = snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();

      return customers
          .where(
            (customer) =>
                customer.fullName.toLowerCase().contains(query.toLowerCase()) ||
                customer.phone.contains(query),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm khách hàng: ${e.toString()}');
    }
  }

  // Get customers by type
  Future<List<CustomerModel>> getCustomersByType(String type) async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'customerType',
        type,
      );
      return snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy khách hàng theo loại: ${e.toString()}');
    }
  }

  // Get new customers (this month)
  Future<List<CustomerModel>> getNewCustomersThisMonth() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .get();

      return snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy khách hàng mới: ${e.toString()}');
    }
  }
}
