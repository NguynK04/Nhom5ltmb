import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  final _discountController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<CategoryModel> _categories = [];
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _unitController.text = 'phần';
    _stockController.text = '50';
    _initializeData();
  }

  void _initializeData() async {
    // Load categories first
    await _loadCategories();

    // Then load product data if editing
    if (widget.productId != null) {
      await _loadProduct();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();

      setState(() {
        final categoryList = snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList();

        // Remove duplicates based on ID
        final Map<String, CategoryModel> categoryMap = {};
        for (final category in categoryList) {
          categoryMap[category.id] = category;
        }
        _categories = categoryMap.values.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải danh mục: $e')));
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId!)
          .get();

      if (doc.exists) {
        final product = ProductModel.fromFirestore(doc);
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _priceController.text = product.price.toString();
        _stockController.text = product.stock.toString();
        _unitController.text = product.unit;
        _discountController.text = (product.discount ?? 0).toString();

        // Validate category exists in current categories list
        final categoryExists = _categories.any(
          (cat) => cat.id == product.categoryId,
        );
        if (categoryExists) {
          _selectedCategoryId = product.categoryId;
          _selectedCategoryName = product.categoryName;
        } else {
          // If category doesn't exist, reset to null so user must select new one
          _selectedCategoryId = null;
          _selectedCategoryName = null;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Danh mục của món ăn này không còn tồn tại. Vui lòng chọn danh mục mới.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        _isActive = product.isActive;
        _isFeatured = product.isFeatured;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải món ăn: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa món ăn' : 'Thêm món ăn'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
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
                    // Tên món ăn
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autocorrect: true,
                      enableSuggestions: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tên món ăn *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                        hintText: 'VD: Phở bò (dd→đ, oo→ô)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên món ăn';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Danh mục
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final selectedCategory = _categories.firstWhere(
                          (cat) => cat.id == value,
                        );
                        setState(() {
                          _selectedCategoryId = value;
                          _selectedCategoryName = selectedCategory.name;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn danh mục';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Giá
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Giá (VNĐ) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffix: Text('đ'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập giá';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Giá không hợp lệ';
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
                        hintText:
                            'Mô tả chi tiết món ăn... (hỗ trợ Telex: dd→đ)',
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Số lượng và đơn vị
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nhập số lượng';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Số không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nhập đơn vị';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Giảm giá
                    TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Giảm giá (%)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        suffix: Text('%'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null ||
                              discount < 0 ||
                              discount > 100) {
                            return 'Giảm giá từ 0-100%';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Trạng thái
                    SwitchListTile(
                      title: const Text('Món ăn đang bán'),
                      subtitle: Text(
                        _isActive ? 'Khách hàng có thể đặt' : 'Tạm ngừng bán',
                      ),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),

                    SwitchListTile(
                      title: const Text('Món nổi bật'),
                      subtitle: Text(
                        _isFeatured
                            ? 'Hiển thị ở trang chủ'
                            : 'Món ăn bình thường',
                      ),
                      value: _isFeatured,
                      onChanged: (value) => setState(() => _isFeatured = value),
                    ),

                    const SizedBox(height: 24),

                    // Nút lưu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(isEdit ? 'Cập nhật món ăn' : 'Thêm món ăn'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'categoryId': _selectedCategoryId!,
        'categoryName': _selectedCategoryName!,
        'image': null,
        'stock': int.parse(_stockController.text),
        'unit': _unitController.text.trim(),
        'isActive': _isActive,
        'isFeatured': _isFeatured,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.productId != null) {
        // Cập nhật món ăn
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId!)
            .update(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật món ăn thành công!')),
        );
      } else {
        // Thêm món ăn mới
        productData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm món ăn thành công!')),
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

  void _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa món ăn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId!)
            .delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Xóa món ăn thành công!')));
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
    _priceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}
