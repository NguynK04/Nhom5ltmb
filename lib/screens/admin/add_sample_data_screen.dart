import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korderr/services/sample_data_service.dart';
import 'package:korderr/core/utils/helpers.dart';

class AddSampleDataScreen extends StatefulWidget {
  const AddSampleDataScreen({super.key});

  @override
  State<AddSampleDataScreen> createState() => _AddSampleDataScreenState();
}

class _AddSampleDataScreenState extends State<AddSampleDataScreen> {
  final SampleDataService _sampleDataService = SampleDataService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Dữ Liệu Mẫu'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🍽️ Thêm Thực Đơn Mẫu',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tính năng này sẽ thêm:\n'
                      '• 3 danh mục món ăn\n'
                      '• 20 món ăn đa dạng với đầy đủ thông tin\n'
                      '• Giá cả và mô tả chi tiết\n'
                      '• Một số món có khuyến mãi',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_statusMessage.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_statusMessage),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addSampleData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restaurant_menu),
              label: Text(
                _isLoading ? 'Đang thêm dữ liệu...' : 'Thêm Dữ Liệu Mẫu',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _checkExistingData,
              icon: const Icon(Icons.search),
              label: const Text('Kiểm Tra Dữ Liệu Hiện Tại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Xóa Tất Cả Dữ Liệu'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang thêm dữ liệu mẫu...';
    });

    try {
      await _sampleDataService.addSampleData();

      setState(() {
        _statusMessage = '✅ Thành công! Đã thêm 3 danh mục và 20 món ăn.';
      });

      if (mounted) {
        Helpers.showSuccess(context, 'Thêm dữ liệu thành công!');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi: ${e.toString()}';
      });

      if (mounted) {
        Helpers.showError(context, 'Lỗi thêm dữ liệu: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkExistingData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra dữ liệu...';
    });

    try {
      // Đếm categories
      final categoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      // Đếm products
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      setState(() {
        _statusMessage =
            '📊 Dữ liệu hiện tại:\n'
            '• Danh mục: ${categoriesSnapshot.docs.length}\n'
            '• Món ăn: ${productsSnapshot.docs.length}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi kiểm tra: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Xác nhận xóa',
      message:
          'Bạn có chắc chắn muốn xóa TẤT CẢ dữ liệu không?\nHành động này không thể hoàn tác!',
    );

    if (!confirm) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang xóa dữ liệu...';
    });

    try {
      await _sampleDataService.clearAllData();

      setState(() {
        _statusMessage = '✅ Đã xóa tất cả dữ liệu.';
      });

      if (mounted) {
        Helpers.showSuccess(context, 'Xóa dữ liệu thành công!');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Lỗi xóa: ${e.toString()}';
      });

      if (mounted) {
        Helpers.showError(context, 'Lỗi xóa dữ liệu: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
