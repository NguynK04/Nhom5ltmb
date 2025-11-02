import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/core/constants/app_constants.dart';
import 'package:korderr/models/category_model.dart';
import 'package:korderr/services/firestore_service.dart';

class CategoryRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = AppConstants.categoriesCollection;

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestoreService.getCollection(_collection);
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách danh mục: ${e.toString()}');
    }
  }

  // Get active categories
  Future<List<CategoryModel>> getActiveCategories() async {
    try {
      final snapshot = await _firestoreService.searchByField(
        _collection,
        'isActive',
        true,
      );
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách danh mục: ${e.toString()}');
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, categoryId);
      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin danh mục: ${e.toString()}');
    }
  }

  // Create category
  Future<String> createCategory(CategoryModel category) async {
    try {
      return await _firestoreService.createDocument(
        _collection,
        category.toMap(),
      );
    } catch (e) {
      throw Exception('Lỗi tạo danh mục: ${e.toString()}');
    }
  }

  // Update category
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestoreService.updateDocument(_collection, categoryId, data);
    } catch (e) {
      throw Exception('Lỗi cập nhật danh mục: ${e.toString()}');
    }
  }

  // Delete category (soft delete)
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestoreService.updateDocument(_collection, categoryId, {
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Lỗi xóa danh mục: ${e.toString()}');
    }
  }

  // Stream categories
  Stream<List<CategoryModel>> streamCategories() {
    return _firestoreService
        .streamCollection(_collection)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList(),
        );
  }
}
