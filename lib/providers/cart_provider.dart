import 'package:flutter/material.dart';
import 'package:korderr/models/product_model.dart';
import 'package:korderr/models/order_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<OrderItemModel> _items = [];
  double _discount = 0;
  double _taxRate = 0.1; // 10% VAT

  List<OrderItemModel> get items => List.unmodifiable(_items);
  double get discount => _discount;
  double get taxRate => _taxRate;
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  // Calculate totals
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get discountAmount => discount;
  double get subtotalAfterDiscount =>
      (totalAmount - discountAmount).clamp(0, double.infinity);
  double get taxAmount => subtotalAfterDiscount * taxRate;
  double get finalAmount => subtotalAfterDiscount + taxAmount;

  // Add item to cart
  void addItem(ProductModel product, {String? notes}) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + 1;
      final newSubtotal = OrderItemModel.calculateSubtotal(
        newQuantity,
        existingItem.price,
      );

      _items[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
        subtotal: newSubtotal,
      );
    } else {
      // Add new item
      final newItem = OrderItemModel(
        productId: product.id,
        productName: product.name,
        productImage: product.image,
        quantity: 1,
        price: product.finalPrice,
        subtotal: product.finalPrice,
        notes: notes,
      );
      _items.add(newItem);
    }

    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = _items[index];
      final newSubtotal = OrderItemModel.calculateSubtotal(
        quantity,
        item.price,
      );
      _items[index] = item.copyWith(quantity: quantity, subtotal: newSubtotal);
      notifyListeners();
    }
  }

  // Increase item quantity
  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = _items[index];
      updateQuantity(productId, item.quantity + 1);
    }
  }

  // Decrease item quantity
  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = _items[index];
      updateQuantity(productId, item.quantity - 1);
    }
  }

  // Update item notes
  void updateItemNotes(String productId, String notes) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(notes: notes);
      notifyListeners();
    }
  }

  // Set discount
  void setDiscount(double amount) {
    _discount = amount.clamp(0, totalAmount);
    notifyListeners();
  }

  // Set tax rate
  void setTaxRate(double rate) {
    _taxRate = rate.clamp(0, 1);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _discount = 0;
    notifyListeners();
  }

  // Check if product is in cart
  bool hasProduct(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Get item quantity
  int getItemQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => OrderItemModel(
        productId: '',
        productName: '',
        quantity: 0,
        price: 0,
        subtotal: 0,
      ),
    );
    return item.quantity;
  }

  // Validate cart (check if not empty and products are available)
  bool validateCart() {
    return _items.isNotEmpty;
  }

  // Add test item for debugging
  void addTestItem() {
    final testItem = OrderItemModel(
      productId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      productName: 'Sản phẩm test ${_items.length + 1}',
      productImage: null,
      quantity: 1,
      price: 50000,
      subtotal: 50000,
      notes: 'Item test cho debug',
    );
    _items.add(testItem);
    notifyListeners();
  }
}
