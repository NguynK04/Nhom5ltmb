import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo tài khoản nhân viên mới với mật khẩu mặc định
  static Future<String> createStaffAccount({
    required String email,
    required String fullName,
    required String phone,
    String defaultPassword = '123456',
  }) async {
    try {
      // Lưu user hiện tại
      final currentUser = _auth.currentUser;

      // Tạo tài khoản mới
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: defaultPassword,
      );

      final newUser = userCredential.user;
      if (newUser == null) throw Exception('Không thể tạo tài khoản');

      // Cập nhật display name
      await newUser.updateDisplayName(fullName);

      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(newUser.uid).set({
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'role': 'staff',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser?.email,
      });

      // Đăng xuất tài khoản mới tạo
      await _auth.signOut();

      // Đăng nhập lại bằng tài khoản admin
      if (currentUser != null) {
        // Cần admin đăng nhập lại thủ công hoặc dùng refresh token
        // Ở đây chúng ta sẽ để admin tự đăng nhập lại
      }

      return newUser.uid;
    } catch (e) {
      rethrow;
    }
  }

  /// Vô hiệu hóa tài khoản nhân viên
  static Future<void> deactivateStaffAccount(String staffId) async {
    try {
      await _firestore.collection('users').doc(staffId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'deactivatedBy': _auth.currentUser?.email,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Kích hoạt lại tài khoản nhân viên
  static Future<void> activateStaffAccount(String staffId) async {
    try {
      await _firestore.collection('users').doc(staffId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'reactivatedBy': _auth.currentUser?.email,
        'reactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách tất cả nhân viên
  static Stream<QuerySnapshot> getStaffList() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots();
  }

  /// Cập nhật thông tin nhân viên
  static Future<void> updateStaffInfo({
    required String staffId,
    required String fullName,
    required String phone,
  }) async {
    try {
      await _firestore.collection('users').doc(staffId).update({
        'fullName': fullName,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.email,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Tạo yêu cầu reset mật khẩu cho nhân viên
  static Future<void> createPasswordResetRequest({
    required String staffId,
    required String staffEmail,
    required String staffName,
    required String newPassword,
  }) async {
    try {
      await _firestore.collection('password_resets').add({
        'staffId': staffId,
        'staffEmail': staffEmail,
        'staffName': staffName,
        'newPassword': newPassword,
        'requestedBy': _auth.currentUser?.email,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'type': 'admin_reset',
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách yêu cầu reset mật khẩu
  static Stream<QuerySnapshot> getPasswordResetRequests() {
    return _firestore
        .collection('password_resets')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Đánh dấu yêu cầu reset mật khẩu đã hoàn thành
  static Future<void> markPasswordResetCompleted(String requestId) async {
    try {
      await _firestore.collection('password_resets').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'completedBy': _auth.currentUser?.email,
      });
    } catch (e) {
      rethrow;
    }
  }
}
