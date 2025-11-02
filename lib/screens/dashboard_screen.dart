import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../models/invoice_model.dart';
import '../models/revenue_model.dart';
import '../models/staff_activity_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardStats;
  List<InvoiceModel> _recentInvoices = [];
  List<StaffActivityModel> _recentActivities = [];
  RevenueModel? _todayRevenue;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      // Load dashboard stats
      final stats = await DatabaseService.getDashboardStats();

      // Load recent invoices
      final invoicesSnapshot = await FirebaseFirestore.instance
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      final recentInvoices = invoicesSnapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();

      // Load recent activities
      final activitiesSnapshot = await FirebaseFirestore.instance
          .collection('staff_activities')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final recentActivities = activitiesSnapshot.docs
          .map((doc) => StaffActivityModel.fromFirestore(doc))
          .toList();

      // Load today's revenue
      final today = DateTime.now();
      final dateKey = RevenueModel.generateDateKey(today);
      final revenueDoc = await FirebaseFirestore.instance
          .collection('revenue')
          .doc(dateKey)
          .get();

      RevenueModel? todayRevenue;
      if (revenueDoc.exists) {
        todayRevenue = RevenueModel.fromFirestore(revenueDoc);
      }

      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _recentInvoices = recentInvoices;
          _recentActivities = recentActivities;
          _todayRevenue = todayRevenue;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '📊 Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Overview
                    _buildStatsOverview(),
                    const SizedBox(height: 24),

                    // Today's Revenue
                    _buildTodayRevenue(),
                    const SizedBox(height: 24),

                    // Recent Invoices
                    _buildRecentInvoices(),
                    const SizedBox(height: 24),

                    // Recent Activities
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsOverview() {
    if (_dashboardStats == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📈 Tổng quan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              '📋 Đơn hàng hôm nay',
              '${_dashboardStats!['todayOrders'] ?? 0}',
              Colors.blue,
              Icons.receipt_long,
            ),
            _buildStatCard(
              '💰 Doanh thu hôm nay',
              '₫${(_dashboardStats!['todayRevenue'] ?? 0.0).toStringAsFixed(0)}',
              Colors.green,
              Icons.monetization_on,
            ),
            _buildStatCard(
              '👥 Khách hàng',
              '${_dashboardStats!['totalCustomers'] ?? 0}',
              Colors.orange,
              Icons.people,
            ),
            _buildStatCard(
              '🧾 Hóa đơn',
              '${_dashboardStats!['totalInvoices'] ?? 0}',
              Colors.purple,
              Icons.description,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTodayRevenue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💰 Doanh thu hôm nay',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _todayRevenue == null
              ? const Column(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có doanh thu hôm nay',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng doanh thu:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₫${_todayRevenue!.totalRevenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Đơn hàng'),
                              Text(
                                '${_todayRevenue!.totalOrders}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Khách hàng'),
                              Text(
                                '${_todayRevenue!.totalCustomers}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Trung bình'),
                              Text(
                                '₫${(_todayRevenue!.totalRevenue / (_todayRevenue!.totalOrders > 0 ? _todayRevenue!.totalOrders : 1)).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRecentInvoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🧾 Hóa đơn gần đây',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to invoices list
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _recentInvoices.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có hóa đơn nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                children: _recentInvoices.map((invoice) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hóa đơn #${invoice.invoiceNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                invoice.customerName ?? 'Khách vãng lai',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₫${invoice.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '${invoice.createdAt.day}/${invoice.createdAt.month}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Hoạt động gần đây',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),
        _recentActivities.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có hoạt động nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentActivities.length > 5
                      ? 5
                      : _recentActivities.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final activity = _recentActivities[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getActivityColor(
                          activity.action,
                        ).withOpacity(0.1),
                        child: Icon(
                          _getActivityIcon(activity.action),
                          color: _getActivityColor(activity.action),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getActivityDescription(activity.action),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        activity.staffName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '${activity.timestamp.hour}:${activity.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  IconData _getActivityIcon(String action) {
    switch (action) {
      case StaffActivityModel.ACTION_LOGIN:
        return Icons.login;
      case StaffActivityModel.ACTION_CREATE_ORDER:
        return Icons.add_shopping_cart;
      case StaffActivityModel.ACTION_UPDATE_ORDER:
        return Icons.edit;
      case StaffActivityModel.ACTION_CANCEL_ORDER:
        return Icons.cancel;
      case StaffActivityModel.ACTION_CREATE_CUSTOMER:
        return Icons.person_add;
      case StaffActivityModel.ACTION_UPDATE_CUSTOMER:
        return Icons.person;
      default:
        return Icons.history;
    }
  }

  Color _getActivityColor(String action) {
    switch (action) {
      case StaffActivityModel.ACTION_LOGIN:
        return Colors.green;
      case StaffActivityModel.ACTION_CREATE_ORDER:
        return Colors.blue;
      case StaffActivityModel.ACTION_UPDATE_ORDER:
        return Colors.orange;
      case StaffActivityModel.ACTION_CANCEL_ORDER:
        return Colors.red;
      case StaffActivityModel.ACTION_CREATE_CUSTOMER:
        return Colors.purple;
      case StaffActivityModel.ACTION_UPDATE_CUSTOMER:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getActivityDescription(String action) {
    switch (action) {
      case StaffActivityModel.ACTION_LOGIN:
        return 'Đăng nhập hệ thống';
      case StaffActivityModel.ACTION_CREATE_ORDER:
        return 'Tạo đơn hàng mới';
      case StaffActivityModel.ACTION_UPDATE_ORDER:
        return 'Cập nhật đơn hàng';
      case StaffActivityModel.ACTION_CANCEL_ORDER:
        return 'Hủy đơn hàng';
      case StaffActivityModel.ACTION_CREATE_CUSTOMER:
        return 'Tạo khách hàng mới';
      case StaffActivityModel.ACTION_UPDATE_CUSTOMER:
        return 'Cập nhật khách hàng';
      default:
        return action;
    }
  }
}
