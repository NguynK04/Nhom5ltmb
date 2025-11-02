class AppConstants {
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String productsCollection = 'products';
  static const String customersCollection = 'customers';
  static const String ordersCollection = 'orders';
  static const String settingsCollection = 'settings';
  static const String logsCollection = 'logs';

  // User Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleManager = 'MANAGER';
  static const String roleStaff = 'STAFF';

  // Order Status
  static const String orderStatusPending = 'PENDING';
  static const String orderStatusPreparing = 'PREPARING';
  static const String orderStatusReady = 'READY';
  static const String orderStatusCompleted = 'COMPLETED';
  static const String orderStatusCancelled = 'CANCELLED';

  // Payment Methods
  static const String paymentMethodCash = 'CASH';
  static const String paymentMethodCard = 'CARD';
  static const String paymentMethodQRCode = 'QR_CODE';
  static const String paymentMethodBankTransfer = 'BANK_TRANSFER';

  // Customer Types
  static const String customerTypeNew = 'NEW';
  static const String customerTypeRegular = 'REGULAR';
  static const String customerTypeVIP = 'VIP';

  // Customer Type Thresholds
  static const double regularCustomerSpendThreshold = 500000;
  static const int regularCustomerVisitThreshold = 5;
  static const double vipCustomerSpendThreshold = 5000000;

  // Product Units
  static const List<String> productUnits = [
    'phần',
    'ly',
    'chai',
    'tô',
    'dĩa',
    'suất',
    'kg',
    'gram',
  ];

  // Storage Paths
  static const String productsImagesPath = 'products';
  static const String usersAvatarsPath = 'users/avatars';

  // App Settings
  static const int maxImageSizeMB = 5;
  static const int maxAvatarSizeMB = 2;
  static const double defaultTaxRate = 0.1; // 10% VAT

  // Pagination
  static const int defaultPageSize = 20;
  static const int productsPerPage = 20;
  static const int ordersPerPage = 20;
  static const int customersPerPage = 20;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Currency
  static const String currencySymbol = 'đ';
  static const String currencyLocale = 'vi_VN';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 200;

  // Messages
  static const String msgLoginSuccess = 'Đăng nhập thành công';
  static const String msgLoginFailed = 'Đăng nhập thất bại';
  static const String msgLogoutSuccess = 'Đăng xuất thành công';
  static const String msgInvalidEmail = 'Email không hợp lệ';
  static const String msgInvalidPassword = 'Mật khẩu phải có ít nhất 6 ký tự';
  static const String msgRequiredField = 'Trường này là bắt buộc';
  static const String msgSaveSuccess = 'Lưu thành công';
  static const String msgSaveFailed = 'Lưu thất bại';
  static const String msgDeleteSuccess = 'Xóa thành công';
  static const String msgDeleteFailed = 'Xóa thất bại';
  static const String msgUpdateSuccess = 'Cập nhật thành công';
  static const String msgUpdateFailed = 'Cập nhật thất bại';
  static const String msgOrderCreated = 'Đơn hàng đã được tạo thành công';
  static const String msgOrderCancelled = 'Đơn hàng đã bị hủy';
  static const String msgConfirmDelete = 'Bạn có chắc chắn muốn xóa?';
  static const String msgConfirmCancel = 'Bạn có chắc chắn muốn hủy đơn hàng?';
  static const String msgNoData = 'Không có dữ liệu';
  static const String msgLoadingData = 'Đang tải dữ liệu...';
  static const String msgNetworkError = 'Lỗi kết nối mạng';
  static const String msgUnauthorized =
      'Bạn không có quyền thực hiện thao tác này';

  // Log Actions
  static const String logActionLogin = 'LOGIN';
  static const String logActionLogout = 'LOGOUT';
  static const String logActionCreateOrder = 'CREATE_ORDER';
  static const String logActionUpdateOrder = 'UPDATE_ORDER';
  static const String logActionCancelOrder = 'CANCEL_ORDER';
  static const String logActionCreateProduct = 'CREATE_PRODUCT';
  static const String logActionUpdateProduct = 'UPDATE_PRODUCT';
  static const String logActionDeleteProduct = 'DELETE_PRODUCT';
  static const String logActionCreateCustomer = 'CREATE_CUSTOMER';
  static const String logActionUpdateCustomer = 'UPDATE_CUSTOMER';

  // Log Modules
  static const String logModuleAuth = 'AUTH';
  static const String logModuleOrders = 'ORDERS';
  static const String logModuleProducts = 'PRODUCTS';
  static const String logModuleCustomers = 'CUSTOMERS';
  static const String logModuleCategories = 'CATEGORIES';
  static const String logModuleSettings = 'SETTINGS';
}
