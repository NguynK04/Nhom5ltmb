import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Script để thêm dữ liệu thực đơn mẫu
/// Bao gồm categories và products
Future<void> main() async {
  print('🍽️ Bắt đầu thêm dữ liệu thực đơn...');

  try {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase đã được khởi tạo');

    final firestore = FirebaseFirestore.instance;

    // 1. Tạo Categories trước
    print('\n📂 Đang tạo categories...');

    final categories = [
      {
        'name': 'Món Nướng',
        'description': 'Các món nướng thơm ngon, nướng than hoa',
        'icon': 'local_fire_department',
        'isActive': true,
      },
      {
        'name': 'Món Nước',
        'description': 'Các món canh, soup, lẩu',
        'icon': 'soup_kitchen',
        'isActive': true,
      },
      {
        'name': 'Tráng Miệng',
        'description': 'Kem, trái cây và các món tráng miệng',
        'icon': 'icecream',
        'isActive': true,
      },
    ];

    Map<String, String> categoryIds = {};

    for (final category in categories) {
      final docRef = await firestore.collection('categories').add({
        ...category,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      categoryIds[category['name'] as String] = docRef.id;
      print('✅ Tạo category: ${category['name']}');
    }

    // 2. Tạo Products
    print('\n🍖 Đang tạo products...');

    final products = [
      // Món Nướng
      {
        'name': 'Thịt Bò Nướng Lá Lốt',
        'description':
            'Thịt bò thượng hạng được ướp gia vị đặc biệt, cuộn lá lốt nướng than hoa thơm phức',
        'price': 180000.0,
        'categoryName': 'Món Nướng',
        'stock': 50,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': true,
        'discount': 10.0,
      },
      {
        'name': 'Sườn Nướng BBQ',
        'description':
            'Sườn heo non nướng với sauce BBQ đặc trưng, thịt mềm ngọt đậm đà',
        'price': 220000.0,
        'categoryName': 'Món Nướng',
        'stock': 30,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': true,
        'discount': null,
      },
      {
        'name': 'Gà Nướng Muối Ớt',
        'description':
            'Gà ta nướng muối ớt thơm lừng, da giòn thịt ngọt, ăn kèm rau sống',
        'price': 350000.0,
        'categoryName': 'Món Nướng',
        'stock': 20,
        'unit': 'con',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Chả Cá Nướng',
        'description': 'Chả cá tự làm nướng than hoa, thơm béo đậm đà hương vị',
        'price': 120000.0,
        'categoryName': 'Món Nướng',
        'stock': 40,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': false,
        'discount': 5.0,
      },
      {
        'name': 'Tôm Nướng Phô Mai',
        'description':
            'Tôm sú tươi nướng với phô mai thơm béo, ăn kèm bánh mì nướng',
        'price': 280000.0,
        'categoryName': 'Món Nướng',
        'stock': 25,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': true,
        'discount': null,
      },
      {
        'name': 'Cánh Gà Nướng Mật Ong',
        'description':
            'Cánh gà nướng với mật ong và gia vị đặc biệt, vị ngọt đậm đà',
        'price': 80000.0,
        'categoryName': 'Món Nướng',
        'stock': 60,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Bạch Tuộc Nướng',
        'description':
            'Bạch tuộc tươi nướng than hoa, ăn kèm wasabi và tương ớt',
        'price': 250000.0,
        'categoryName': 'Món Nướng',
        'stock': 15,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },

      // Món Nước
      {
        'name': 'Lẩu Thái Chua Cay',
        'description':
            'Lẩu thái truyền thống với nước dùng chua cay đậm đà, đầy đủ hải sản tươi ngon',
        'price': 450000.0,
        'categoryName': 'Món Nước',
        'stock': 10,
        'unit': 'nồi',
        'isActive': true,
        'isFeatured': true,
        'discount': 15.0,
      },
      {
        'name': 'Canh Chua Cá Lóc',
        'description':
            'Canh chua cá lóc truyền thống miền Tây với cà chua, dứa, đậu bắp',
        'price': 120000.0,
        'categoryName': 'Món Nước',
        'stock': 35,
        'unit': 'tô',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Soup Hến',
        'description':
            'Soup hến đậm đà với nước dùng trong vắt, thịt hến tươi ngọt',
        'price': 90000.0,
        'categoryName': 'Món Nước',
        'stock': 40,
        'unit': 'tô',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Lẩu Gà Lá É',
        'description':
            'Lẩu gà truyền thống với lá é thơm, nước dùng ngọt thanh',
        'price': 380000.0,
        'categoryName': 'Món Nước',
        'stock': 12,
        'unit': 'nồi',
        'isActive': true,
        'isFeatured': true,
        'discount': null,
      },
      {
        'name': 'Canh Bí Đỏ Tôm Khô',
        'description': 'Canh bí đỏ ngọt thanh với tôm khô thơm béo, bổ dưỡng',
        'price': 85000.0,
        'categoryName': 'Món Nước',
        'stock': 30,
        'unit': 'tô',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Soup Cua Asparagus',
        'description': 'Soup cua măng tây thơm béo, dinh dưỡng cao',
        'price': 150000.0,
        'categoryName': 'Món Nước',
        'stock': 25,
        'unit': 'tô',
        'isActive': true,
        'isFeatured': false,
        'discount': 8.0,
      },

      // Tráng Miệng
      {
        'name': 'Kem Flan Caramen',
        'description':
            'Kem flan caramen thơm béo, vị ngọt dịu nhẹ, làm từ trứng gà tươi',
        'price': 35000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 50,
        'unit': 'ly',
        'isActive': true,
        'isFeatured': true,
        'discount': null,
      },
      {
        'name': 'Chè Đậu Đỏ',
        'description': 'Chè đậu đỏ truyền thống với nước cốt dừa thơm béo',
        'price': 25000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 60,
        'unit': 'tô',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Trái Cây Dĩa',
        'description': 'Dĩa trái cây tươi theo mùa: xoài, dứa, nho, táo, lê...',
        'price': 80000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 20,
        'unit': 'dĩa',
        'isActive': true,
        'isFeatured': true,
        'discount': null,
      },
      {
        'name': 'Kem Dừa Nướng',
        'description': 'Kem dừa nướng thơm béo trong trái dừa tươi, độc đáo',
        'price': 55000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 30,
        'unit': 'trái',
        'isActive': true,
        'isFeatured': true,
        'discount': null,
      },
      {
        'name': 'Bánh Flan Nướng',
        'description': 'Bánh flan nướng với lớp caramen đậm đà, thơm béo',
        'price': 40000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 40,
        'unit': 'miếng',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
      {
        'name': 'Chè Sương Sa Hạt Lựu',
        'description': 'Chè sương sa hạt lựu mát lạnh, đẹp mắt và thơm ngon',
        'price': 30000.0,
        'categoryName': 'Tráng Miệng',
        'stock': 45,
        'unit': 'ly',
        'isActive': true,
        'isFeatured': false,
        'discount': null,
      },
    ];

    int addedCount = 0;
    for (final product in products) {
      final categoryId = categoryIds[product['categoryName']];
      if (categoryId != null) {
        await firestore.collection('products').add({
          'name': product['name'],
          'description': product['description'],
          'price': product['price'],
          'image': null, // Có thể thêm URL hình ảnh sau
          'categoryId': categoryId,
          'categoryName': product['categoryName'],
          'stock': product['stock'],
          'unit': product['unit'],
          'isActive': product['isActive'],
          'isFeatured': product['isFeatured'],
          'discount': product['discount'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        addedCount++;
        print('✅ Thêm món: ${product['name']} - ${product['price']}đ');
      }
    }

    print('\n🎉 HOÀN TẤT!');
    print('📊 Thống kê:');
    print('   • Categories: ${categories.length}');
    print('   • Products: $addedCount');
    print('\n💡 Dữ liệu thực đơn đã được thêm thành công vào Firebase!');
    print('   Bây giờ bạn có thể xem thực đơn trong app.');
  } catch (e, stackTrace) {
    print('\n❌ LỖI: $e');
    print('Stack trace: $stackTrace');
  }
}
