import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localization.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/auth_bloc/auth_state.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _navigateToHome();
        } else if (state.status == AuthStatus.error &&
            state.errorMessage != null) {
          _showError(state.errorMessage!);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0D1117),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // App Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90FF).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/ai.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Welcome Text
                      Text(
                        t.translate('welcome_back'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        t.translate('sign_in_subtitle'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email Label
                            Text(
                              t.translate('email'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hintText: t.translate('email_hint'),
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),

                            // Password Label with Forgot
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.translate('password'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    t.translate('forgot_password'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4A90FF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Password Field - BlocBuilder
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.obscurePassword != curr.obscurePassword,
                              builder: (context, state) {
                                return _buildTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: state.obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      state.obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white.withOpacity(0.4),
                                      size: 20,
                                    ),
                                    onPressed: () => context
                                        .read<AuthBloc>()
                                        .add(AuthTogglePasswordVisibility()),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Remember Device - BlocBuilder
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) =>
                                  prev.rememberDevice != curr.rememberDevice,
                              builder: (context, state) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: state.rememberDevice,
                                        onChanged: (_) => context
                                            .read<AuthBloc>()
                                            .add(AuthToggleRememberDevice()),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        activeColor: const Color(0xFF4A90FF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      t.translate('remember_device'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Sign In Button - BlocBuilder
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (prev, curr) => prev.status != curr.status,
                              builder: (context, state) {
                                final isLoading = state.status == AuthStatus.loading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_emailController.text.trim().isEmpty ||
                                                _passwordController.text.trim().isEmpty) {
                                              _showError('Please fill in all fields');
                                              return;
                                            }
                                            context.read<AuthBloc>().add(AuthSignInWithEmail(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text.trim(),
                                            ));
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B5BFE),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(t.translate('sign_in'),
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.arrow_forward, size: 18),
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Or continue with
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(t.translate('or_continue_with'),
                                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social Buttons - BlocBuilder
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (prev, curr) => prev.status != curr.status,
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  label: t.translate('google'),
                                  icon: Icons.g_mobiledata,
                                  onTap: isLoading ? () {} : () => context.read<AuthBloc>().add(AuthSignInWithGoogle()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSocialButton(
                                  label: t.translate('apple'),
                                  icon: Icons.apple,
                                  onTap: isLoading ? () {} : () => context.read<AuthBloc>().add(AuthSignInWithApple()),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Create Account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.translate('no_account'),
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                ),
                              );
                            },
                            child: Text(t.translate('create_account'),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF4A90FF), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.4), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: icon == Icons.g_mobiledata ? 24 : 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
