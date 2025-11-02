import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:korderr/config/email_config.dart';

class EmailService {
  // Generate OTP code
  static String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Send OTP email
  static Future<bool> sendOTPEmail({
    required String toEmail,
    required String otpCode,
    required String recipientName,
  }) async {
    try {
      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        EmailConfig.smtpHost,
        port: EmailConfig.smtpPort,
        username: EmailConfig.senderEmail,
        password: EmailConfig.senderAppPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false,
      );

      // Create email message
      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(toEmail)
        ..subject = 'Mã xác nhận đặt lại mật khẩu - KorderR'
        ..html = _buildOTPEmailHTML(recipientName, otpCode);

      // Send email
      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  // Send registration confirmation email
  static Future<bool> sendRegistrationEmail({
    required String toEmail,
    required String recipientName,
  }) async {
    try {
      final smtpServer = SmtpServer(
        EmailConfig.smtpHost,
        port: EmailConfig.smtpPort,
        username: EmailConfig.senderEmail,
        password: EmailConfig.senderAppPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false,
      );

      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(toEmail)
        ..subject = 'Chào mừng bạn đến với KorderR!'
        ..html = _buildRegistrationEmailHTML(recipientName);

      final sendReport = await send(message, smtpServer);
      print('Registration email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('Error sending registration email: $e');
      return false;
    }
  }

  // Build OTP email HTML template
  static String _buildOTPEmailHTML(String recipientName, String otpCode) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Mã xác nhận OTP</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f4f4f4;
                margin: 0;
                padding: 20px;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                background-color: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                text-align: center;
                padding: 30px;
                border-radius: 10px 10px 0 0;
            }
            .content {
                padding: 30px;
                text-align: center;
            }
            .otp-box {
                background-color: #f8f9fa;
                border: 2px dashed #6c757d;
                border-radius: 10px;
                padding: 20px;
                margin: 20px 0;
                display: inline-block;
            }
            .otp-code {
                font-size: 32px;
                font-weight: bold;
                color: #007bff;
                letter-spacing: 5px;
                margin: 0;
            }
            .footer {
                background-color: #f8f9fa;
                padding: 20px;
                text-align: center;
                border-radius: 0 0 10px 10px;
                color: #6c757d;
                font-size: 14px;
            }
            .warning {
                background-color: #fff3cd;
                border: 1px solid #ffeaa7;
                border-radius: 5px;
                padding: 15px;
                margin: 20px 0;
                color: #856404;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🔐 Mã Xác Nhận OTP</h1>
                <p>KorderR Restaurant Management</p>
            </div>
            
            <div class="content">
                <h2>Xin chào $recipientName!</h2>
                <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản KorderR của mình.</p>
                <p>Vui lòng sử dụng mã xác nhận OTP bên dưới:</p>
                
                <div class="otp-box">
                    <p class="otp-code">$otpCode</p>
                </div>
                
                <div class="warning">
                    <strong>⚠️ Lưu ý quan trọng:</strong><br>
                    • Mã OTP này có hiệu lực trong <strong>10 phút</strong><br>
                    • Không chia sẻ mã này với bất kỳ ai<br>
                    • Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này
                </div>
                
                <p>Nếu bạn gặp vấn đề, vui lòng liên hệ với chúng tôi.</p>
            </div>
            
            <div class="footer">
                <p>© 2024 ${EmailConfig.companyName}</p>
                <p>Email này được gửi tự động, vui lòng không reply.</p>
                <p>Hỗ trợ: ${EmailConfig.supportEmail}</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Build registration email HTML template
  static String _buildRegistrationEmailHTML(String recipientName) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Chào mừng đến với KorderR</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f4f4f4;
                margin: 0;
                padding: 20px;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                background-color: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
                color: white;
                text-align: center;
                padding: 30px;
                border-radius: 10px 10px 0 0;
            }
            .content {
                padding: 30px;
                text-align: center;
            }
            .footer {
                background-color: #f8f9fa;
                padding: 20px;
                text-align: center;
                border-radius: 0 0 10px 10px;
                color: #6c757d;
                font-size: 14px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎉 Chào mừng bạn!</h1>
                <p>KorderR Restaurant Management</p>
            </div>
            
            <div class="content">
                <h2>Xin chào $recipientName!</h2>
                <p>Cảm ơn bạn đã đăng ký tài khoản Admin tại KorderR.</p>
                <p>Tài khoản của bạn đã được tạo thành công và sẵn sàng sử dụng.</p>
                <p>Bạn có thể đăng nhập vào hệ thống và bắt đầu quản lý nhà hàng của mình.</p>
                
                <p>Chúc bạn có trải nghiệm tuyệt vời với KorderR!</p>
            </div>
            
            <div class="footer">
                <p>© 2024 ${EmailConfig.companyName}</p>
                <p>Email này được gửi tự động, vui lòng không reply.</p>
                <p>Hỗ trợ: ${EmailConfig.supportEmail}</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
}
