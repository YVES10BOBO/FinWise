import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';

class AccountConnectionScreen extends StatelessWidget {
  const AccountConnectionScreen({super.key});

  Future<void> _skipConnection(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('account_connected', false);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  Future<void> _connectLater(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('account_connected', false);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Accounts'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect Your Accounts (Optional)',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your bank or mobile money accounts for automatic transaction tracking',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        const Text(
                          'You can skip this step!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'FinWise works perfectly even without connected accounts. You can:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BenefitItem(text: 'Manually enter transactions'),
                    _BenefitItem(text: 'Get AI budget recommendations'),
                    _BenefitItem(text: 'Track spending patterns'),
                    _BenefitItem(text: 'Receive smart financial tips'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Connection Options (for future implementation)
              _ConnectionOption(
                icon: '🏦',
                title: 'Bank Account',
                subtitle: 'Connect via secure API',
                onTap: () {
                  // TODO: Implement bank connection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bank connection coming soon!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _ConnectionOption(
                icon: '📱',
                title: 'Mobile Money',
                subtitle: 'MTN, Airtel, or other providers',
                onTap: () {
                  // TODO: Implement mobile money connection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mobile money connection coming soon!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _connectLater(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: const Text(
                    'Connect Later',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _skipConnection(context),
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
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

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConnectionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
