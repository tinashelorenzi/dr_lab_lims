import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User email not found'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final success = await authProvider.completeSetup(
      authProvider.user!.email,
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (!success && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
    // Navigation is handled by the main app based on auth state
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 48),
                    
                    // Setup Steps
                    _buildSetupSteps(),
                    
                    const SizedBox(height: 32),
                    
                    // Setup Form
                    _buildSetupForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Setup Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.security_outlined,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Account Setup',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(
          duration: 800.ms,
          delay: 200.ms,
        ).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Text(
              'Welcome, ${authProvider.user?.displayName ?? 'User'}!\nLet\'s secure your account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            );
          },
        ).animate().fadeIn(
          duration: 800.ms,
          delay: 400.ms,
        ).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildSetupSteps() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Setup Progress',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildStepIndicator(0, 'Password', Icons.lock_outlined),
              _buildStepConnector(0),
              _buildStepIndicator(1, 'Security', Icons.security_outlined),
              _buildStepConnector(1),
              _buildStepIndicator(2, 'Complete', Icons.check_circle_outlined),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 600.ms,
      delay: 600.ms,
    ).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppTheme.primaryColor 
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive 
                    ? AppTheme.primaryColor 
                    : AppTheme.borderColor,
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive ? Colors.white : AppTheme.secondaryTextColor,
              size: 20,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive 
                  ? AppTheme.primaryTextColor 
                  : AppTheme.secondaryTextColor,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: isCompleted 
              ? AppTheme.primaryColor 
              : AppTheme.borderColor,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildSetupForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_currentStep == 0) ..._buildPasswordStep(),
                if (_currentStep == 1) ..._buildSecurityStep(),
                if (_currentStep == 2) ..._buildCompleteStep(),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                _buildActionButtons(authProvider),
              ],
            ),
          ),
        ).animate().fadeIn(
          duration: 600.ms,
          delay: 800.ms,
        ).slideY(begin: 0.2, end: 0);
      },
    );
  }

  List<Widget> _buildPasswordStep() {
    return [
      Text(
        'Set Your Password',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 8),
      
      Text(
        'Create a strong password to secure your account',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.secondaryTextColor,
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 24),
      
      // Password Field
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'New Password',
          hintText: 'Enter a strong password',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword 
                  ? Icons.visibility_outlined 
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter a password';
          }
          if (value!.length < 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        },
      ),
      
      const SizedBox(height: 16),
      
      // Confirm Password Field
      TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword 
                  ? Icons.visibility_outlined 
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please confirm your password';
          }
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
      
      const SizedBox(height: 16),
      
      // Password Requirements
      _buildPasswordRequirements(),
    ];
  }

  List<Widget> _buildSecurityStep() {
    return [
      Text(
        'Security Setup',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 8),
      
      Text(
        'We\'re generating your encryption keys for secure communication',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.secondaryTextColor,
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 32),
      
      // Security Features
      _buildSecurityFeature(
        Icons.enhanced_encryption_outlined,
        'End-to-End Encryption',
        'Your messages and data are encrypted with RSA 2048-bit keys',
      ),
      
      const SizedBox(height: 16),
      
      _buildSecurityFeature(
        Icons.fingerprint_outlined,
        'Secure Authentication',
        'Multi-factor authentication and secure session management',
      ),
      
      const SizedBox(height: 16),
      
      _buildSecurityFeature(
        Icons.verified_user_outlined,
        'Data Protection',
        'Your private keys are encrypted and stored securely',
      ),
    ];
  }

  List<Widget> _buildCompleteStep() {
    return [
      Icon(
        Icons.check_circle_outlined,
        size: 64,
        color: AppTheme.successColor,
      ).animate().scale(
        duration: 600.ms,
        curve: Curves.elasticOut,
      ),
      
      const SizedBox(height: 24),
      
      Text(
        'Setup Complete!',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppTheme.successColor,
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 8),
      
      Text(
        'Your account is now secure and ready to use',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.secondaryTextColor,
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildRequirement('At least 8 characters', password.length >= 8),
          _buildRequirement('Contains uppercase letter', password.contains(RegExp(r'[A-Z]'))),
          _buildRequirement('Contains lowercase letter', password.contains(RegExp(r'[a-z]'))),
          _buildRequirement('Contains number', password.contains(RegExp(r'[0-9]'))),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: met ? AppTheme.successColor : AppTheme.tertiaryTextColor,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: met ? AppTheme.successColor : AppTheme.tertiaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AuthProvider authProvider) {
    return Row(
      children: [
        if (_currentStep > 0 && _currentStep < 2)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
          ),
        
        if (_currentStep > 0 && _currentStep < 2)
          const SizedBox(width: 16),
        
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _getActionButtonOnPressed(authProvider),
              child: _getActionButtonChild(authProvider),
            ),
          ),
        ),
      ],
    );
  }

  VoidCallback? _getActionButtonOnPressed(AuthProvider authProvider) {
    if (authProvider.isLoading) return null;
    
    switch (_currentStep) {
      case 0:
        return () {
          if (_formKey.currentState!.validate()) {
            _nextStep();
          }
        };
      case 1:
        return _nextStep;
      case 2:
        return _handleSetup;
      default:
        return null;
    }
  }

  Widget _getActionButtonChild(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    
    switch (_currentStep) {
      case 0:
        return const Text('Continue');
      case 1:
        return const Text('Next');
      case 2:
        return const Text('Complete Setup');
      default:
        return const Text('Continue');
    }
  }
}