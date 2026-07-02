// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/controllers.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'views/auth_screens.dart';
import 'views/onboarding_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        // Controllers
        ChangeNotifierProvider(
          create: (ctx) => AuthController(
            authService: ctx.read<FirebaseAuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HealthController(
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FruitController(
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProductController(
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Health Mango Scanner',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFFA000),
          brightness: Brightness.light,
        ),
        home: const _AuthGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/onboarding': (_) => OnboardingScreen(
                onComplete: (profile) {
                  // Navigate to home
                  Navigator.of(_).pushReplacementNamed('/home');
                },
              ),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authCtrl, _) {
        // Not logged in
        if (!authCtrl.isAuthenticated) {
          return const LoginScreen();
        }

        // Logged in - check if health profile exists
        return Consumer<HealthController>(
          builder: (context, healthCtrl, _) {
            if (healthCtrl.healthProfile == null && !healthCtrl.isLoading) {
              return OnboardingScreen(
                onComplete: (profile) {
                  // Navigate to home
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              );
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}
