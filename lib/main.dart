import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'providers/transaction_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/category_provider.dart';
import 'theme/theme_provider.dart';
import 'widgets/add_transaction_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FinWiseApp());
}

class FinWiseApp extends StatelessWidget {
  const FinWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'FinWise',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            home: const _InitialScreen(),
          );
        },
      ),
    );
  }
}

class _InitialScreen extends StatefulWidget {
  const _InitialScreen();

  @override
  State<_InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<_InitialScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndOnboarding();
    // Listen to auth state changes - this will automatically update the UI
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        // Small delay to ensure Firebase state is fully updated
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _checkAuthAndOnboarding();
          }
        });
      }
    });
  }

  Future<void> _checkAuthAndOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Firebase auth check
      final authenticated = FirebaseAuth.instance.currentUser != null;
      final completed = prefs.getBool('onboarding_complete') ?? false;
      
      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
          _onboardingComplete = completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Error checking auth/onboarding - will be handled by showing login screen
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _onboardingComplete = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Show login if not authenticated
    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    // Show onboarding if authenticated but not completed
    if (!_onboardingComplete) {
      return const WelcomeScreen();
    }

    // Show main app
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = const HomeScreen();
        break;
      case 1:
        currentScreen = const CategoriesScreen();
        break;
      case 2:
        currentScreen = const GoalsScreen();
        break;
      case 3:
        currentScreen = const TransactionsScreen();
        break;
      case 4:
        currentScreen = const SettingsScreen();
        break;
      default:
        currentScreen = const HomeScreen();
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textLight,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTransactionDialog(
              onSave: (transaction) {
                Provider.of<TransactionProvider>(context, listen: false)
                    .addTransaction(transaction);
              },
            ),
          );
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
