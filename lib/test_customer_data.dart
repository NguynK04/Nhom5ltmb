import 'package:cloud_firestore/cloud_firestore.dart';

class TestCustomerData {
  static Future<void> addSampleCustomers() async {
    final firestore = FirebaseFirestore.instance;

    final customers = [
      {
        'fullName': 'Nguyễn Văn Anh',
        'phone': '0901234567',
        'email': 'anh.nguyen@email.com',
        'address': '123 Đường ABC, Quận 1, TP.HCM',
        'customerType': 'vip',
        'totalSpent': 2500000.0,
        'visitCount': 15,
        'loyaltyPoints': 250,
        'membershipLevel': 'gold',
        'discountPercent': 10.0,
        'notes': 'Khách hàng thân thiết, thích món cà ri gà',
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'lastVisit': Timestamp.now(),
      },
      {
        'fullName': 'Trần Thị Bình',
        'phone': '0912345678',
        'email': 'binh.tran@email.com',
        'address': '456 Đường XYZ, Quận 2, TP.HCM',
        'customerType': 'vip',
        'totalSpent': 5200000.0,
        'visitCount': 28,
        'loyaltyPoints': 520,
        'membershipLevel': 'diamond',
        'discountPercent': 15.0,
        'notes': 'Khách VIP, luôn đặt tiệc cho công ty',
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'lastVisit': Timestamp.now(),
      },
      {
        'fullName': 'Lê Minh Cường',
        'phone': '0923456789',
        'email': 'cuong.le@email.com',
        'address': '789 Đường DEF, Quận 3, TP.HCM',
        'customerType': 'regular',
        'totalSpent': 1200000.0,
        'visitCount': 8,
        'loyaltyPoints': 120,
        'membershipLevel': 'silver',
        'discountPercent': 5.0,
        'notes': 'Thích món chay, hay đặt combo family',
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'lastVisit': Timestamp.now(),
      },
      {
        'fullName': 'Phạm Thị Dung',
        'phone': '0934567890',
        'email': 'dung.pham@email.com',
        'address': '321 Đường GHI, Quận 4, TP.HCM',
        'customerType': 'regular',
        'totalSpent': 650000.0,
        'visitCount': 5,
        'loyaltyPoints': 65,
        'membershipLevel': 'bronze',
        'discountPercent': 0.0,
        'notes': 'Khách mới, hay gọi món nước',
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'lastVisit': Timestamp.now(),
      },
      {
        'fullName': 'Hoàng Văn Ém',
        'phone': '0945678901',
        'email': null,
        'address': '654 Đường JKL, Quận 5, TP.HCM',
        'customerType': 'regular',
        'totalSpent': 320000.0,
        'visitCount': 3,
        'loyaltyPoints': 32,
        'membershipLevel': 'bronze',
        'discountPercent': 0.0,
        'notes': 'Khách hàng mới tham gia',
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'lastVisit': Timestamp.now(),
      },
    ];

    try {
      for (var customerData in customers) {
        await firestore.collection('customers').add(customerData);
        print('Added customer: ${customerData['fullName']}');
      }
      print('✅ All sample customers added successfully!');
    } catch (e) {
      print('❌ Error adding customers: $e');
    }
  }
}
