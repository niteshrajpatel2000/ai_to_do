import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'language_page.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  String _statusText = 'Initializing AI...';

  @override
  void initState() {
    super.initState();

    // Remove the native splash screen
    FlutterNativeSplash.remove();

    // Fade & scale controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress bar controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Update status text as progress advances
    _progressController.addListener(() {
      if (!mounted) return;
      final value = _progressController.value;
      setState(() {
        if (value < 0.3) {
          _statusText = 'Initializing AI...';
        } else if (value < 0.6) {
          _statusText = 'Optimizing your day...';
        } else if (value < 0.85) {
          _statusText = 'Loading tasks...';
        } else {
          _statusText = 'Almost ready...';
        }
      });
    });

    _fadeController.forward();

    // Start progress after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressController.forward();
    });

    // Navigate based on auth state after animation completes
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) _navigateToNextScreen();
    });
  }

  /// Check if user is logged in and if language was already selected
  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedLanguage = prefs.getString('language_code') != null;
    final currentUser = FirebaseAuth.instance.currentUser;

    Widget nextScreen;

    if (currentUser != null) {
      // User is already logged in → go directly to Dashboard
      nextScreen = const HomePage();
    } else if (hasSelectedLanguage) {
      // Language was selected before but user is not logged in → go to Login
      nextScreen = const LoginPage();
    } else {
      // First time user → go to Language selection
      nextScreen = const LanguagePage();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // App Icon with scale and fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90FF).withOpacity(0.25),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/ai.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'AI To-Do',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Intelligent Task Management',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Progress section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      // Status text and percentage
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _statusText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4A90FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Progress bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4A90FF),
                                      Color(0xFF6C63FF),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4A90FF)
                                          .withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Bottom secure text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SECURE AI PROCESSING',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
