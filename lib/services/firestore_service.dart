import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create document
  Future<String> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo dữ liệu: ${e.toString()}');
    }
  }

  // Create document with custom ID
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw Exception('Lỗi tạo dữ liệu: ${e.toString()}');
    }
  }

  // Get document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu: ${e.toString()}');
    }
  }

  // Update document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Lỗi cập nhật dữ liệu: ${e.toString()}');
    }
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa dữ liệu: ${e.toString()}');
    }
  }

  // Get collection
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu: ${e.toString()}');
    }
  }

  // Get collection with query
  Future<QuerySnapshot> getCollectionWithQuery(
    String collection, {
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (var filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu: ${e.toString()}');
    }
  }

  // Stream collection
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Stream document
  Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Batch write
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (var operation in operations) {
        final docRef = _firestore
            .collection(operation.collection)
            .doc(operation.docId);

        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(docRef, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi batch write: ${e.toString()}');
    }
  }

  // Search by field
  Future<QuerySnapshot> searchByField(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      return await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: ${e.toString()}');
    }
  }
}

// Helper classes
class QueryFilter {
  final String field;
  final dynamic value;

  QueryFilter({required this.field, required this.value});
}

enum BatchOperationType { set, update, delete }

class BatchOperation {
  final String collection;
  final String docId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.collection,
    required this.docId,
    required this.type,
    this.data,
  });
}
