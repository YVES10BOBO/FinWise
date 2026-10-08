import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'auth_widgets.dart';
import '../../main.dart';
import '../../l10n/l10n_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Normalize email (trim and lowercase) but keep password as-is
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text;
        
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Reload user to ensure auth state is fully updated
        if (credential.user != null) {
          await credential.user!.reload();
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loginSuccess),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait for auth state to fully propagate
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Force auth state refresh by checking current user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Wait a bit more for the auth state listener to trigger
          await Future.delayed(const Duration(milliseconds: 300));
        }

        if (!mounted) return;

        // Navigate to InitialScreen which will show onboarding or main app
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InitialScreen()),
          (route) => false, // Remove all previous routes
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        // Handle all possible Firebase Auth error codes
        final message = switch (e.code) {
          'user-not-found' => context.l10n.errUserNotFound,
          'wrong-password' => context.l10n.errWrongPassword,
          'invalid-credential' => context.l10n.errInvalidCredential,
          'invalid-email' => context.l10n.errInvalidEmailEnter,
          'user-disabled' => context.l10n.errUserDisabled,
          'too-many-requests' => context.l10n.errTooManyFailed,
          'network-request-failed' => context.l10n.errNetworkInternet,
          'operation-not-allowed' => context.l10n.errLoginDisabled,
          'requires-recent-login' => context.l10n.errReLogin,
          _ => context.l10n.errLoginFailedCode(e.message ?? e.code),
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.expenseColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        // Check if login was actually successful despite the error
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == _emailController.text.trim().toLowerCase()) {
          // Login was successful, just handle navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.loginSuccess),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await Future.delayed(const Duration(milliseconds: 300));
            }
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const InitialScreen()),
                (route) => false,
              );
            }
          }
        } else {
          // Some background plugins (e.g. Pigeon-generated APIs) can throw
          // benign type-cast errors after a successful login. We don't want to
          // confuse the user with those if auth actually worked.
          final message = e.toString();
          if (!message.contains('PigeonUserDetails')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.loginFailedRetry),
                backgroundColor: AppTheme.expenseColor,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Branded header ──────────────────────────────────────────
            AuthHeader(
              title: context.l10n.welcomeBack,
              subtitle: context.l10n.signInSubtitle,
            ),

            // ── Form ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthField(
                      controller: _emailController,
                      label: context.l10n.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.enterEmail;
                        }
                        if (!value.contains('@')) {
                          return context.l10n.enterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      controller: _passwordController,
                      label: context.l10n.password,
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textLight,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.enterPassword;
                        }
                        if (value.length < 6) {
                          return context.l10n.passwordMin6;
                        }
                        return null;
                      },
                    ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.l10n.forgotPassword,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary action
                    AuthButton(
                      label: context.l10n.signIn,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleLogin,
                    ),

                    const SizedBox(height: 28),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            context.l10n.newToFinwise,
                            style: TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sign up — a real button, not a buried text link
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(
                              color: AppTheme.primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          context.l10n.createAnAccount,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
