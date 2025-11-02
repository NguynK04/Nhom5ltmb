import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../widgets/premium_product_card.dart';
import '../../providers/cart_provider.dart';
import '../../config/routes.dart';

class CategorizedMenuScreen extends StatefulWidget {
  const CategorizedMenuScreen({super.key});

  @override
  State<CategorizedMenuScreen> createState() => _CategorizedMenuScreenState();
}

class _CategorizedMenuScreenState extends State<CategorizedMenuScreen> {
  int _selectedIndex = 1; // Mặc định chọn "Đồ Nướng" (index 1 - giữa)
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      // Danh sách danh mục cố định cho quán nướng
      final categories = [
        CategoryModel(
          id: 'dessert',
          name: 'Tráng Miệng',
          description: 'Món tráng miệng ngọt ngào',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: 'grilled',
          name: 'Đồ Nướng',
          description: 'Các món nướng đặc sắc',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: 'drinks',
          name: 'Đồ Uống',
          description: 'Nước uống giải khát',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải danh mục: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Quán Ăn'),
        backgroundColor: const Color(0xFF1B5E5E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          // Cart button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.cart);
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? const Center(child: Text('Không có danh mục nào'))
          : _buildProductGrid(),
      bottomNavigationBar: _categories.isEmpty
          ? null
          : ConvexAppBar(
              style: TabStyle.fixedCircle,
              items: _categories.asMap().entries.map((entry) {
                final category = entry.value;
                IconData icon;
                switch (category.name.toLowerCase()) {
                  case 'tráng miệng':
                    icon = Icons.cake;
                    break;
                  case 'đồ nướng':
                    icon = Icons.outdoor_grill;
                    break;
                  case 'đồ uống':
                    icon = Icons.local_cafe;
                    break;
                  default:
                    icon = Icons.fastfood;
                }
                return TabItem(icon: icon, title: category.name);
              }).toList(),
              initialActiveIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: const Color(0xFF1B5E5E),
              activeColor: Colors.white,
              color: Colors.white70,
              height: 60,
              top: -20,
              cornerRadius: 20,
              curveSize: 80,
            ),
    );
  }

  Widget _buildProductGrid() {
    final selectedCategory = _categories[_selectedIndex];

    return StreamBuilder<QuerySnapshot>(
      stream: selectedCategory.id == 'all'
          ? FirebaseFirestore.instance
                .collection('products')
                .where('isActive', isEqualTo: true)
                .snapshots()
          : FirebaseFirestore.instance
                .collection('products')
                .where('isActive', isEqualTo: true)
                .where('categoryName', isEqualTo: selectedCategory.name)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  selectedCategory.id == 'all'
                      ? 'Chưa có món ăn nào'
                      : 'Chưa có món ăn trong danh mục ${selectedCategory.name}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Debug: Looking for categoryName = "${selectedCategory.name}"',
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Debug: Lấy tất cả sản phẩm để xem có gì
                    final allProducts = await FirebaseFirestore.instance
                        .collection('products')
                        .limit(5)
                        .get();

                    print('=== DEBUG: All products ===');
                    for (var doc in allProducts.docs) {
                      final data = doc.data();
                      print(
                        'Product: ${data['name']} - CategoryName: "${data['categoryName']}" - CategoryId: ${data['categoryId']}',
                      );
                    }
                  },
                  child: const Text(
                    'Debug Products',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();

        return Column(
          children: [
            // Category header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1B5E5E),
                    const Color(0xFF1B5E5E).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategory.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedCategory.id == 'all'
                        ? 'Tổng cộng ${products.length} món ăn'
                        : '${products.length} món ăn trong danh mục',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Products grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return PremiumProductCard(
                      product: product,
                      onAddToCart: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addItem(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã thêm ${product.name} vào giỏ hàng',
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor: const Color(0xFF27AE60),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.productDetail,
                          arguments: product.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
