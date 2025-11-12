class AppConfig {
  static const String appName = 'E-Learning Pro';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.elearning.com';
  static const String apiVersion = 'v1';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String enrollmentsCollection = 'enrollments';
  static const String progressCollection = 'progress';
  static const String quizzesCollection = 'quizzes';
  static const String paymentsCollection = 'payments';
  static const String chatHistoryCollection = 'chat_history';
  
  // Pagination
  static const int coursesPerPage = 10;
  static const int commentsPerPage = 20;
  
  // Video Settings
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  
  // Quiz Settings
  static const int miniQuizQuestions = 5;
  static const int fullQuizQuestions = 20;
  static const int quizTimeLimit = 30; // minutes
  
  // AI Settings
  static const int maxChatHistory = 50;
  static const int aiResponseTimeout = 30; // seconds
}
