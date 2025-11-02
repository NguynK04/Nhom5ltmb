import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Script đơn giản để thêm dữ liệu mẫu vào Firebase
/// Chạy: dart run lib/add_sample_data_simple.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Khởi tạo Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  try {
    print('📝 Thêm categories...');

    // Thêm categories
    final categories = [
      {'name': 'Món Nướng', 'description': 'Các món nướng thơm ngon'},
      {'name': 'Món Nước', 'description': 'Các món canh, soup, lẩu'},
      {'name': 'Tráng Miệng', 'description': 'Kem, trái cây'},
    ];

    Map<String, String> categoryIds = {};

    for (final category in categories) {
      final docRef = await firestore.collection('categories').add({
        'name': category['name'],
        'description': category['description'],
        'icon': 'restaurant',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      categoryIds[category['name']!] = docRef.id;
      print('✅ Category: ${category['name']} - ${docRef.id}');
    }

    print('🍽️ Thêm products...');

    // Thêm products
    final products = [
      {
        'name': 'Thịt Bò Nướng Lá Lốt',
        'description': 'Thịt bò thượng hạng nướng lá lốt thơm ngon',
        'price': 180000.0,
        'categoryName': 'Món Nướng',
        'stock': 50,
        'unit': 'phần',
      },
      {
        'name': 'Sườn Nướng BBQ',
        'description': 'Sườn heo nướng BBQ đậm đà',
        'price': 220000.0,
        'categoryName': 'Món Nướng',
        'stock': 30,
        'unit': 'phần',
      },
      {
        'name': 'Lẩu Thái Chua Cay',
        'description': 'Lẩu thái truyền thống chua cay',
        'price': 450000.0,
        'categoryName': 'Món Nước',
        'stock': 10,
        'unit': 'nồi',
      },
      {
        'name': 'Canh Chua Cá Lóc',
        'description': 'Canh chua cá lóc miền Tây',
        'price': 120000.0,
        'categoryName': 'Món Nước',
        'stock': 35,
        'unit': 'tô',
      },
      {
        'name': 'Kem Flan Caramen',
        'description': 'Kem flan caramen thơm béo',
        'price': 35000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 50,
        'unit': 'ly',
      },
      {
        'name': 'Trái Cây Dĩa',
        'description': 'Dĩa trái cây tươi theo mùa',
        'price': 80000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 20,
        'unit': 'dĩa',
      },
    ];

    int addedCount = 0;
    for (final product in products) {
      final categoryId = categoryIds[product['categoryName']];

      if (categoryId != null) {
        final docRef = await firestore.collection('products').add({
          'name': product['name'],
          'description': product['description'],
          'price': product['price'],
          'image': null,
          'categoryId': categoryId,
          'categoryName': product['categoryName'],
          'stock': product['stock'],
          'unit': product['unit'],
          'isActive': true,
          'isFeatured': false,
          'discount': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        addedCount++;
        print('✅ Product: ${product['name']} - ${docRef.id}');
      }
    }

    print('\n🎉 HOÀN THÀNH!');
    print('📊 Thống kê:');
    print('   • Categories: ${categories.length}');
    print('   • Products: $addedCount');
    print('\n💡 Dữ liệu đã được thêm vào Firebase!');
    print('   Bây giờ bạn có thể xem trong app.');
  } catch (e) {
    print('❌ LỖI: $e');
  }
}
