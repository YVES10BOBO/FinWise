import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';
import '../../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '💰',
                      style: TextStyle(fontSize: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Welcome to FinWise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Smart financial advice for a new era of wealth',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                // Features
                _FeatureItem(
                  icon: '🤖',
                  text: 'AI-Powered Budget Recommendations',
                ),
                const SizedBox(height: 20),
                _FeatureItem(
                  icon: '📊',
                  text: 'Automatic Spending Analysis',
                ),
                const SizedBox(height: 20),
                _FeatureItem(
                  icon: '🎯',
                  text: 'Smart Goal Tracking',
                ),
                const Spacer(),
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ProfileSetupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}
