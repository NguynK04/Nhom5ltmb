import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/customer_model.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../models/invoice_model.dart';
import '../../services/database_service.dart';
import '../../services/payment_service.dart';
import '../payment/payment_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? orderCode;

  const CreateOrderScreen({super.key, this.orderCode});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderCodeController = TextEditingController();
  final _customerSearchController = TextEditingController();

  CustomerModel? _selectedCustomer;
  List<CustomerModel> _searchResults = [];
  bool _isLoading = false;
  String _selectedPaymentMethod = PaymentService.CASH;

  @override
  void initState() {
    super.initState();
    // Tự động điền mã đơn hàng nếu được truyền từ giỏ hàng
    if (widget.orderCode != null) {
      _orderCodeController.text = widget.orderCode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng mới'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order code input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Nhập mã đơn hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nhập mã đơn hàng được tạo từ việc chọn món trong thực đơn',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orderCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Mã đơn hàng',
                          hintText: 'VD: ORD12345678',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã đơn hàng';
                          }
                          if (!value.startsWith('ORD')) {
                            return 'Mã đơn hàng phải bắt đầu bằng ORD';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Chọn khách hàng (tùy chọn)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tìm kiếm khách hàng để áp dụng ưu đãi thành viên',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      if (_selectedCustomer != null) ...[
                        // Selected customer display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getMembershipColor(
                                  _selectedCustomer!.membershipLevel,
                                ),
                                child: Text(
                                  CustomerModel.getMembershipColor(
                                    _selectedCustomer!.membershipLevel,
                                  ),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedCustomer!.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('📱 ${_selectedCustomer!.phone}'),
                                    Text(
                                      '${CustomerModel.getMembershipColor(_selectedCustomer!.membershipLevel)} ${CustomerModel.getMembershipDisplayName(_selectedCustomer!.membershipLevel)} • ${_selectedCustomer!.loyaltyPoints} điểm',
                                    ),
                                    if (_selectedCustomer!.discountPercent > 0)
                                      Text(
                                        'Giảm giá: ${_selectedCustomer!.discountPercent.toInt()}%',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _selectedCustomer = null),
                                icon: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Customer search
                        TextFormField(
                          controller: _customerSearchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          autocorrect: true,
                          enableSuggestions: true,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Tìm khách hàng',
                            hintText: 'Nhập tên (dd→đ) hoặc số điện thoại',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: _searchCustomers,
                        ),

                        if (_searchResults.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final customer = _searchResults[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getMembershipColor(
                                      customer.membershipLevel,
                                    ),
                                    child: Text(
                                      CustomerModel.getMembershipColor(
                                        customer.membershipLevel,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  title: Text(customer.fullName),
                                  subtitle: Text(
                                    '📱 ${customer.phone} • ${customer.loyaltyPoints} điểm',
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedCustomer = customer;
                                      _searchResults.clear();
                                      _customerSearchController.clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order summary (if has cart items)
              if (cartProvider.items.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '3. Tóm tắt đơn hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...cartProvider.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(item.productName)),
                                Text('x${item.quantity}'),
                                const SizedBox(width: 16),
                                Text('₫${item.subtotal.toStringAsFixed(0)}'),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tạm tính:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₫${cartProvider.totalAmount.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                        if (_selectedCustomer?.discountPercent != null &&
                            _selectedCustomer!.discountPercent > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giảm giá (${_selectedCustomer!.discountPercent.toInt()}%):',
                              ),
                              Text(
                                '-₫${(cartProvider.totalAmount * _selectedCustomer!.discountPercent / 100).toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thuế VAT (${(cartProvider.taxRate * 100).toInt()}%):',
                            ),
                            Text(
                              '₫${cartProvider.taxAmount.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₫${_calculateFinalAmount().toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Debug info
              if (cartProvider.items.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Giỏ hàng: ${cartProvider.items.length} món (${cartProvider.totalQuantity} sản phẩm)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...cartProvider.items
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${item.productName} x${item.quantity} = ₫${item.subtotal.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ),
                      if (cartProvider.items.length > 3)
                        Text(
                          '... và ${cartProvider.items.length - 3} món khác',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

              // Cart empty warning
              if (cartProvider.items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '⚠️ Giỏ hàng trống!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Vui lòng thêm sản phẩm vào giỏ hàng trước khi tạo đơn',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/products'),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Đi đến Menu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              // Create order button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Tạo đơn hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMembershipColor(String level) {
    switch (level) {
      case 'diamond':
        return Colors.cyan;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
      default:
        return Colors.brown;
    }
  }

  void _searchCustomers(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults.clear());
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('isActive', isEqualTo: true)
          .get();

      final results = snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .where(
            (customer) =>
                customer.fullName.toLowerCase().contains(query.toLowerCase()) ||
                customer.phone.contains(query),
          )
          .take(5)
          .toList();

      setState(() => _searchResults = results);
    } catch (e) {
      print('Error searching customers: $e');
    }
  }

  double _calculateFinalAmount() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    double total = cartProvider.totalAmount;

    // Debug: In thông tin giỏ hàng
    debugPrint('=== CALCULATE FINAL AMOUNT DEBUG ===');
    debugPrint('Cart items count: ${cartProvider.items.length}');
    debugPrint('Cart totalAmount: $total');
    debugPrint('Cart taxRate: ${cartProvider.taxRate}');

    if (total <= 0) {
      debugPrint('⚠️ WARNING: Cart total is 0 or negative!');
      // Tính lại total từ items
      total = cartProvider.items.fold(0.0, (sum, item) => sum + item.subtotal);
      debugPrint('Recalculated total from items: $total');
    }

    // Áp dụng discount nếu có
    double discountAmount = 0;
    if (_selectedCustomer?.discountPercent != null &&
        _selectedCustomer!.discountPercent > 0) {
      discountAmount = total * (_selectedCustomer!.discountPercent / 100);
      total = total - discountAmount;
      debugPrint(
        'Applied discount: ${_selectedCustomer!.discountPercent}% = ₫$discountAmount',
      );
    }

    // Áp dụng thuế
    double finalAmount = total + (total * cartProvider.taxRate);
    debugPrint('Final amount: ₫$finalAmount');
    debugPrint('===================================');

    return finalAmount;
  }

  void _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderCode = _orderCodeController.text.trim();

      // CartProvider đã sử dụng OrderItemModel, không cần chuyển đổi
      final orderItems = List<OrderItemModel>.from(cartProvider.items);

      final finalAmount = _calculateFinalAmount();

      // Kiểm tra cart không trống và có tổng tiền
      if (cartProvider.items.isEmpty) {
        throw Exception(
          'Giỏ hàng trống! Vui lòng thêm sản phẩm trước khi tạo đơn hàng.',
        );
      }

      if (finalAmount <= 0) {
        throw Exception(
          'Tổng tiền không hợp lệ! Vui lòng kiểm tra lại giỏ hàng.',
        );
      }

      // Tạo OrderModel
      final order = OrderModel(
        id: '',
        orderNumber: orderCode,
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.fullName,
        staffId: 'current_staff_id', // TODO: Lấy từ AuthProvider
        staffName: 'Current Staff', // TODO: Lấy từ AuthProvider
        tableNumber: null,
        items: orderItems,
        totalAmount: cartProvider.totalAmount > 0
            ? cartProvider.totalAmount
            : finalAmount,
        discount: _selectedCustomer?.discountPercent != null
            ? cartProvider.totalAmount *
                  (_selectedCustomer!.discountPercent / 100)
            : 0.0,
        tax: cartProvider.taxAmount,
        finalAmount: finalAmount,
        paymentMethod: _selectedPaymentMethod,
        status: 'pending',
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sử dụng DatabaseService để tạo đơn hàng và hóa đơn
      final orderId = await DatabaseService.createOrder(order);

      // Lấy hóa đơn vừa tạo để chuyển sang thanh toán
      final invoiceSnapshot = await FirebaseFirestore.instance
          .collection('invoices')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (invoiceSnapshot.docs.isNotEmpty && mounted) {
        final invoice = InvoiceModel.fromFirestore(invoiceSnapshot.docs.first);

        // Chuyển sang màn hình thanh toán
        final paymentResult = await Navigator.push<PaymentResult>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              invoice: invoice,
              onPaymentComplete: (result) {
                Navigator.pop(context, result);
              },
            ),
          ),
        );

        // Xử lý kết quả thanh toán
        if (paymentResult != null && paymentResult.success) {
          // Cập nhật payment method trong database
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({
                'paymentMethod': paymentResult.paymentMethod,
                'status': 'completed',
                'updatedAt': FieldValue.serverTimestamp(),
              });

          // Cập nhật invoice
          await FirebaseFirestore.instance
              .collection('invoices')
              .doc(invoice.id)
              .update({
                'paymentMethod': paymentResult.paymentMethod,
                'status': 'paid',
                'updatedAt': FieldValue.serverTimestamp(),
              });

          // Clear cart and form sau khi thanh toán thành công
          cartProvider.clearCart();
          _orderCodeController.clear();
          setState(() => _selectedCustomer = null);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ ${paymentResult.message}\n'
                  'Đơn hàng #$orderCode - ₫${finalAmount.toStringAsFixed(0)}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context); // Quay về màn hình trước
          }
        } else if (paymentResult != null) {
          // Thanh toán thất bại
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${paymentResult.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        throw Exception('Không thể tạo hóa đơn để thanh toán');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi tạo đơn hàng: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _orderCodeController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }
}
