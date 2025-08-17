// lib/widgets/loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../shared/theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.science_outlined,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ).animate().scale(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
            ).then().shake(duration: const Duration(milliseconds: 500)),
            
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'DR Lab LIMS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 500),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Laboratory Management System',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 700),
            ),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor.withOpacity(0.8),
                ),
              ),
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 1000),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 1200),
            ),
          ],
        ),
      ),
    );
  }
}