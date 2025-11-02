import 'package:intl/intl.dart';
import 'package:korderr/core/constants/app_constants.dart';

class Formatters {
  // Format currency (Vietnam Dong)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat(AppConstants.dateFormat);
    return formatter.format(date);
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat(AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }

  // Format time
  static String formatTime(DateTime time) {
    final formatter = DateFormat(AppConstants.timeFormat);
    return formatter.format(time);
  }

  // Format phone number (Vietnam)
  static String formatPhone(String phone) {
    // Remove all spaces and special characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Format: 0xxx xxx xxx
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }

    // Format: +84xxx xxx xxx
    if (cleaned.startsWith('+84') && cleaned.length == 12) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    }

    return cleaned;
  }

  // Format order number (auto-generate)
  static String generateOrderNumber(DateTime date, int sequence) {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final seqStr = sequence.toString().padLeft(3, '0');
    return 'ORD-$dateStr-$seqStr';
  }

  // Format relative time (e.g., "2 giờ trước", "5 phút trước")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  // Parse currency string to double
  static double parseCurrency(String value) {
    // Remove currency symbol and separators
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // Format percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  // Format number with separator
  static String formatNumber(int value) {
    final formatter = NumberFormat.decimalPattern(AppConstants.currencyLocale);
    return formatter.format(value);
  }
}
