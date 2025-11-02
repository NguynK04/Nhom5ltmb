// File cấu hình email cho ứng dụng
//
// HƯỚNG DẪN CẤU HÌNH GMAIL:
// 1. Đăng nhập vào Gmail của bạn
// 2. Đi tới Google Account settings (myaccount.google.com)
// 3. Chọn "Security"
// 4. Bật "2-Step Verification" nếu chưa bật
// 5. Tìm "App passwords" và tạo mật khẩu ứng dụng mới
// 6. Chọn "Mail" và "Other" rồi nhập tên ứng dụng (VD: KorderR)
// 7. Copy mật khẩu 16 ký tự được tạo ra
// 8. Cập nhật thông tin bên dưới:

class EmailConfig {
  // ⚠️ QUAN TRỌNG: Cập nhật thông tin email của bạn ở đây
  static const String senderEmail = 'nguyenkhoa0914044556@gmail.com';
  static const String senderAppPassword =
      'yaco nthu uaji salz'; // App Password từ Google
  static const String senderName = 'KorderR Restaurant';

  // SMTP Configuration for Gmail
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;

  // OTP Settings
  static const int otpExpiryMinutes = 10;

  // Email Templates
  static const String supportEmail = 'nguyenkhoa0914044556@gmail.com';
  static const String companyName = 'KorderR Restaurant Management';
  static const String companyWebsite = 'https://korderr.com';
}

// HƯỚNG DẪN SỬ DỤNG:
// 1. Mở file lib/services/email_service.dart
// 2. Thay thế các constant ở đầu file bằng EmailConfig
// 3. Cập nhật thông tin email của bạn ở trên
// 4. Test bằng cách đăng ký tài khoản mới hoặc quên mật khẩu

/* 
EXAMPLE APP PASSWORD: 
- Đăng nhập Gmail > Manage your Google Account > Security
- Bật 2-Step Verification
- App passwords > Select app: Mail > Select device: Other
- Nhập "KorderR" > Generate
- Copy mật khẩu 16 ký tự (VD: abcd efgh ijkl mnop)
- Paste vào senderAppPassword ở trên (không có spaces)
*/
