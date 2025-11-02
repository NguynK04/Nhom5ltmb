import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:korderr/providers/auth_provider.dart';
import 'package:korderr/config/routes.dart';
import 'package:korderr/core/utils/helpers.dart';
import 'package:korderr/services/database_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await DatabaseService.getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thống kê: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Admin'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await Helpers.showConfirmDialog(
                context,
                title: 'Đăng xuất',
                message: 'Bạn có chắc chắn muốn đăng xuất?',
              );

              if (confirm && context.mounted) {
                await authProvider.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${authProvider.currentUser?.fullName ?? "Admin"}!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng bạn đến với hệ thống quản lý nhà hàng',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Text(
              'Thống kê nhanh',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.attach_money,
                        title: 'Doanh thu hôm nay',
                        value:
                            '₫${(_dashboardStats?['todayRevenue'] ?? 0).toStringAsFixed(0)}',
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.shopping_cart,
                        title: 'Đơn hàng hôm nay',
                        value: '${_dashboardStats?['todayOrders'] ?? 0}',
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.people,
                        title: 'Tổng khách hàng',
                        value: '${_dashboardStats?['totalCustomers'] ?? 0}',
                        color: Colors.purple,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.trending_up,
                        title: 'Xem chi tiết',
                        value: 'Dashboard',
                        color: Colors.indigo,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.dashboard),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Quản lý', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.restaurant_menu,
                  label: 'Menu',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.productList),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.category,
                  label: 'Danh mục',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.categoryList),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Đơn hàng',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.orderList),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.people,
                  label: 'Khách hàng',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.customerList),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.analytics,
                  label: 'Doanh thu',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.dashboard),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.people_alt,
                  label: 'Quản lý NV',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.staffManagement),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.restaurant,
                  label: 'Thêm Menu',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.addSampleData),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.lock_reset,
                  label: 'Quản lý MK',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.passwordManagement),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.bug_report,
                  label: 'Test Firebase',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.firebaseTest),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
