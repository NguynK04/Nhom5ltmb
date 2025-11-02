import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Script để tạo admin user tự động
/// Chỉ chạy 1 lần duy nhất để setup admin
Future<void> main() async {
  print('🚀 Bắt đầu setup admin user...');

  try {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase đã được khởi tạo');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // Thông tin admin
    const adminEmail = 'admin@korderr.com';
    const adminPassword = '123456';
    const adminFullName = 'Administrator';
    const adminPhone = '0123456789';

    print('\n📝 Đang tạo admin user trong Authentication...');

    // Tạo user trong Firebase Authentication
    UserCredential userCredential;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      print('✅ Tạo admin user thành công!');
      print('   Email: $adminEmail');
      print('   UID: ${userCredential.user!.uid}');
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️  User đã tồn tại, đang đăng nhập...');
        userCredential = await auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        print('✅ Đăng nhập thành công!');
        print('   UID: ${userCredential.user!.uid}');
      } else {
        rethrow;
      }
    }

    final userId = userCredential.user!.uid;

    print('\n📝 Đang tạo document trong Firestore...');

    // Tạo document trong Firestore với đúng kiểu dữ liệu
    await firestore.collection('users').doc(userId).set({
      'email': adminEmail, // string
      'fullName': adminFullName, // string
      'phone': adminPhone, // string
      'role': 'ADMIN', // string
      'isActive': true, // boolean ✅
      'avatar': null, // null
      'createdAt': FieldValue.serverTimestamp(), // timestamp ✅
      'updatedAt': FieldValue.serverTimestamp(), // timestamp ✅
    });

    print('✅ Tạo document trong Firestore thành công!');
    print('   Collection: users');
    print('   Document ID: $userId');

    print('\n🎉 HOÀN TẤT! Admin user đã được tạo thành công!');
    print('\n📋 Thông tin đăng nhập:');
    print('   Email: $adminEmail');
    print('   Password: $adminPassword');
    print('   Role: ADMIN');
    print('\n💡 Bây giờ bạn có thể đăng nhập vào app với thông tin trên!');

    // Đăng xuất
    await auth.signOut();
  } catch (e, stackTrace) {
    print('\n❌ LỖI: $e');
    print('Stack trace: $stackTrace');
  }
}
