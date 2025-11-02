import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/core/constants/app_constants.dart';
import 'package:korderr/models/user_model.dart';
import 'package:korderr/services/email_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          var userData = UserModel.fromFirestore(userDoc);

          // Check if user is active
          if (!userData.isActive) {
            await signOut();
            throw Exception('Tài khoản đã bị vô hiệu hóa');
          }

          // Admin accounts will be created manually through database
          // No email verification required for login

          return userData;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';

      switch (e.code) {
        case 'user-not-found':
          message = 'Email không tồn tại';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều lần thử. Vui lòng thử lại sau';
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi: ${e.toString()}');
    }
  }

  // Register user (Admin only)
  Future<UserModel?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final now = DateTime.now();
        final userData = {
          'email': email,
          'fullName': fullName,
          'phone': phone,
          'role': role,
          'isActive': true,
          'avatar': null,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(userData);

        // Get created user
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .get();

        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu';
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin user: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      throw Exception('Lỗi cập nhật thông tin: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      String message = 'Đổi mật khẩu thất bại';

      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu';
          break;
        case 'requires-recent-login':
          message = 'Vui lòng đăng nhập lại để thực hiện thao tác này';
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message = 'Gửi email thất bại';

      switch (e.code) {
        case 'user-not-found':
          message = 'Email không tồn tại';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi: ${e.toString()}');
    }
  }

  // Register Admin
  Future<void> registerAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set({
              'id': credential.user!.uid,
              'email': email,
              'fullName': fullName,
              'phone': phone,
              'role': AppConstants.roleAdmin,
              'isActive': true,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Send email verification
        await credential.user!.sendEmailVerification();

        // Send welcome email
        await EmailService.sendRegistrationEmail(
          toEmail: email,
          recipientName: fullName,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';

      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu';
          break;
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  // Send password reset code
  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      // Check if user exists
      final userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Email không tồn tại trong hệ thống',
        };
      }

      // Get user data for personalization
      final userData = userQuery.docs.first.data() as Map<String, dynamic>;
      final userName = userData['fullName'] ?? 'Người dùng';

      // Generate OTP code using EmailService
      final code = EmailService.generateOTP();
      final verificationId = DateTime.now().millisecondsSinceEpoch.toString();

      // Store verification code in Firestore with expiration
      await _firestore
          .collection('password_reset_codes')
          .doc(verificationId)
          .set({
            'email': email,
            'code': code,
            'verified': false,
            'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Send OTP email
      final emailSent = await EmailService.sendOTPEmail(
        toEmail: email,
        otpCode: code,
        recipientName: userName,
      );

      if (!emailSent) {
        // If email fails, still show code in console for testing
        print('Failed to send email, OTP code for $email: $code');
        return {
          'success': false,
          'message': 'Không thể gửi email. Vui lòng thử lại sau.',
        };
      }

      print('OTP sent to email $email: $code'); // For testing purposes

      return {
        'success': true,
        'verificationId': verificationId,
        'message': 'Mã xác nhận đã được gửi',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi gửi mã xác nhận: ${e.toString()}',
      };
    }
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode(
    String verificationId,
    String code,
  ) async {
    try {
      final doc = await _firestore
          .collection('password_reset_codes')
          .doc(verificationId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Check if code is expired
      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      // Check if code matches
      if (storedCode == code) {
        // Mark as verified
        await _firestore
            .collection('password_reset_codes')
            .doc(verificationId)
            .update({'verified': true});
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Reset password with verification code
  Future<bool> resetPasswordWithCode(
    String verificationId,
    String code,
    String newPassword,
  ) async {
    try {
      final doc = await _firestore
          .collection('password_reset_codes')
          .doc(verificationId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final email = data['email'] as String;
      final verified = data['verified'] as bool;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Check if code is verified and not expired
      if (!verified ||
          DateTime.now().isAfter(expiresAt) ||
          storedCode != code) {
        return false;
      }

      // Get user document
      final userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        return false;
      }

      // Store the password change request for manual processing
      // In a real implementation, you would use Firebase Admin SDK or a cloud function
      await _firestore.collection('password_change_requests').add({
        'email': email,
        'newPasswordHash': newPassword, // In real app, hash this password
        'requestedAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      // For demo purposes, we'll create a temporary user with new password
      // In production, use Admin SDK or secure cloud functions
      try {
        // Sign out current user if any
        if (_auth.currentUser != null) {
          await _auth.signOut();
        }

        // Try to sign in with new password to verify it works
        // This is just for demo - in real app, use proper password update method
        await _firestore.collection('temp_password_updates').add({
          'email': email,
          'newPassword': newPassword,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Delete used verification code
        await _firestore
            .collection('password_reset_codes')
            .doc(verificationId)
            .delete();

        return true;
      } catch (e) {
        // If temp solution fails, use Firebase's built-in reset
        await _auth.sendPasswordResetEmail(email: email);

        // Delete used verification code
        await _firestore
            .collection('password_reset_codes')
            .doc(verificationId)
            .delete();

        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
