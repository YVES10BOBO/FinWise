import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart';
import 'auth_widgets.dart';
import '../legal_screen.dart';
import '../../services/firestore_user_profile_service.dart';
import '../../l10n/l10n_helpers.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.agreeTermsRequired),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        // Normalize email (trim and lowercase) for consistency
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text;
        
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save name locally for UI personalization (until we migrate to Firestore profile)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text.trim());

        // Also set displayName in Firebase Auth profile
        await credential.user?.updateDisplayName(_nameController.text.trim());

        // Create user profile doc in Firestore (so UID maps to name/email)
        final user = credential.user;
        if (user != null) {
          await FirestoreUserProfileService().createProfileIfNeeded(
            uid: user.uid,
            email: user.email,
            name: _nameController.text.trim(),
          );
          // Reload user to ensure auth state is fully updated
          await user.reload();
        }

        if (!mounted) return;
        setState(() => _isLoading = false);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.accountCreated),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a moment for the success message to be visible
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        // Sign out the user so they can log in with their new account
        await FirebaseAuth.instance.signOut();

        // Re-check after the await — the user may have left this screen.
        if (!mounted) return;

        // Navigate directly to LoginScreen
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Remove all previous routes
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final message = switch (e.code) {
          'email-already-in-use' => context.l10n.errEmailInUse,
          'invalid-email' => context.l10n.errInvalidEmailCheck,
          'weak-password' => context.l10n.errWeakPassword,
          'operation-not-allowed' => context.l10n.errSignupDisabled,
          'network-request-failed' => context.l10n.errNetworkConnection,
          _ => e.message ?? context.l10n.signupFailed,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.expenseColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final message = e.toString();
        // Check if account was actually created despite the error
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == _emailController.text.trim().toLowerCase()) {
          // Account was created successfully, just handle navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.accountCreated),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            // Sign out the user so they can log in with their new account
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          // Some background plugins can throw benign errors after a successful signup.
          // Only show error if account wasn't actually created.
          if (!message.contains('PigeonUserDetails')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.signupFailed),
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
            AuthHeader(
              title: context.l10n.createYourAccount,
              subtitle: context.l10n.signupSubtitle,
              showBack: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthField(
                      controller: _nameController,
                      label: context.l10n.fullName,
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? context.l10n.enterName
                              : null,
                    ),
                    const SizedBox(height: 16),
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
                          return context.l10n.enterAPassword;
                        }
                        if (value.length < 6) {
                          return context.l10n.passwordMin6;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.atLeast6,
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      controller: _confirmPasswordController,
                      label: context.l10n.confirmPassword,
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirmPassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textLight,
                          size: 20,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.pleaseConfirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return context.l10n.passwordsDontMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Terms
                    InkWell(
                      onTap: () =>
                          setState(() => _agreeToTerms = !_agreeToTerms),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                onChanged: (v) => setState(
                                    () => _agreeToTerms = v ?? false),
                                activeColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(text: context.l10n.iAgreeToThe),
                                    TextSpan(
                                      text: context.l10n.terms,
                                      style: const TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (_) => LegalScreen.terms(),
                                        )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    AuthButton(
                      label: context.l10n.createAccount,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleSignup,
                    ),

                    const SizedBox(height: 24),

                    // Back to sign in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.haveAccount,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                          ),
                          child: Text(
                            context.l10n.signIn,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
