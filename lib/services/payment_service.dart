import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/invoice_model.dart';

class PaymentService {
  static const String vnpayMerchantId = 'DEMO'; // Demo merchant ID
  static const String vnpayAppScheme = 'korderr'; // App scheme for return

  // Payment methods
  static const String CASH = 'cash';
  static const String CARD = 'card';
  static const String VNPAY = 'vnpay';
  static const String QR_CODE = 'qr_code';
  static const String BANK_TRANSFER = 'bank_transfer';

  static List<PaymentMethod> getAllPaymentMethods() {
    return [
      PaymentMethod(
        id: CASH,
        name: 'Tiền mặt',
        icon: Icons.money,
        color: Colors.green,
        description: 'Thanh toán bằng tiền mặt',
      ),
      PaymentMethod(
        id: CARD,
        name: 'Thẻ tín dụng',
        icon: Icons.credit_card,
        color: Colors.blue,
        description: 'Thanh toán bằng thẻ tín dụng/ghi nợ',
      ),
      PaymentMethod(
        id: VNPAY,
        name: 'VNPay',
        icon: Icons.account_balance_wallet,
        color: Colors.red,
        description: 'Thanh toán qua VNPay',
      ),
      PaymentMethod(
        id: QR_CODE,
        name: 'QR Code',
        icon: Icons.qr_code,
        color: Colors.purple,
        description: 'Thanh toán bằng quét mã QR',
      ),
      PaymentMethod(
        id: BANK_TRANSFER,
        name: 'Chuyển khoản',
        icon: Icons.account_balance,
        color: Colors.orange,
        description: 'Chuyển khoản ngân hàng',
      ),
    ];
  }

  // Process VNPay payment (Demo version)
  static Future<PaymentResult> processVNPayPayment({
    required double amount,
    required String orderInfo,
    required String orderId,
  }) async {
    try {
      // Simulate VNPay processing time
      await Future.delayed(const Duration(seconds: 3));

      // Demo: 90% success rate for VNPay
      final isSuccess = DateTime.now().millisecond % 10 < 9;

      if (isSuccess) {
        return PaymentResult(
          success: true,
          message: 'Thanh toán VNPay thành công (Demo)',
          transactionId: 'VNP_${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: VNPAY,
          metadata: {
            'demo_mode': true,
            'amount': amount,
            'order_info': orderInfo,
          },
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'Thanh toán VNPay thất bại - Thử lại',
          paymentMethod: VNPAY,
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Lỗi thanh toán VNPay: $e',
        paymentMethod: VNPAY,
      );
    }
  }

  // Generate QR Code for payment
  static String generateQRCodeData({
    required InvoiceModel invoice,
    required String paymentMethod,
  }) {
    final qrData = {
      'type': 'payment',
      'invoiceId': invoice.id,
      'invoiceNumber': invoice.invoiceNumber,
      'amount': invoice.totalAmount,
      'customerName': invoice.customerName,
      'paymentMethod': paymentMethod,
      'timestamp': DateTime.now().toIso8601String(),
      'restaurant': 'Korderr Restaurant',
    };

    return jsonEncode(qrData);
  }

  // Process cash payment
  static Future<PaymentResult> processCashPayment({
    required double amount,
    required String orderId,
  }) async {
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));

    return PaymentResult(
      success: true,
      message: 'Thanh toán tiền mặt thành công',
      transactionId: 'CASH_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: CASH,
    );
  }

  // Process card payment (demo)
  static Future<PaymentResult> processCardPayment({
    required double amount,
    required String orderId,
  }) async {
    // Simulate card processing
    await Future.delayed(const Duration(seconds: 3));

    // Demo: 80% success rate
    final isSuccess = DateTime.now().millisecond % 10 < 8;

    if (isSuccess) {
      return PaymentResult(
        success: true,
        message: 'Thanh toán thẻ thành công',
        transactionId: 'CARD_${DateTime.now().millisecondsSinceEpoch}',
        paymentMethod: CARD,
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Thanh toán thẻ thất bại - Thử lại',
        paymentMethod: CARD,
      );
    }
  }

  // Process bank transfer (demo)
  static Future<PaymentResult> processBankTransferPayment({
    required double amount,
    required String orderId,
  }) async {
    // Simulate transfer processing
    await Future.delayed(const Duration(seconds: 2));

    return PaymentResult(
      success: true,
      message: 'Chuyển khoản thành công',
      transactionId: 'BANK_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: BANK_TRANSFER,
    );
  }
}

// Payment Method Model
class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// Payment Result Model
class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;
  final String paymentMethod;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
    required this.paymentMethod,
    this.metadata,
  });

  @override
  String toString() {
    return 'PaymentResult('
        'success: $success, '
        'message: $message, '
        'transactionId: $transactionId, '
        'paymentMethod: $paymentMethod'
        ')';
  }
}
