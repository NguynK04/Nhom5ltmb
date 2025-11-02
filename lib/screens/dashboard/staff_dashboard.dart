import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:korderr/providers/auth_provider.dart';
import 'package:korderr/config/routes.dart';
import 'package:korderr/core/utils/helpers.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Nhân viên'),
        automaticallyImplyLeading: true,
        actions: [
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
                      'Xin chào, ${authProvider.currentUser?.fullName ?? "Nhân viên"}!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bắt đầu ngày làm việc mới',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.add_shopping_cart,
                  label: 'Tạo đơn mới',
                  color: Theme.of(context).primaryColor,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.createOrder),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.restaurant_menu,
                  label: 'Menu',
                  color: const Color(0xFF1B5E5E),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.productList),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.people,
                  label: 'Khách hàng',
                  color: Colors.purple,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.customerList),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.shopping_cart,
                  label: 'Giỏ hàng',
                  color: Colors.green,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
