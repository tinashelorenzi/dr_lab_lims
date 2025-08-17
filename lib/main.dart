// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Only import window_manager on desktop platforms
import 'package:window_manager/window_manager.dart'
    if (dart.library.html) 'web_stubs.dart';

import 'providers/auth_provider.dart';
import 'shared/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_screen.dart';
import 'screens/main/main_layout_screen.dart';
import 'widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dotenv BEFORE anything else
  try {
    await dotenv.load(fileName: ".env");
    print("Environment loaded successfully");
  } catch (e) {
    print("Failed to load .env file: $e");
    // Continue anyway with default values
  }
  
  // Only initialize window manager on desktop platforms
  if (!kIsWeb) {
    await _initializeWindowManager();
  }

  runApp(const MyApp());
}

Future<void> _initializeWindowManager() async {
  try {
    // Initialize window manager for desktop
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'DR Lab LIMS',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (e) {
    print("Window manager initialization failed: $e");
    // Continue without window manager
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'DR Lab LIMS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
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
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.authState) {
          case AuthState.initial:
          case AuthState.loading:
            return const LoadingScreen();
            
          case AuthState.authenticated:
            return const MainLayoutScreen();
            
          case AuthState.setupRequired:
            return const SetupScreen();
            
          case AuthState.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}