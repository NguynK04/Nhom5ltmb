import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/customer_model.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khách hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(child: Text('Tìm kiếm: "$_searchQuery"')),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _searchQuery = ''),
                  ),
                ],
              ),
            ),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final customers = snapshot.data!.docs
                    .map((doc) => CustomerModel.fromFirestore(doc))
                    .toList();
                final totalCustomers = customers.length;
                final vipCustomers = customers
                    .where((c) => c.membershipLevel != 'bronze')
                    .length;
                final totalPoints = customers.fold<int>(
                  0,
                  (sum, c) => sum + c.loyaltyPoints,
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Tổng KH',
                      totalCustomers.toString(),
                      Icons.people,
                    ),
                    _buildStatItem(
                      'KH VIP',
                      vipCustomers.toString(),
                      Icons.star,
                    ),
                    _buildStatItem(
                      'Tổng điểm',
                      totalPoints.toString(),
                      Icons.point_of_sale,
                    ),
                  ],
                );
              },
            ),
          ),

          // Customers list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var customers =
                    snapshot.data?.docs
                        .map((doc) => CustomerModel.fromFirestore(doc))
                        .toList() ??
                    [];

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  customers = customers.where((customer) {
                    return customer.fullName.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        customer.phone.contains(_searchQuery);
                  }).toList();
                }

                // Sort by membership level and total spent
                customers.sort((a, b) {
                  final levelOrder = {
                    'diamond': 4,
                    'gold': 3,
                    'silver': 2,
                    'bronze': 1,
                  };
                  final aLevel = levelOrder[a.membershipLevel] ?? 0;
                  final bLevel = levelOrder[b.membershipLevel] ?? 0;

                  if (aLevel != bLevel) return bLevel.compareTo(aLevel);
                  return b.totalSpent.compareTo(a.totalSpent);
                });

                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy khách hàng'
                              : 'Chưa có khách hàng nào',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Thử tìm kiếm với từ khóa khác'
                              : 'Nhấn nút + để thêm khách hàng đầu tiên',
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _addCustomer(),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm khách hàng'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getMembershipColor(
                            customer.membershipLevel,
                          ),
                          child: Text(
                            CustomerModel.getMembershipColor(
                              customer.membershipLevel,
                            ),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (customer.loyaltyPoints > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${customer.loyaltyPoints} điểm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📱 ${customer.phone}'),
                            Row(
                              children: [
                                Text(
                                  '${CustomerModel.getMembershipColor(customer.membershipLevel)} ${CustomerModel.getMembershipDisplayName(customer.membershipLevel)}',
                                ),
                                if (customer.discountPercent > 0) ...[
                                  const Text(' • '),
                                  Text(
                                    '${customer.discountPercent.toInt()}% giảm giá',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (customer.totalSpent > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Đã chi tiêu: ${customer.totalSpent.toStringAsFixed(0)}đ • ${customer.visitCount} lần ghé thăm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Sửa'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editCustomer(customer.id);
                            } else if (value == 'delete') {
                              _deleteCustomer(customer);
                            }
                          },
                        ),
                        onTap: () => _editCustomer(customer.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Color _getMembershipColor(String level) {
    switch (level) {
      case 'diamond':
        return Colors.cyan;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
      default:
        return Colors.brown;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = _searchQuery;
        return AlertDialog(
          title: const Text('Tìm kiếm khách hàng'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Tên hoặc số điện thoại',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => tempQuery = value,
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = tempQuery);
                Navigator.pop(context);
              },
              child: const Text('Tìm'),
            ),
          ],
        );
      },
    );
  }

  void _addCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomerFormScreen()),
    );
  }

  void _editCustomer(String customerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(customerId: customerId),
      ),
    );
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa khách hàng "${customer.fullName}"?\n\nHành động này không thể hoàn tác.',
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
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customer.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa khách hàng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa khách hàng: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
