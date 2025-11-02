import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/customer_model.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loyaltyPointsController = TextEditingController();

  String _selectedMembershipLevel = 'bronze';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  void _loadCustomer() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId!)
          .get();

      if (doc.exists) {
        final customer = CustomerModel.fromFirestore(doc);
        _nameController.text = customer.fullName;
        _phoneController.text = customer.phone;
        _loyaltyPointsController.text = customer.loyaltyPoints.toString();
        _selectedMembershipLevel = customer.membershipLevel;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải khách hàng: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa khách hàng' : 'Thêm khách hàng'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCustomer,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tên khách hàng
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên khách hàng *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Nhập tên đầy đủ',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên khách hàng';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: 'Nhập số điện thoại',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (value.length < 10) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Cấp độ thành viên
                    DropdownButtonFormField<String>(
                      value: _selectedMembershipLevel,
                      decoration: const InputDecoration(
                        labelText: 'Cấp độ thành viên',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.card_membership),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'bronze',
                          child: Row(
                            children: [
                              Text('🥉'),
                              const SizedBox(width: 8),
                              const Text('Đồng (0% giảm giá)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'silver',
                          child: Row(
                            children: [
                              Text('🥈'),
                              const SizedBox(width: 8),
                              const Text('Bạc (5% giảm giá)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'gold',
                          child: Row(
                            children: [
                              Text('🥇'),
                              const SizedBox(width: 8),
                              const Text('Vàng (10% giảm giá)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'diamond',
                          child: Row(
                            children: [
                              Text('💎'),
                              const SizedBox(width: 8),
                              const Text('Kim Cương (15% giảm giá)'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedMembershipLevel = value!);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Điểm tích lũy
                    TextFormField(
                      controller: _loyaltyPointsController,
                      decoration: const InputDecoration(
                        labelText: 'Điểm tích lũy',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.stars),
                        hintText: '0',
                        suffix: Text('điểm'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null) {
                            return 'Điểm phải là số';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Thông tin tích điểm
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Hệ thống tích điểm',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('• 🥉 Đồng: < 2 triệu (0% giảm giá)'),
                          const Text('• 🥈 Bạc: 2-5 triệu (5% giảm giá)'),
                          const Text('• 🥇 Vàng: 5-10 triệu (10% giảm giá)'),
                          const Text(
                            '• 💎 Kim cương: > 10 triệu (15% giảm giá)',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Điểm tích lũy: 1 điểm = 1,000đ chi tiêu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nút lưu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              isEdit
                                  ? 'Cập nhật khách hàng'
                                  : 'Thêm khách hàng',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final loyaltyPoints = int.tryParse(_loyaltyPointsController.text) ?? 0;
      final discountPercent = CustomerModel.calculateDiscountPercent(
        _selectedMembershipLevel,
      );

      final customerData = {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'customerType': 'regular',
        'totalSpent': 0.0,
        'visitCount': 0,
        'loyaltyPoints': loyaltyPoints,
        'membershipLevel': _selectedMembershipLevel,
        'lastVisit': null,
        'discountPercent': discountPercent,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.customerId != null) {
        // Cập nhật khách hàng
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId!)
            .update(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật khách hàng thành công!')),
        );
      } else {
        // Thêm khách hàng mới
        customerData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('customers')
            .add(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm khách hàng thành công!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa khách hàng này?\n\nLưu ý: Các đơn hàng liên quan sẽ không hiển thị đúng thông tin khách hàng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId!)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa khách hàng thành công!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _loyaltyPointsController.dispose();
    super.dispose();
  }
}
