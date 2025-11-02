class AppConfig {
  // Environment settings
  static const bool isDevelopment = true;
  static const bool isProduction = false;

  // Features toggles
  static const bool enableEmailVerification = true;
  static const bool enableSMSVerification = false;
  static const bool enableGoogleSignIn = false;

  // Admin registration settings
  static const bool requireEmailVerificationForAdmin = true;
  static const bool autoActivateAfterEmailVerification = true;
  static const bool allowMultipleAdminAccounts = true;

  // Email settings
  static const int emailVerificationTimeoutMinutes = 60;
  static const bool showTestVerificationCode =
      isDevelopment; // Chỉ hiện trong dev mode

  // UI settings
  static const bool showDetailedErrorMessages = isDevelopment;
  static const bool enableDebugLogs = isDevelopment;

  // Database settings
  static const String usersCollection = 'users';
  static const String verificationCodesCollection = 'verification_codes';

  // Default roles
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String staffRole = 'staff';

  // App metadata
  static const String appName = 'Korderr';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@korderr.com';

  // Get current environment name
  static String get environmentName {
    if (isDevelopment) return 'Development';
    if (isProduction) return 'Production';
    return 'Unknown';
  }

  // Check if feature is enabled
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'email_verification':
        return enableEmailVerification;
      case 'sms_verification':
        return enableSMSVerification;
      case 'google_signin':
        return enableGoogleSignIn;
      default:
        return false;
    }
  }
}
