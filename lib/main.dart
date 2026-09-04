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
import 'widgets/app_lock_prompt.dart';
import 'theme/theme_provider.dart';
import 'widgets/add_transaction_dialog.dart';
import 'widgets/contact_sheet.dart';
import 'services/firestore_user_profile_service.dart';
import 'services/device_identity_service.dart';
import 'services/sms_listener_service.dart';
import 'services/foreground_service_handler.dart';
import 'navigation_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase must finish first: the providers built by runApp read the
  // current user immediately.
  await Firebase.initializeApp();
  // Must run before any FlutterForegroundTask call, and before the service
  // is (re)attached to a running isolate on app restart.
  FlutterForegroundTask.initCommunicationPort();
  ForegroundServiceHandler.init();
  // Resolve the device name once here, in the main isolate where platform
  // channels are reliable. The SMS background isolate then just reads the
  // cached value.
  unawaited(DeviceIdentityService.ensureResolved());

  // Paint the UI FIRST. Restarting the SMS listener involves a permission
  // check and starting a foreground service (which deliberately waits for
  // Android to settle), and awaiting all that before runApp held the launch
  // screen on-screen for seconds. Nothing on the first frame depends on it,
  // so it runs in the background and the app opens immediately.
  runApp(const FinWiseApp());

  // Restart the SMS listener + persistent monitoring service if permission
  // was already granted on a previous launch. (First-run permission
  // prompting happens from MainScreen, where there's an Activity to attach
  // the system dialog to — see SmsListenerService.ensureAutoDetectRunning.)
  unawaited(SmsListenerService.startIfEnabled());
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

    // ONLY `paused` counts as leaving the app.
    //
    // `inactive` also fires for things that happen *inside* the app — system
    // permission dialogs, the notification shade, an incoming call banner.
    // Treating those as "user left" meant granting a permission instantly
    // re-locked the app, which looked exactly like a crash and restart.
    if (state == AppLifecycleState.paused) {
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

        // NOT awaited, deliberately. A Firestore write only completes when
        // the SERVER acknowledges it — offline, that Future never resolves,
        // so awaiting it here left the app stuck on the loading spinner with
        // no error and no way forward. Firestore still applies the write to
        // its local cache immediately and syncs it whenever connectivity
        // returns, so nothing is lost by letting it finish in the
        // background. Startup must never depend on the network.
        unawaited(
          profileService.createProfileIfNeeded(
            uid: user.uid,
            email: user.email,
            name: (user.displayName?.trim().isNotEmpty ?? false)
                ? user.displayName!.trim()
                : (localName?.trim().isNotEmpty ?? false)
                    ? localName!.trim()
                    : null,
          ),
        );

        // If local onboarding flag is false but Firestore says it's complete,
        // hydrate local preferences from the profile so a new device can skip onboarding.
        if (!completed) {
          try {
            // Time-boxed: this read only matters for restoring onboarding on
            // a NEW device. On a slow or absent connection it must not hold
            // the launch screen — falling back to local state is correct and
            // the user simply keeps whatever onboarding state this device has.
            final remote = await profileService
                .getProfile(user.uid)
                .timeout(const Duration(seconds: 4));
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

  /// Drives the swipeable tab body, kept in sync with the bottom nav bar in
  /// both directions: tapping a nav item animates the page, and swiping
  /// updates which nav item is highlighted.
  final PageController _pageController = PageController();

  /// While the app is on screen, re-read the local cache every few seconds
  /// so transactions the SMS background isolate recorded show up live —
  /// even when the user just sits on the open screen and never leaves it.
  Timer? _cacheRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // First-run permission flow, deliberately sequenced.
      //
      // Firing the SMS prompt, the notification prompt and the app-lock
      // dialog back-to-back made the app appear to close: system dialogs
      // fought each other and one of them used to launch an external
      // settings screen. Now each step waits for the previous one to settle,
      // and nothing navigates away from the app.
      // Permission prompts make Android report the app as backgrounded.
      // Suppress the auto-lock across them so granting a permission doesn't
      // bounce the user to the PIN screen.
      final lock = context.read<AppLockProvider>();
      await lock.withoutLocking(
        () => SmsListenerService.ensureAutoDetectRunning(),
      );
      if (!mounted) return;

      await _drainDetectedTransactions();
      if (!mounted) return;

      // Let the permission dialogs fully dismiss before showing our own.
      // 600ms wasn't enough: if the user was still reading the SMS prompt,
      // this fired while a system dialog was up and the app-lock invitation
      // never appeared at all. Wait until nothing else is on screen.
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // Don't stack our dialog on top of another route (a permission sheet,
      // or the user having navigated somewhere) — try again shortly instead.
      for (var i = 0; i < 10; i++) {
        if (!mounted) return;
        if (ModalRoute.of(context)?.isCurrent ?? true) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (!mounted) return;

      await AppLockPrompt.maybeShow(context);
    });
    _startCacheRefreshTimer();
  }

  @override
  void dispose() {
    _cacheRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  /// Bottom nav tap → animate the page. Swiping the page itself updates
  /// [_currentIndex] straight from PageView's onPageChanged, so both ways of
  /// navigating stay in sync.
  void _goToTab(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
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
    return Scaffold(
      // Swipeable: dragging left/right moves between tabs, same as tapping
      // the bottom nav bar. Each tab is wrapped in _KeepAlivePage so its
      // scroll position and state survive swiping away and back.
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          _KeepAlivePage(child: HomeScreen()),
          _KeepAlivePage(child: CategoriesScreen()),
          _KeepAlivePage(child: GoalsScreen()),
          _KeepAlivePage(child: TransactionsScreen()),
          _KeepAlivePage(child: SettingsScreen()),
        ],
      ),
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
          onTap: _goToTab,
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
      // Right side, stacked: the help shortcut sits just above the "Add
      // transaction" button rather than off on its own on the left.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HelpButton(onTap: () => showContactSheet(context)),
          const SizedBox(height: 12),
          FloatingActionButton(
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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Keeps a tab's state (scroll position, in-progress input, etc.) alive when
/// swiped away and back, instead of rebuilding it from scratch every time —
/// same behavior tapping the bottom nav bar already had.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;

  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Small "need help?" shortcut, visible on every tab. Opens the FAQ /
/// email / WhatsApp contact sheet — see [showContactSheet].
class _HelpButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HelpButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.help_outline,
            color: AppTheme.primaryColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
