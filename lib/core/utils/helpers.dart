import 'package:flutter/material.dart';
import 'package:korderr/core/constants/app_constants.dart';

class Helpers {
  // Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF004E89),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF39C12),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderStatusPending:
        return const Color(0xFFF39C12); // Warning
      case AppConstants.orderStatusPreparing:
        return const Color(0xFF3498DB); // Blue
      case AppConstants.orderStatusReady:
        return const Color(0xFF9B59B6); // Purple
      case AppConstants.orderStatusCompleted:
        return const Color(0xFF2ECC71); // Success
      case AppConstants.orderStatusCancelled:
        return const Color(0xFFE74C3C); // Error
      default:
        return const Color(0xFF7F8C8D); // Gray
    }
  }

  // Get status text
  static String getStatusText(String status) {
    switch (status) {
      case AppConstants.orderStatusPending:
        return 'Chờ xử lý';
      case AppConstants.orderStatusPreparing:
        return 'Đang chuẩn bị';
      case AppConstants.orderStatusReady:
        return 'Sẵn sàng';
      case AppConstants.orderStatusCompleted:
        return 'Hoàn thành';
      case AppConstants.orderStatusCancelled:
        return 'Đã hủy';
      default:
        return status;
    }
  }

  // Get payment method text
  static String getPaymentMethodText(String method) {
    switch (method) {
      case AppConstants.paymentMethodCash:
        return 'Tiền mặt';
      case AppConstants.paymentMethodCard:
        return 'Thẻ';
      case AppConstants.paymentMethodQRCode:
        return 'QR Code';
      case AppConstants.paymentMethodBankTransfer:
        return 'Chuyển khoản';
      default:
        return method;
    }
  }

  // Get customer type text
  static String getCustomerTypeText(String type) {
    switch (type) {
      case AppConstants.customerTypeNew:
        return 'Khách mới';
      case AppConstants.customerTypeRegular:
        return 'Khách quen';
      case AppConstants.customerTypeVIP:
        return 'VIP';
      default:
        return type;
    }
  }

  // Get customer type color
  static Color getCustomerTypeColor(String type) {
    switch (type) {
      case AppConstants.customerTypeNew:
        return const Color(0xFF3498DB); // Blue
      case AppConstants.customerTypeRegular:
        return const Color(0xFF2ECC71); // Green
      case AppConstants.customerTypeVIP:
        return const Color(0xFFFFD700); // Gold
      default:
        return const Color(0xFF7F8C8D); // Gray
    }
  }

  // Check if user has permission
  static bool hasPermission(String userRole, List<String> allowedRoles) {
    return allowedRoles.contains(userRole);
  }

  // Check if user is admin
  static bool isAdmin(String userRole) {
    return userRole == AppConstants.roleAdmin;
  }

  // Check if user is manager or admin
  static bool isManagerOrAdmin(String userRole) {
    return userRole == AppConstants.roleAdmin ||
        userRole == AppConstants.roleManager;
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Determine customer type based on spending and visits
  static String determineCustomerType(double totalSpent, int visitCount) {
    if (totalSpent >= AppConstants.vipCustomerSpendThreshold) {
      return AppConstants.customerTypeVIP;
    } else if (totalSpent >= AppConstants.regularCustomerSpendThreshold ||
        visitCount >= AppConstants.regularCustomerVisitThreshold) {
      return AppConstants.customerTypeRegular;
    } else {
      return AppConstants.customerTypeNew;
    }
  }

  // Show error from exception
  static void showErrorFromException(BuildContext context, dynamic error) {
    String message = AppConstants.msgNetworkError;

    if (error.toString().contains('permission-denied')) {
      message = AppConstants.msgUnauthorized;
    } else if (error.toString().contains('network')) {
      message = AppConstants.msgNetworkError;
    } else {
      message = error.toString();
    }

    showError(context, message);
  }
}
