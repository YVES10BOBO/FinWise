import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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
import 'providers/currency_provider.dart';
import 'providers/income_provider.dart';
import 'providers/app_lock_provider.dart';
import 'screens/lock/pin_screen.dart';
import 'theme/theme_provider.dart';
import 'widgets/add_transaction_dialog.dart';
import 'services/firestore_user_profile_service.dart';
import 'services/sms_listener_service.dart';
import 'services/foreground_service_handler.dart';
import 'navigation_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Must run before any FlutterForegroundTask call, and before the service
  // is (re)attached to a running isolate on app restart.
  FlutterForegroundTask.initCommunicationPort();
  ForegroundServiceHandler.init();
  // Restart the SMS listener + persistent monitoring service if permission
  // was already granted on a previous launch. (First-run permission
  // prompting happens from MainScreen, where there's an Activity to attach
  // the system dialog to — see SmsListenerService.ensureAutoDetectRunning.)
  await SmsListenerService.startIfEnabled();
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
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
          ChangeNotifierProvider(create: (_) => IncomeProvider()),
          ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'FinWise',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            home: const AppLockGate(child: InitialScreen()),
          );
        },
      ),
    );
  }
}

/// Wraps the whole app in the PIN/biometric lock.
///
/// Firebase sign-in keeps you logged in indefinitely, which means anyone
/// holding an already-unlocked phone could otherwise read every balance and
/// transaction. This gate re-verifies the person on cold start and after the
/// app has been away for longer than the configured timeout.
class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = context.read<AppLockProvider>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      lock.onPaused();
    } else if (state == AppLifecycleState.resumed) {
      lock.onResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLockProvider>(
      builder: (context, lock, child) {
        // Wait for stored settings before deciding — avoids a flash of the
        // dashboard before the lock appears.
        if (!lock.isLoaded) {
          return const Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (lock.isEnabled && lock.isLocked) {
          return const PinScreen(mode: PinMode.unlock);
        }

        return widget.child;
      },
    );
  }
}

// Public wrapper for navigation from auth screens
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InitialScreen();
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
      final user = FirebaseAuth.instance.currentUser;
      final authenticated = user != null;
      bool completed = prefs.getBool('onboarding_complete') ?? false;

      // Ensure user profile doc exists in Firestore (helps debugging + multi-device)
      if (user != null) {
        final localName = prefs.getString('user_name');
        final profileService = FirestoreUserProfileService();

        await profileService.createProfileIfNeeded(
          uid: user.uid,
          email: user.email,
          name: (user.displayName?.trim().isNotEmpty ?? false)
              ? user.displayName!.trim()
              : (localName?.trim().isNotEmpty ?? false)
                  ? localName!.trim()
                  : null,
        );

        // If local onboarding flag is false but Firestore says it's complete,
        // hydrate local preferences from the profile so a new device can skip onboarding.
        if (!completed) {
          try {
            final remote = await profileService.getProfile(user.uid);
            if (remote != null && (remote['onboardingComplete'] == true)) {
              completed = true;

              // Restore key onboarding values locally when present.
              final remoteName = remote['name'] as String?;
              final income = (remote['income'] as num?)?.toDouble();
              final freq = remote['incomeFrequency'] as String?;
              final spendingStyle = remote['spendingStyle'] as String?;
              final categoriesDynamic = remote['categories'];
              final categories = categoriesDynamic is List
                  ? categoriesDynamic.map((e) => e.toString()).toList()
                  : <String>[];

              if (remoteName != null && remoteName.trim().isNotEmpty) {
                await prefs.setString('user_name', remoteName.trim());
              }
              if (income != null) {
                await prefs.setString('user_income', income.toStringAsFixed(0));
              }
              if (freq != null && freq.isNotEmpty) {
                await prefs.setString('income_frequency', freq);
              }
              if (spendingStyle != null && spendingStyle.isNotEmpty) {
                await prefs.setString('spending_style', spendingStyle);
              }
              if (categories.isNotEmpty) {
                await prefs.setStringList('user_categories', categories);
              }
              await prefs.setBool('questionnaire_complete', true);
              await prefs.setBool('onboarding_complete', true);
            }
          } catch (_) {
            // If profile fetch fails, we just keep local state.
          }
        }
      }
      
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  /// While the app is on screen, re-read the local cache every few seconds
  /// so transactions the SMS background isolate recorded show up live —
  /// even when the user just sits on the open screen and never leaves it.
  Timer? _cacheRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Turn on auto-detect by default (asks for SMS permission the first
      // time) and start the monitoring service — no toggle-hunting needed.
      await SmsListenerService.ensureAutoDetectRunning();
      await _drainDetectedTransactions();
    });
    _startCacheRefreshTimer();
  }

  @override
  void dispose() {
    _cacheRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startCacheRefreshTimer() {
    _cacheRefreshTimer?.cancel();
    _tickSms();
    // Every 3s while the app is on screen: (1) read the SMS inbox for new
    // Mobile Money messages (reliable foreground detection that doesn't
    // depend on the plugin's flaky foreground callback), then (2) drain any
    // detected transactions into the live balance/history.
    _cacheRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _tickSms();
    });
  }

  Future<void> _tickSms() async {
    if (!mounted) return;
    await SmsListenerService.pollInboxForNew();
    if (!mounted) return;
    await Provider.of<TransactionProvider>(context, listen: false)
        .refreshFromCache();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Coming back to the app — pull in anything detected while away, and
      // resume the live refresh loop.
      _drainDetectedTransactions();
      _startCacheRefreshTimer();
    } else if (state == AppLifecycleState.paused) {
      // No point polling storage while off-screen; the background isolate
      // handles detection there.
      _cacheRefreshTimer?.cancel();
    }
  }

  Future<void> _drainDetectedTransactions() async {
    if (!mounted) return;
    // Pull in anything the SMS handler recorded to its per-item slots while
    // FinWise was off-screen (or on another app), so it lands on the balance.
    await Provider.of<TransactionProvider>(context, listen: false)
        .refreshFromCache();
  }

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
