import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';
import '../../config/routes.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick category buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh mục nhanh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickCategoryButton(
                      'Món chính',
                      Icons.restaurant,
                      Colors.orange,
                      'Các món ăn chính trong thực đơn',
                    ),
                    _buildQuickCategoryButton(
                      'Đồ uống',
                      Icons.local_drink,
                      Colors.blue,
                      'Nước uống, trà, cà phê, nước ép',
                    ),
                    _buildQuickCategoryButton(
                      'Đồ nướng',
                      Icons.outdoor_grill,
                      Colors.red,
                      'Các món nướng BBQ, thịt nướng',
                    ),
                    _buildQuickCategoryButton(
                      'Tráng miệng',
                      Icons.cake,
                      Colors.pink,
                      'Bánh ngọt, kem, chè, trái cây',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Existing categories list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .snapshots(),
              builder: (context, snapshot) {
                print(
                  '🔥 CategoryList - ConnectionState: ${snapshot.connectionState}',
                );
                print('🔥 CategoryList - HasData: ${snapshot.hasData}');
                print('🔥 CategoryList - HasError: ${snapshot.hasError}');
                if (snapshot.hasError) {
                  print('🔥 CategoryList - Error: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  print(
                    '🔥 CategoryList - Docs count: ${snapshot.data!.docs.length}',
                  );
                  for (var doc in snapshot.data!.docs) {
                    print(
                      '🔥 CategoryList - Doc ID: ${doc.id}, Data: ${doc.data()}',
                    );
                  }
                }

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

                final categories = <CategoryModel>[];
                try {
                  final docs = snapshot.data?.docs ?? [];
                  for (var doc in docs) {
                    print('🔥 Processing doc: ${doc.id}');
                    final category = CategoryModel.fromFirestore(doc);
                    categories.add(category);
                    print('🔥 Added category: ${category.name}');
                  }
                } catch (e) {
                  print('🔥 Error processing categories: $e');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi xử lý dữ liệu: $e'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có danh mục nào',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Nhấn nút + để thêm danh mục đầu tiên'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _addCategory(),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm danh mục'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category.isActive
                              ? Colors.green
                              : Colors.grey,
                          child: Icon(Icons.category, color: Colors.white),
                        ),
                        title: Text(
                          category.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: category.isActive ? null : Colors.grey,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (category.description.isNotEmpty)
                              Text(category.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  category.isActive
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 16,
                                  color: category.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category.isActive ? 'Hoạt động' : 'Tạm ẩn',
                                  style: TextStyle(
                                    color: category.isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                              _editCategory(category.id);
                            } else if (value == 'delete') {
                              _deleteCategory(category);
                            }
                          },
                        ),
                        onTap: () => _editCategory(category.id),
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
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickCategoryButton(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _addQuickCategory(title, description, icon, color),
      icon: Icon(icon, size: 18),
      label: Text(title, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _addQuickCategory(
    String name,
    String description,
    IconData icon,
    Color color,
  ) async {
    try {
      // Check if category already exists
      final existingCategory = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: name)
          .get();

      if (existingCategory.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Danh mục "$name" đã tồn tại!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final newCategory = CategoryModel(
        id: '',
        name: name,
        description: description,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('categories')
          .add(newCategory.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm danh mục "$name" thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thêm danh mục: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addCategory() {
    Navigator.pushNamed(context, AppRoutes.categoryForm);
  }

  void _editCategory(String categoryId) {
    Navigator.pushNamed(context, AppRoutes.categoryForm, arguments: categoryId);
  }

  void _deleteCategory(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa danh mục "${category.name}"?\n\nCác món ăn trong danh mục này sẽ không hiển thị chính xác.',
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
            .collection('categories')
            .doc(category.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa danh mục thành công!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi xóa danh mục: $e')));
      }
    }
  }
}
