# Korderr - Ứng dụng Quản lý Order Món Nhà Hàng

Ứng dụng quản lý đơn hàng món ăn cho nhà hàng được xây dựng bằng Flutter + Firebase.

## 🎯 Tính năng chính

### ✅ Đã hoàn thành
- ✅ Authentication (Đăng nhập/Đăng ký)
- ✅ Dashboard cho Admin/Manager và Staff
- ✅ Cấu trúc dự án hoàn chỉnh
- ✅ Models, Services, Repositories, Providers
- ✅ Theme và Routes
- ✅ Validators và Helpers

### 🚧 Đang phát triển (Placeholder screens)
- 🚧 Quản lý Sản phẩm (Products)
- 🚧 Quản lý Danh mục (Categories)
- 🚧 Quản lý Đơn hàng (Orders) - CORE
- 🚧 Quản lý Khách hàng (Customers)
- 🚧 Thống kê và Báo cáo

## 📋 Yêu cầu

- Flutter SDK: ^3.9.2
- Dart: ^3.9.2
- Firebase project (Firestore, Authentication, Storage)

## 🚀 Cài đặt

### 1. Clone repository

```bash
git clone <repository-url>
cd korderr
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình Firebase

#### Cách 1: Sử dụng FlutterFire CLI (Khuyến nghị)

```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Đăng nhập Firebase
firebase login

# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình Firebase
flutterfire configure
```

Lệnh `flutterfire configure` sẽ tự động:
- Tạo Firebase project (nếu chưa có)
- Tạo file `lib/config/firebase_options.dart`
- Cấu hình cho các nền tảng (Android, iOS, Web)

### 4. Kích hoạt Firebase Services

Trong Firebase Console, kích hoạt:
- ✅ **Authentication** → Email/Password
- ✅ **Firestore Database** → Start in test mode
- ✅ **Storage** → Start in test mode

### 5. Tạo tài khoản Admin đầu tiên

Vào Firebase Console → Authentication → Add user:
- Email: admin@korderr.com
- Password: 123456

Sau đó vào Firestore → Tạo collection `users` → Thêm document:

```json
{
  "email": "admin@korderr.com",
  "fullName": "Administrator",
  "phone": "0123456789",
  "role": "ADMIN",
  "isActive": true,
  "avatar": null
}
```

### 6. Chạy ứng dụng

```bash
flutter run
```

## 📱 Tài khoản Demo

- **Admin**: admin@korderr.com / 123456

## 📁 Cấu trúc Project

```
lib/
├── config/                 # Cấu hình
├── core/                   # Constants, Utils
├── models/                 # Data models
├── services/               # Firebase services
├── repositories/           # Data repositories
├── providers/              # State management
├── screens/                # UI screens
└── main.dart              # Entry point
```

## 🛠️ Các bước tiếp theo

1. Cấu hình Firebase (Quan trọng!)
2. Implement Product Management
3. Implement Order Management (CORE)
4. Implement Customer Management
5. Add Statistics & Charts

## 📝 Notes

- Tất cả screens hiện đang ở dạng **placeholder** (trừ Auth và Dashboard)
- Cần cấu hình Firebase trước khi chạy
- File `firebase_options.dart` là template, cần chạy `flutterfire configure`

## Getting Started (Original)

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
