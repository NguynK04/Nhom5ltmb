# Hướng dẫn cấu hình Email OTP cho KorderR

## 🚀 Tính năng mới
- ✅ Đăng ký tài khoản Admin
- ✅ Quên mật khẩu với mã OTP qua email
- ✅ Email chào mừng khi đăng ký thành công

## 📧 Cấu hình Gmail để gửi OTP

### Bước 1: Tạo App Password cho Gmail
1. Đăng nhập vào tài khoản Gmail của bạn
2. Đi tới [Google Account Settings](https://myaccount.google.com)
3. Chọn **"Security"** ở menu bên trái
4. Trong phần **"How you sign in to Google"**, bật **"2-Step Verification"** (nếu chưa bật)
5. Sau khi bật 2FA, bạn sẽ thấy tùy chọn **"App passwords"**
6. Click **"App passwords"**
7. Chọn **"Select app"** → **"Mail"**
8. Chọn **"Select device"** → **"Other (Custom name)"**
9. Nhập tên: **"KorderR Restaurant"**
10. Click **"Generate"**
11. **Copy mật khẩu 16 ký tự** được tạo ra (VD: `abcd efgh ijkl mnop`)

### Bước 2: Cập nhật cấu hình trong ứng dụng
1. Mở file `lib/config/email_config.dart`
2. Thay đổi thông tin sau:

```dart
class EmailConfig {
  // Thay thế bằng email của bạn
  static const String senderEmail = 'your-email@gmail.com'; 
  
  // Thay thế bằng App Password vừa tạo (không có dấu cách)
  static const String senderAppPassword = '16-char-app-password'; 
  
  // Tùy chỉnh tên gửi
  static const String senderName = 'KorderR Restaurant';
  
  // Email hỗ trợ (có thể giống senderEmail)
  static const String supportEmail = 'support@korderr.com';
}
```

### Bước 3: Test chức năng
1. Chạy ứng dụng: `flutter run`
2. Thử đăng ký tài khoản Admin mới
3. Thử chức năng "Quên mật khẩu"
4. Kiểm tra email để nhận mã OTP

## 🔧 Xử lý sự cố

### Lỗi "Authentication failed"
- ✅ Kiểm tra email và App Password chính xác
- ✅ Đảm bảo đã bật 2-Step Verification
- ✅ Sử dụng App Password, không phải mật khẩu Gmail thường

### Lỗi "Connection timeout"
- ✅ Kiểm tra kết nối internet
- ✅ Thử lại sau vài phút
- ✅ Kiểm tra firewall không chặn port 587

### Không nhận được email
- ✅ Kiểm tra thư mục Spam/Junk
- ✅ Đảm bảo email người nhận chính xác
- ✅ Kiểm tra log trong terminal để xem lỗi

## 📱 Luồng hoạt động

### Đăng ký Admin:
1. User điền form đăng ký
2. Hệ thống tạo tài khoản Firebase
3. Gửi email chào mừng tự động
4. User xác nhận email từ Firebase
5. Đăng nhập thành công

### Quên mật khẩu:
1. User nhập email
2. Hệ thống tạo mã OTP 6 số
3. Gửi email chứa mã OTP (hiệu lực 10 phút)
4. User nhập mã OTP để xác nhận
5. User nhập mật khẩu mới
6. Hệ thống cập nhật mật khẩu

## 🛡️ Bảo mật

- **Mã OTP**: 6 số, hiệu lực 10 phút
- **App Password**: Bảo mật hơn mật khẩu thường
- **SMTP TLS**: Kết nối được mã hóa
- **Validation**: Kiểm tra email tồn tại trong hệ thống

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy:
1. Kiểm tra terminal log để xem lỗi chi tiết
2. Đảm bảo đã cấu hình email chính xác
3. Test với email khác để loại trừ vấn đề email cụ thể

---
**Lưu ý**: Trong môi trường production, nên sử dụng dịch vụ email chuyên nghiệp như SendGrid, Mailgun hoặc AWS SES để đảm bảo tính ổn định và deliverability.