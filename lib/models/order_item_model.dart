class OrderItemModel {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double subtotal;
  final String? notes;

  OrderItemModel({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.notes,
  });

  // From Map
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'notes': notes,
    };
  }

  // CopyWith
  OrderItemModel copyWith({
    String? productId,
    String? productName,
    String? productImage,
    int? quantity,
    double? price,
    double? subtotal,
    String? notes,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
    );
  }

  // Calculate subtotal
  static double calculateSubtotal(int quantity, double price) {
    return quantity * price;
  }
}
