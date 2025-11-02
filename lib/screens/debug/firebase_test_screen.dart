import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _result = 'Chưa test';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testCategories,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Categories'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testProducts,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Products'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addTestCategory,
              child: const Text('Add Test Category'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addTestProduct,
              child: const Text('Add Test Product'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addTestCustomers,
              child: const Text('Add Test Customers'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCustomers,
              child: const Text('Test Customers'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testCategories() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing categories...';
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      final result = StringBuffer();
      result.writeln('✅ Categories collection found!');
      result.writeln('📊 Total docs: ${snapshot.docs.length}');
      result.writeln('');

      for (var doc in snapshot.docs) {
        result.writeln('📁 Doc ID: ${doc.id}');
        result.writeln('📄 Data: ${doc.data()}');
        result.writeln('---');
      }

      setState(() => _result = result.toString());
    } catch (e) {
      setState(() => _result = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _testProducts() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing products...';
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      final result = StringBuffer();
      result.writeln('✅ Products collection found!');
      result.writeln('📊 Total docs: ${snapshot.docs.length}');
      result.writeln('');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        result.writeln('🍔 Doc ID: ${doc.id}');
        result.writeln('📛 Name: ${data['name']}');
        result.writeln('💰 Price: ${data['price']}');
        result.writeln('📁 Category: ${data['categoryName']}');
        result.writeln('📄 Full Data: $data');
        result.writeln('---');
      }

      setState(() => _result = result.toString());
    } catch (e) {
      setState(() => _result = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addTestCategory() async {
    setState(() {
      _isLoading = true;
      _result = 'Adding test category...';
    });

    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': 'Test Category ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test category',
        'isActive': true,
        'icon': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _result = '✅ Test category added successfully!');
    } catch (e) {
      setState(() => _result = '❌ Error adding category: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addTestProduct() async {
    setState(() {
      _isLoading = true;
      _result = 'Adding test product...';
    });

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': 'Test Product ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test product',
        'price': 100000.0,
        'categoryId': 'test-category',
        'categoryName': 'Test Category',
        'image': null,
        'stock': 10,
        'unit': 'phần',
        'isActive': true,
        'isFeatured': false,
        'discount': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _result = '✅ Test product added successfully!');
    } catch (e) {
      setState(() => _result = '❌ Error adding product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _testCustomers() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing customers...';
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .get();

      final result = StringBuffer();
      result.writeln('✅ Customers collection found!');
      result.writeln('📊 Total docs: ${snapshot.docs.length}');
      result.writeln('');

      if (snapshot.docs.isNotEmpty) {
        result.writeln('📋 Customer details:');
        for (var doc in snapshot.docs.take(5)) {
          final data = doc.data();
          result.writeln(
            '• ${data['fullName'] ?? 'No name'} - ${data['phone'] ?? 'No phone'}',
          );
          result.writeln(
            '  Membership: ${data['membershipLevel'] ?? 'bronze'} (${data['loyaltyPoints'] ?? 0} points)',
          );
          result.writeln('  Total spent: ${data['totalSpent'] ?? 0}đ');
          result.writeln('');
        }

        if (snapshot.docs.length > 5) {
          result.writeln('... and ${snapshot.docs.length - 5} more customers');
        }
      } else {
        result.writeln('No customers found. Add some test customers first.');
      }

      setState(() => _result = result.toString());
    } catch (e) {
      setState(() => _result = '❌ Error testing customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addTestCustomers() async {
    setState(() {
      _isLoading = true;
      _result = 'Adding test customers...';
    });

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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastVisit': FieldValue.serverTimestamp(),
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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastVisit': FieldValue.serverTimestamp(),
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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastVisit': FieldValue.serverTimestamp(),
      },
    ];

    try {
      final result = StringBuffer();
      for (var customerData in customers) {
        await FirebaseFirestore.instance
            .collection('customers')
            .add(customerData);
        result.writeln('Added customer: ${customerData['fullName']}');
      }
      result.writeln('\n✅ All test customers added successfully!');
      setState(() => _result = result.toString());
    } catch (e) {
      setState(() => _result = '❌ Error adding customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
