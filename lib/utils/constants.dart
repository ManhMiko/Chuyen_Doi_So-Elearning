class AppConstants {
  // App Info
  static const String appName = 'E-Learning Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Nền tảng học tập thông minh với AI';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Video
  static const int videoBufferDuration = 5; // seconds
  static const int autoSaveInterval = 5; // seconds
  static const double videoCompletionThreshold = 0.9; // 90%
  
  // Quiz
  static const int defaultQuizTimeLimit = 30; // minutes
  static const int minQuizQuestions = 3;
  static const int maxQuizQuestions = 50;
  static const int passingScorePercentage = 70;
  
  // Points & Rewards
  static const int pointsPerCompletedLesson = 10;
  static const int pointsPerCompletedCourse = 100;
  static const int pointsPerQuizPassed = 20;
  static const int bonusStreakPoints = 5;
  
  // Cache
  static const int imageCacheDuration = 7; // days
  static const int dataCacheDuration = 1; // hours
  
  // Limits
  static const int maxChatHistory = 100;
  static const int maxSearchResults = 50;
  static const int maxRecentSearches = 10;
  
  // URLs
  static const String termsOfServiceUrl = 'https://elearning.com/terms';
  static const String privacyPolicyUrl = 'https://elearning.com/privacy';
  static const String supportUrl = 'https://elearning.com/support';
  static const String faqUrl = 'https://elearning.com/faq';
  
  // Error Messages
  static const String networkError = 'Lỗi kết nối mạng. Vui lòng thử lại.';
  static const String serverError = 'Lỗi server. Vui lòng thử lại sau.';
  static const String unknownError = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String noDataError = 'Không có dữ liệu.';
  
  // Success Messages
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String registerSuccess = 'Đăng ký thành công!';
  static const String updateSuccess = 'Cập nhật thành công!';
  static const String paymentSuccess = 'Thanh toán thành công!';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Storage Keys
  static const String userKey = 'user';
  static const String tokenKey = 'token';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
}

class AssetPaths {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';
  
  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';
  
  // Icons
  static const String appIcon = 'assets/icons/app_icon.png';
}

class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String courseDetail = '/course-detail';
  static const String lesson = '/lesson';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';
  static const String payment = '/payment';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String chat = '/chat';
  static const String miniQuiz = '/mini-quiz';
}
