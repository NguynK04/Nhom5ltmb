import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/payment_service.dart';
import '../../models/invoice_model.dart';

class PaymentScreen extends StatefulWidget {
  final InvoiceModel invoice;
  final Function(PaymentResult) onPaymentComplete;

  const PaymentScreen({
    super.key,
    required this.invoice,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = PaymentService.CASH;
  bool _isProcessing = false;
  String? _qrCodeData;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  void _generateQRCode() {
    _qrCodeData = PaymentService.generateQRCodeData(
      invoice: widget.invoice,
      paymentMethod: _selectedPaymentMethod,
    );
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      PaymentResult result;

      switch (_selectedPaymentMethod) {
        case PaymentService.CASH:
          result = await PaymentService.processCashPayment(
            amount: widget.invoice.totalAmount,
            orderId: widget.invoice.invoiceNumber,
          );
          break;

        case PaymentService.CARD:
          result = await PaymentService.processCardPayment(
            amount: widget.invoice.totalAmount,
            orderId: widget.invoice.invoiceNumber,
          );
          break;

        case PaymentService.VNPAY:
          result = await PaymentService.processVNPayPayment(
            amount: widget.invoice.totalAmount,
            orderInfo: 'Thanh toán hóa đơn ${widget.invoice.invoiceNumber}',
            orderId: widget.invoice.invoiceNumber,
          );
          break;

        case PaymentService.BANK_TRANSFER:
          result = await PaymentService.processBankTransferPayment(
            amount: widget.invoice.totalAmount,
            orderId: widget.invoice.invoiceNumber,
          );
          break;

        case PaymentService.QR_CODE:
          // QR Code payment - wait for confirmation
          result = await _showQRPaymentDialog();
          break;

        default:
          result = PaymentResult(
            success: false,
            message: 'Phương thức thanh toán không hỗ trợ',
            paymentMethod: _selectedPaymentMethod,
          );
      }

      widget.onPaymentComplete(result);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<PaymentResult> _showQRPaymentDialog() async {
    return await showDialog<PaymentResult>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _QRPaymentDialog(
            qrCodeData: _qrCodeData!,
            invoice: widget.invoice,
          ),
        ) ??
        PaymentResult(
          success: false,
          message: 'Thanh toán QR bị hủy',
          paymentMethod: PaymentService.QR_CODE,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '💳 Thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Invoice Summary
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🧾 Hóa đơn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${widget.invoice.invoiceNumber}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.invoice.customerName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(widget.invoice.customerName!),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng tiền:', style: TextStyle(fontSize: 16)),
                    Text(
                      '₫${widget.invoice.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment Methods
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💳 Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: PaymentService.getAllPaymentMethods().length,
                      itemBuilder: (context, index) {
                        final method =
                            PaymentService.getAllPaymentMethods()[index];
                        return _buildPaymentMethodTile(method);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Process Payment Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang xử lý...'),
                      ],
                    )
                  : Text(
                      'Thanh toán ₫${widget.invoice.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? method.color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? method.color.withOpacity(0.05) : Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: method.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(method.icon, color: method.color, size: 24),
        ),
        title: Text(
          method.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? method.color : Colors.black87,
          ),
        ),
        subtitle: Text(
          method.description,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Radio<String>(
          value: method.id,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
              _generateQRCode(); // Regenerate QR when method changes
            });
          },
          activeColor: method.color,
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.id;
            _generateQRCode();
          });
        },
      ),
    );
  }
}

// QR Payment Dialog
class _QRPaymentDialog extends StatefulWidget {
  final String qrCodeData;
  final InvoiceModel invoice;

  const _QRPaymentDialog({required this.qrCodeData, required this.invoice});

  @override
  State<_QRPaymentDialog> createState() => _QRPaymentDialogState();
}

class _QRPaymentDialogState extends State<_QRPaymentDialog> {
  bool _isWaiting = true;

  @override
  void initState() {
    super.initState();
    // Simulate QR scan waiting time
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isWaiting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📱 Quét mã QR để thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: QrImageView(
              data: widget.qrCodeData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Hóa đơn: #${widget.invoice.invoiceNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Số tiền: ₫${widget.invoice.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          if (_isWaiting) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text(
              'Đang chờ khách hàng quét mã...',
              style: TextStyle(color: Colors.grey),
            ),
          ] else ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Có thể hoàn tất thanh toán',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              PaymentResult(
                success: false,
                message: 'Thanh toán QR bị hủy',
                paymentMethod: PaymentService.QR_CODE,
              ),
            );
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isWaiting
              ? null
              : () {
                  Navigator.of(context).pop(
                    PaymentResult(
                      success: true,
                      message: 'Thanh toán QR thành công',
                      transactionId:
                          'QR_${DateTime.now().millisecondsSinceEpoch}',
                      paymentMethod: PaymentService.QR_CODE,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hoàn tất'),
        ),
      ],
    );
  }
}
