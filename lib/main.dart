import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme_config.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with explicit options for Web
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDcdLuuXsZuhKieTF-geCHo2CCjXGnhM1A",
          authDomain: "elearning-app-demo.firebaseapp.com",
          projectId: "elearning-app-demo",
          storageBucket: "elearning-app-demo.firebasestorage.app",
          messagingSenderId: "50004759891",
          appId: "1:50004759891:web:e31838fb4a904494cebda6",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('Running without Firebase - some features will be limited');
  }
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
  } catch (e) {
    print('Hive initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'E-Learning Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
