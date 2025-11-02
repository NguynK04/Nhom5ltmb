import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartDebugScreen extends StatelessWidget {
  const CartDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Debug Giỏ hàng'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Stats
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Thống kê giỏ hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Số lượng sản phẩm: ${cartProvider.items.length}'),
                        Text('Tổng số lượng: ${cartProvider.totalQuantity}'),
                        Text(
                          'Tổng tiền: ₫${cartProvider.totalAmount.toStringAsFixed(0)}',
                        ),
                        Text(
                          'Thuế VAT (${(cartProvider.taxRate * 100).toInt()}%): ₫${cartProvider.taxAmount.toStringAsFixed(0)}',
                        ),
                        Text(
                          'Thành tiền: ₫${cartProvider.finalAmount.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cart Items
                const Text(
                  '🛍️ Danh sách sản phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (cartProvider.items.isEmpty) ...[
                  Card(
                    color: Colors.red.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Giỏ hàng trống',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  ...cartProvider.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${item.productId}'),
                            Text('Giá: ₫${item.price.toStringAsFixed(0)}'),
                            Text('Số lượng: ${item.quantity}'),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Text('Ghi chú: ${item.notes}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₫${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Add a test item
                          cartProvider.addTestItem();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm item test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: cartProvider.items.isNotEmpty
                            ? () {
                                cartProvider.clearCart();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '🗑️ Đã xóa toàn bộ giỏ hàng',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.clear),
                        label: const Text('Xóa tất cả'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/orders/create');
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Đi tới tạo đơn hàng'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
