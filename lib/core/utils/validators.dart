class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Trường này'} không được để trống';
    }
    return null;
  }

  // Phone validation (Vietnam)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Trường này'} không được để trống';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Trường này'} phải là số';
    }
    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final result = validateNumber(value, fieldName: fieldName);
    if (result != null) return result;

    if (double.parse(value!) <= 0) {
      return '${fieldName ?? 'Trường này'} phải lớn hơn 0';
    }
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    return validatePositiveNumber(value, fieldName: 'Giá');
  }

  // Stock validation
  static String? validateStock(String? value) {
    final result = validateNumber(value, fieldName: 'Tồn kho');
    if (result != null) return result;

    if (int.tryParse(value!) == null) {
      return 'Tồn kho phải là số nguyên';
    }
    if (int.parse(value) < 0) {
      return 'Tồn kho không được âm';
    }
    return null;
  }

  // Max length validation
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Trường này'} không được vượt quá $maxLength ký tự';
    }
    return null;
  }

  // Discount validation
  static String? validateDiscount(String? value) {
    if (value == null || value.isEmpty) return null;

    final discount = double.tryParse(value);
    if (discount == null) {
      return 'Giảm giá phải là số';
    }
    if (discount < 0 || discount > 100) {
      return 'Giảm giá phải từ 0 đến 100';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }
}
