import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_config.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/lecture_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only if configured)
  if (FirebaseConfig.isConfigured) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: FirebaseConfig.apiKey,
        appId: FirebaseConfig.appId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
        authDomain: FirebaseConfig.authDomain,
        storageBucket: FirebaseConfig.storageBucket,
        measurementId: FirebaseConfig.measurementId,
      ),
    );
  }

  runApp(const LMSApp());
}

class LMSApp extends StatelessWidget {
  const LMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LectureProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LMS - Lecture Management System',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getThemeData(),
            darkTheme: themeProvider.getThemeData(),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
