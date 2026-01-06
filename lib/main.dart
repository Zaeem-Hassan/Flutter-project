import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/settings_screen.dart';
import 'services/connectivity_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.instance.init();
  
  runApp(const DiabetesApp());
}

class DiabetesApp extends StatelessWidget {
  const DiabetesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return MaterialApp(
            title: 'DiabCheck',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsService.flutterThemeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/result') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    prediction: args['prediction'],
                    probability: args['probability'],
                    message: args['message'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
