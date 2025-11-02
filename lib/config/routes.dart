import 'package:flutter/material.dart';
import 'package:korderr/screens/auth/login_screen.dart';
import 'package:korderr/screens/auth/register_screen.dart';
import 'package:korderr/screens/auth/admin_register_screen.dart';
import 'package:korderr/screens/auth/forgot_password_screen.dart';
import 'package:korderr/screens/splash_screen.dart';
import 'package:korderr/screens/dashboard/admin_dashboard.dart';
import 'package:korderr/screens/dashboard/staff_dashboard.dart';
import 'package:korderr/screens/products/product_list_screen.dart';
import 'package:korderr/screens/products/categorized_menu_screen.dart';
import 'package:korderr/screens/products/product_detail_screen.dart';
import 'package:korderr/screens/products/product_form_screen.dart';
import 'package:korderr/screens/categories/category_list_screen.dart';
import 'package:korderr/screens/categories/category_form_screen.dart';
import 'package:korderr/screens/orders/order_list_screen.dart';
import 'package:korderr/screens/orders/create_order_screen.dart';
import 'package:korderr/screens/orders/order_detail_screen.dart';
import 'package:korderr/screens/customers/customer_list_screen.dart';
import 'package:korderr/screens/customers/customer_form_screen.dart';
import 'package:korderr/screens/cart/cart_screen.dart';
import 'package:korderr/screens/settings/profile_screen.dart';
import 'package:korderr/screens/admin/add_sample_data_screen.dart';
import 'package:korderr/screens/admin/password_management_screen.dart';
import 'package:korderr/screens/admin/staff_management_screen.dart';
import 'package:korderr/screens/debug/firebase_test_screen.dart';
import 'package:korderr/screens/debug/cart_debug_screen.dart';
import 'package:korderr/screens/dashboard_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminRegister = '/admin-register';
  static const String forgotPassword = '/forgot-password';
  static const String adminDashboard = '/admin-dashboard';
  static const String staffDashboard = '/staff-dashboard';
  static const String productList = '/products';
  static const String categorizedMenu = '/products/categorized-menu';
  static const String productDetail = '/products/detail';
  static const String productForm = '/products/form';
  static const String categoryList = '/categories';
  static const String categoryForm = '/categories/form';
  static const String orderList = '/orders';
  static const String createOrder = '/orders/create';
  static const String orderDetail = '/orders/detail';
  static const String customerList = '/customers';
  static const String customerForm = '/customers/form';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String addSampleData = '/admin/add-sample-data';
  static const String passwordManagement = '/admin/password-management';
  static const String staffManagement = '/admin/staff-management';
  static const String firebaseTest = '/debug/firebase-test';
  static const String cartDebug = '/debug/cart';
  static const String dashboard = '/dashboard';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case adminRegister:
        return MaterialPageRoute(builder: (_) => const AdminRegisterScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case staffDashboard:
        return MaterialPageRoute(builder: (_) => const StaffDashboard());

      case productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());

      case categorizedMenu:
        return MaterialPageRoute(builder: (_) => const CategorizedMenuScreen());

      case productDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );

      case productForm:
        final productId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProductFormScreen(productId: productId),
        );

      case categoryList:
        return MaterialPageRoute(builder: (_) => const CategoryListScreen());

      case categoryForm:
        final categoryId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CategoryFormScreen(categoryId: categoryId),
        );

      case orderList:
        return MaterialPageRoute(builder: (_) => const OrderListScreen());

      case createOrder:
        final orderCode = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CreateOrderScreen(orderCode: orderCode),
        );

      case orderDetail:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: orderId),
        );

      case customerList:
        return MaterialPageRoute(builder: (_) => const CustomerListScreen());

      case customerForm:
        final customerId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CustomerFormScreen(customerId: customerId),
        );

      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case addSampleData:
        return MaterialPageRoute(builder: (_) => const AddSampleDataScreen());

      case passwordManagement:
        return MaterialPageRoute(
          builder: (_) => const PasswordManagementScreen(),
        );

      case staffManagement:
        return MaterialPageRoute(builder: (_) => const StaffManagementScreen());

      case firebaseTest:
        return MaterialPageRoute(builder: (_) => const FirebaseTestScreen());

      case cartDebug:
        return MaterialPageRoute(builder: (_) => const CartDebugScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy màn hình: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
