import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.linear,
      ),
    );

    _animationController.forward();
    _backgroundAnimationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundAnimationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!_isLoginMode && (value == null || value.isEmpty)) {
      return 'Name is required';
    }
    return null;
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    try {
      if (_isLoginMode) {
        await auth.login(emailController.text, passwordController.text);
      } else {
        await auth.signup(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text.isNotEmpty ? nameController.text : null,
          phone: phoneController.text.isNotEmpty ? phoneController.text : null,
        );
      }

      if (!mounted) return;

      // Navigate based on user role
      if (auth.currentUser?.role == 'seller') {
        Navigator.of(context).pushReplacementNamed('/seller');
      } else if (auth.currentUser?.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        Navigator.of(context).pushReplacementNamed('/customer');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${auth.error ?? e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    theme.colorScheme.primaryContainer.withOpacity(0.3),
                    theme.colorScheme.secondaryContainer.withOpacity(0.4),
                    _backgroundAnimation.value,
                  )!,
                  Color.lerp(
                    theme.colorScheme.secondaryContainer.withOpacity(0.2),
                    theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                    _backgroundAnimation.value,
                  )!,
                  Color.lerp(
                    theme.colorScheme.tertiaryContainer.withOpacity(0.1),
                    theme.colorScheme.primaryContainer.withOpacity(0.2),
                    _backgroundAnimation.value,
                  )!,
                ],
                stops: [0.0, 0.5 + 0.3 * _backgroundAnimation.value, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated floating particles
                ...List.generate(12, (index) {
                  final delay = index * 0.3;
                  final progress = (_backgroundAnimation.value + delay) % 1.0;
                  final size = 6 + (12 * progress);
                  final opacity = (1 - progress) * 0.8;

                  return Positioned(
                    left:
                        (MediaQuery.of(context).size.width * 0.05) +
                        (MediaQuery.of(context).size.width * 0.9 * progress),
                    top:
                        (MediaQuery.of(context).size.height * 0.1) +
                        (MediaQuery.of(context).size.height *
                            0.8 *
                            (0.3 + 0.7 * (progress * 2 - 1).abs())),
                    child: Transform.rotate(
                      angle: progress * 2 * 3.14159,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                                theme.colorScheme.tertiary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: size * 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Animated waves
                ...List.generate(3, (index) {
                  final waveProgress =
                      (_backgroundAnimation.value + index * 0.3) % 1.0;
                  final waveHeight = 80 + (60 * (1 - waveProgress));
                  final waveOpacity = 0.2 + (0.15 * (1 - waveProgress));

                  return Positioned(
                    bottom: -20,
                    left:
                        -100 +
                        (waveProgress *
                            (MediaQuery.of(context).size.width + 200)),
                    child: Opacity(
                      opacity: waveOpacity,
                      child: Container(
                        width: MediaQuery.of(context).size.width + 200,
                        height: waveHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(waveHeight / 2),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.3),
                              theme.colorScheme.secondary.withOpacity(0.2),
                              theme.colorScheme.tertiary.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Floating geometric shapes
                ...List.generate(6, (index) {
                  final shapeProgress =
                      (_backgroundAnimation.value + index * 0.4) % 1.0;
                  final shapeSize = 25 + (35 * shapeProgress);
                  final shapeOpacity = 0.1 + (0.2 * (1 - shapeProgress));
                  final isEven = index % 2 == 0;

                  return Positioned(
                    left:
                        (MediaQuery.of(context).size.width * 0.2) +
                        (MediaQuery.of(context).size.width *
                            0.6 *
                            shapeProgress),
                    top:
                        (MediaQuery.of(context).size.height * 0.3) +
                        (MediaQuery.of(context).size.height *
                            0.4 *
                            (0.5 + 0.5 * (shapeProgress * 2 - 1).abs())),
                    child: Transform.rotate(
                      angle: shapeProgress * 4 * 3.14159,
                      child: Opacity(
                        opacity: shapeOpacity,
                        child: Container(
                          width: shapeSize,
                          height: shapeSize,
                          decoration: BoxDecoration(
                            color: isEven
                                ? theme.colorScheme.tertiary.withOpacity(0.6)
                                : theme.colorScheme.secondary.withOpacity(0.6),
                            shape: isEven
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: isEven
                                ? null
                                : BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Main content
                child!,
              ],
            ),
          );
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Hero Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.2,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to FoodHub',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign up as a customer or login with your credentials to access your account',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Authentication Section
                    Card(
                      color: theme.colorScheme.surface.withOpacity(0.3),
                      elevation: 8,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header with toggle
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLoginMode
                                        ? 'Welcome Back'
                                        : 'Create Account',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _toggleMode,
                                      icon: Icon(
                                        _isLoginMode
                                            ? Icons.person_add
                                            : Icons.login,
                                        size: 20,
                                      ),
                                      label: Text(
                                        _isLoginMode ? 'Sign Up' : 'Sign In',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Name field (signup only)
                              if (!_isLoginMode) ...[
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    hintText: 'Enter your full name',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                  validator: _validateName,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email field
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'example@email.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: _validatePassword,
                              ),

                              // Phone field (signup only)
                              if (!_isLoginMode) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number (Optional)',
                                    hintText: '+1 (555) 123-4567',
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                    ),
                                  ),
                                ),
                              ],

                              // Help text for signup
                              if (!_isLoginMode) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'New accounts are created as customers. Seller and admin accounts are managed separately.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Submit button
                              SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: auth.loading
                                      ? null
                                      : _handleSubmit,
                                  icon: auth.loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          _isLoginMode
                                              ? Icons.login
                                              : Icons.person_add,
                                        ),
                                  label: Text(
                                    auth.loading
                                        ? (_isLoginMode
                                              ? 'Signing in...'
                                              : 'Creating account...')
                                        : (_isLoginMode
                                              ? 'Sign In'
                                              : 'Sign Up'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),

                              // Error message
                              if (auth.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.error!,
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
