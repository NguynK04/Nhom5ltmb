import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/core/constants/app_constants.dart';
import 'package:korderr/models/product_model.dart';
import 'package:korderr/services/firestore_service.dart';

class ProductRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = AppConstants.productsCollection;

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách sản phẩm: ${e.toString()}');
    }
  }

  // Get active products
  Future<List<ProductModel>> getActiveProducts() async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'isActive',
        true,
      );
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách sản phẩm: ${e.toString()}');
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'categoryId',
        categoryId,
      );
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách sản phẩm: ${e.toString()}');
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, productId);
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin sản phẩm: ${e.toString()}');
    }
  }

  // Create product
  Future<String> createProduct(ProductModel product) async {
    try {
      return await _firestoreService.createDocument(
        _collection,
        product.toMap(),
      );
    } catch (e) {
      throw Exception('Lỗi tạo sản phẩm: ${e.toString()}');
    }
  }

  // Update product
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestoreService.updateDocument(_collection, productId, data);
    } catch (e) {
      throw Exception('Lỗi cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Delete product (soft delete)
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreService.updateDocument(_collection, productId, {
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Lỗi xóa sản phẩm: ${e.toString()}');
    }
  }

  // Update stock
  Future<void> updateStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product != null) {
        final newStock = product.stock + quantity;
        await updateProduct(productId, {'stock': newStock});
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật tồn kho: ${e.toString()}');
    }
  }

  // Stream products
  Stream<List<ProductModel>> streamProducts() {
    return _firestoreService
        .streamCollection(_collection)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Filter by name (case-insensitive)
      return products
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm sản phẩm: ${e.toString()}');
    }
  }

  // Get featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'isFeatured',
        true,
      );
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm nổi bật: ${e.toString()}');
    }
  }

  // Get low stock products
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return products
          .where((product) => product.isActive && product.stock <= threshold)
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy sản phẩm sắp hết: ${e.toString()}');
    }
  }
}
