import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_screen.dart';
import 'screens/main/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Flutter Animate
  Animate.restartOnHotReload = true;
  
  runApp(const DrLabLimsApp());
}

class DrLabLimsApp extends StatelessWidget {
  const DrLabLimsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Dr Lab LIMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.authState == AuthState.initial) {
          return const LoadingScreen();
        }

        // Navigate based on authentication state
        switch (authProvider.authState) {
          case AuthState.authenticated:
            return const MainScreen();
          case AuthState.setupRequired:
            return const SetupScreen();
          case AuthState.unauthenticated:
          case AuthState.loading:
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              Color(0xFF262626),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: AppTheme.primaryColor.withOpacity(0.3))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                'Dr Lab LIMS',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 500.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Laboratory Information Management System',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 1000.ms, delay: 700.ms),
              
              const SizedBox(height: 48),
              
              // Loading Indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 900.ms),
              
              const SizedBox(height: 16),
              
              Text(
                'Initializing...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.tertiaryTextColor,
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 1100.ms),
            ],
          ),
        ),
      ),
    );
  }
}