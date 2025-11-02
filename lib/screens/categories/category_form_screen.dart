import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';

class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.categoryId != null) {
      _loadCategory();
    }
  }

  void _loadCategory() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId!)
          .get();

      if (doc.exists) {
        final category = CategoryModel.fromFirestore(doc);
        _nameController.text = category.name;
        _descriptionController.text = category.description;
        _isActive = category.isActive;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải danh mục: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.categoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa danh mục' : 'Thêm danh mục'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCategory,
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
                    // Tên danh mục
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autocorrect: true,
                      enableSuggestions: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tên danh mục *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                        hintText: 'VD: Món Nướng (dd→đ), Nước uống (oo→ô)...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên danh mục';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Mô tả
                    TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      autocorrect: true,
                      enableSuggestions: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Mô tả về danh mục... (hỗ trợ Telex: dd→đ)',
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Trạng thái
                    SwitchListTile(
                      title: const Text('Danh mục hoạt động'),
                      subtitle: Text(
                        _isActive ? 'Khách hàng có thể xem' : 'Ẩn danh mục',
                      ),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),

                    const SizedBox(height: 24),

                    // Nút lưu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              isEdit ? 'Cập nhật danh mục' : 'Thêm danh mục',
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Gợi ý danh mục phổ biến
                    if (!isEdit) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Gợi ý danh mục phổ biến:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSuggestionChip(
                            'Món Nướng',
                            'Các món nướng than hoa thơm ngon',
                          ),
                          _buildSuggestionChip(
                            'Món Nước',
                            'Canh, soup, lẩu các loại',
                          ),
                          _buildSuggestionChip(
                            'Tráng Miệng',
                            'Kem, chè, trái cây',
                          ),
                          _buildSuggestionChip(
                            'Đồ Uống',
                            'Nước ngọt, trà, cà phê',
                          ),
                          _buildSuggestionChip(
                            'Khai Vị',
                            'Các món ăn trước bữa chính',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSuggestionChip(String name, String description) {
    return ActionChip(
      label: Text(name),
      onPressed: () {
        _nameController.text = name;
        _descriptionController.text = description;
      },
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoryData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'isActive': _isActive,
        'icon': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.categoryId != null) {
        // Cập nhật danh mục
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId!)
            .update(categoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật danh mục thành công!')),
        );
      } else {
        // Thêm danh mục mới
        categoryData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('categories')
            .add(categoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm danh mục thành công!')),
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

  void _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa danh mục này?\n\nChú ý: Các món ăn trong danh mục này sẽ không hiển thị chính xác.',
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
            .collection('categories')
            .doc(widget.categoryId!)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa danh mục thành công!')),
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
    _descriptionController.dispose();
    super.dispose();
  }
}
