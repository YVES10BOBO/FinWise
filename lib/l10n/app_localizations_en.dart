// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get later => 'Later';

  @override
  String get clearAll => 'Clear All';

  @override
  String get all => 'All';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get navHome => 'Home';

  @override
  String get navBudget => 'Budget';

  @override
  String get navGoals => 'Goals';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKinyarwanda => 'Kinyarwanda';

  @override
  String get sectionProfile => 'Profile';

  @override
  String get sectionData => 'Data Management';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get sectionAutomation => 'Automation';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionAbout => 'About';

  @override
  String get profileOnboarding => 'Profile & onboarding';

  @override
  String get profileOnboardingSub => 'Update your name and currency';

  @override
  String get incomeTarget => 'Income target';

  @override
  String incomeTargetSet(String amount) {
    return '$amount/month — used to measure your savings rate';
  }

  @override
  String get incomeTargetUnset =>
      'Set an optional target to measure your savings rate';

  @override
  String get logout => 'Logout';

  @override
  String get logoutSub => 'Sign out and return to login';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSub => 'Permanently erase your account and all data';

  @override
  String get calendarView => 'Calendar View';

  @override
  String get calendarViewSub => 'View transactions by date';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get exportCsvSub => 'Download transactions as CSV';

  @override
  String get exportReport => 'Export Report';

  @override
  String get exportReportSub => 'Generate transaction report';

  @override
  String get clearTransactions => 'Clear All Transactions';

  @override
  String get clearTransactionsSub => 'Remove all transaction data';

  @override
  String get clearGoals => 'Clear All Goals';

  @override
  String get clearGoalsSub => 'Remove all goal data';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSub => 'Toggle dark theme';

  @override
  String get currency => 'Currency';

  @override
  String get appVersion => 'App Version';

  @override
  String get loading => 'Loading…';

  @override
  String get faqHelp => 'FAQ & Help';

  @override
  String get faqHelpSub => 'Common questions, or contact us directly';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySub => 'What we collect and what stays on your phone';

  @override
  String get terms => 'Terms & Conditions';

  @override
  String get termsSub => 'The agreement you accepted at sign-up';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodThisYear => 'This year';

  @override
  String periodLastDays(int days) {
    return 'Last $days days';
  }

  @override
  String get periodAllTime => 'All time';

  @override
  String get periodCustom => 'Custom range…';

  @override
  String get showPeriod => 'Show period';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get show => 'Show';

  @override
  String get moneyIn => 'Money in';

  @override
  String get spent => 'Spent';

  @override
  String get left => 'Left';

  @override
  String get savingsRate => 'Savings rate';

  @override
  String setAsideForGoals(String amount) {
    return 'Set aside for goals: $amount';
  }

  @override
  String safeToSpend(String amount) {
    return 'Safe to spend: $amount';
  }

  @override
  String overBy(String amount) {
    return 'You are over by $amount';
  }

  @override
  String youKept(String amount) {
    return 'You kept $amount';
  }

  @override
  String overspentBy(String amount) {
    return 'You overspent by $amount';
  }

  @override
  String earnedPctOfIncome(String pct) {
    return 'earned $pct% of your usual income';
  }

  @override
  String get greatPace => 'Great pace — keep it up.';

  @override
  String get watchSpending => 'Watch your spending to save more.';

  @override
  String get noIncomeCurrent =>
      'Add some income in this period, or set an income target in Settings, to see your savings rate.';

  @override
  String get noIncomePast =>
      'No income recorded in this period. Set an income target in Settings to see your savings rate.';

  @override
  String get historyTitle => 'Transaction History';

  @override
  String get yourHistory => 'Your history';

  @override
  String get historySubtitle =>
      'Search, filter and review all your past transactions in one place.';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get filter => 'Filter';

  @override
  String get filterTitle => 'Filter Transactions';

  @override
  String get filterByType => 'Filter by Type:';

  @override
  String get filterByCategory => 'Filter by Category:';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get items => 'Items';

  @override
  String get noTransactions => 'No transactions found';

  @override
  String get tryAdjusting => 'Try adjusting your search or filters';

  @override
  String nothingInPeriod(String period) {
    return 'Nothing in \"$period\". Try another period, or choose \"All time\".';
  }

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsEmptyTitle => 'Save for what matters';

  @override
  String get goalsEmptyBody =>
      'Set a target, reserve money towards it, and watch your progress. Reserved money stays yours — it just won\'t be counted as spendable.';

  @override
  String get createFirstGoal => 'Create your first goal';

  @override
  String get activeGoals => 'Active goals';

  @override
  String get completed => 'Completed';

  @override
  String get goalsOverview => 'Goals overview';

  @override
  String reservedOfTargeted(String target, String pct) {
    return 'reserved of $target targeted · $pct%';
  }

  @override
  String get total => 'Total';

  @override
  String get active => 'Active';

  @override
  String goalsReady(int count) {
    return '$count goal(s) fully funded — ready to buy';
  }

  @override
  String get statusReady => 'Ready to buy';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusOnTrack => 'On track';

  @override
  String get statusBehind => 'Behind';

  @override
  String get pastDue => 'Past due';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get paid => 'paid';

  @override
  String paidPlanned(String amount) {
    return 'paid · planned $amount';
  }

  @override
  String ofAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get fullyFundedTap => 'Fully funded — tap to mark it bought';

  @override
  String addPerMonth(String amount) {
    return 'Add $amount/month to finish on time';
  }

  @override
  String get addContribution => 'Add contribution';

  @override
  String get details => 'Details';

  @override
  String get reserveMoney => 'Reserve money';

  @override
  String get reserveExplain =>
      'Moves money from an account into this goal. It stays yours — just reserved, so it is not counted as spending.';

  @override
  String get fromAccount => 'From account';

  @override
  String amountWithCode(String code) {
    return 'Amount ($code)';
  }

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get reserve => 'Reserve';

  @override
  String freeAmount(String account, String amount) {
    return '$account · $amount free';
  }

  @override
  String get enterAmountAbove0 => 'Enter an amount above 0';

  @override
  String onlyHasAvailable(String account, String amount) {
    return '$account only has $amount available.';
  }

  @override
  String reservedFrom(String amount, String account) {
    return 'Reserved $amount from $account';
  }

  @override
  String reservedOver(String amount, String over) {
    return 'Reserved $amount — that is $over more than this goal needs. Release it any time.';
  }

  @override
  String get accountCash => 'Cash';

  @override
  String get accountBank => 'Bank';

  @override
  String get accountMobileMoney => 'Mobile Money';

  @override
  String get release => 'Release';

  @override
  String get bought => 'Bought';

  @override
  String target(String date) {
    return 'Target $date';
  }

  @override
  String purchasedOn(String date) {
    return 'Purchased $date';
  }

  @override
  String reservedOfPct(String target, String pct) {
    return 'reserved of $target · $pct%';
  }

  @override
  String paidPlannedCompleted(String amount) {
    return 'paid · planned $amount · completed';
  }

  @override
  String get paidCompleted => 'paid · completed';

  @override
  String readyExtra(String amount) {
    return 'Ready to buy — $amount more than the price is reserved. You can release the extra.';
  }

  @override
  String get fullyFundedBought => 'Fully funded — tap Bought when you buy it.';

  @override
  String stillNeed(String amount, String monthly) {
    return 'Still need $amount · about $monthly/month';
  }

  @override
  String get differentPrice => 'Found a different price? Update price';

  @override
  String plannedPriceChanged(String amount) {
    return 'Planned $amount · Price changed again? Update';
  }

  @override
  String get editGoal => 'Edit goal';

  @override
  String get editGoalSub => 'Name, target amount, date or icon';

  @override
  String get updatePrice => 'Update price';

  @override
  String get updatePriceSub => 'The real price is higher or lower than planned';

  @override
  String get undoPurchase => 'Undo purchase';

  @override
  String get undoPurchaseSub => 'Reopen this goal and reserve again';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String get deleteGoalSub => 'Reserved money returns to available';

  @override
  String get reservedFromTitle => 'Reserved from';

  @override
  String get contributionHistory => 'Contribution history';

  @override
  String get tapToEdit => 'Tap an entry to edit or delete it.';

  @override
  String get undoToEdit => 'Undo the purchase to change these entries.';

  @override
  String get noMoneyReserved => 'No money reserved yet.';

  @override
  String get reservedLabel => 'Reserved';

  @override
  String get releasedLabel => 'Released';

  @override
  String get editOrDelete => 'Edit or delete';

  @override
  String get editThisReserve => 'Edit this reserve';

  @override
  String get editThisRelease => 'Edit this release';

  @override
  String get editEntrySub => 'Change the amount, account or note';

  @override
  String get deleteThisReserve => 'Delete this reserve';

  @override
  String get deleteThisRelease => 'Delete this release';

  @override
  String get deleteReserveSub => 'The money goes back to available';

  @override
  String get deleteReleaseSub => 'The money becomes reserved again';

  @override
  String get editReserve => 'Edit reserve';

  @override
  String get editRelease => 'Edit release';

  @override
  String get releasedTo => 'Released to';

  @override
  String get deleteReserveQ => 'Delete reserve?';

  @override
  String get deleteReleaseQ => 'Delete release?';

  @override
  String deleteReserveBody(String amount) {
    return '$amount will go back to your available money.';
  }

  @override
  String deleteReleaseBody(String amount, String goal) {
    return '$amount will be reserved for \"$goal\" again.';
  }

  @override
  String get entryUpdated => 'Entry updated';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get purchaseSummary => 'Purchase summary';

  @override
  String get planned => 'Planned';

  @override
  String get paidCap => 'Paid';

  @override
  String get underPlan => 'Under plan';

  @override
  String get overPlan => 'Over plan';

  @override
  String paidLessThanPlanned(String amount) {
    return 'You paid $amount less than planned 🎉';
  }

  @override
  String get paidWith => 'Paid with';

  @override
  String get noPaymentLinked => 'No payment linked.';

  @override
  String get priceUpdates => 'Price updates';

  @override
  String celebrateFundedTitle(String goal) {
    return '$goal is fully funded!';
  }

  @override
  String celebrateFundedReserved(String amount) {
    return 'You have $amount reserved.';
  }

  @override
  String celebrateFundedReservedSpan(String amount, String span) {
    return 'You have $amount reserved — saved over $span.';
  }

  @override
  String get celebrateFundedAsk => 'Bought it already? Close the goal now.';

  @override
  String get iBoughtIt => 'I bought it';

  @override
  String get celebrateCompletedTitle => 'Goal completed!';

  @override
  String celebratePaid(String goal, String amount) {
    return '$goal — paid $amount';
  }

  @override
  String celebratePaidUnder(String goal, String amount, String under) {
    return '$goal — paid $amount · $under under plan';
  }

  @override
  String celebrateSavedOver(String span) {
    return 'You saved for it over $span.';
  }

  @override
  String celebrateReturned(String amount) {
    return '$amount went back to your available money.';
  }

  @override
  String get startNewGoal => 'Start a new goal';

  @override
  String get spanLessThanMonth => 'less than a month';

  @override
  String spanMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get goalTitle => 'Goal';

  @override
  String get goalNoLongerExists => 'This goal no longer exists.';

  @override
  String get boughtWithoutReserving =>
      'Bought without reserving money in FinWise first.';

  @override
  String savedOverContributions(String span, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions',
      one: '1 contribution',
    );
    return 'Saved over $span · $_temp0';
  }

  @override
  String missingPayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked payments are',
      one: '1 linked payment is',
    );
    return '$_temp0 no longer in your history.';
  }

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get errUserNotFound =>
      'No account found for that email. Please sign up first.';

  @override
  String get errWrongPassword =>
      'Incorrect password. Please check your password and try again.';

  @override
  String get errInvalidCredential =>
      'Invalid email or password. Please check your credentials.';

  @override
  String get errInvalidEmailEnter =>
      'Invalid email address. Please enter a valid email.';

  @override
  String get errUserDisabled =>
      'This account has been disabled. Please contact support.';

  @override
  String get errTooManyFailed =>
      'Too many failed attempts. Please wait a few minutes and try again.';

  @override
  String get errNetworkInternet =>
      'Network error. Please check your internet connection.';

  @override
  String get errLoginDisabled =>
      'Login is currently disabled. Please contact support.';

  @override
  String get errReLogin => 'Please log out and log in again to continue.';

  @override
  String errLoginFailedCode(String code) {
    return 'Login failed: $code. Please check your email and password.';
  }

  @override
  String get loginFailedRetry => 'Login failed. Please try again.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to keep track of your money';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get newToFinwise => 'New to FinWise?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get agreeTermsRequired => 'Please agree to the terms and conditions';

  @override
  String get accountCreated => 'Account created successfully!';

  @override
  String get errEmailInUse =>
      'That email is already registered. Try logging in instead.';

  @override
  String get errInvalidEmailCheck =>
      'Invalid email address. Please check and try again.';

  @override
  String get errWeakPassword =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get errSignupDisabled =>
      'Signup is currently disabled. Please contact support.';

  @override
  String get errNetworkConnection =>
      'Network error. Please check your connection.';

  @override
  String get signupFailed => 'Signup failed. Please try again.';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get signupSubtitle => 'Start tracking your money in minutes';

  @override
  String get fullName => 'Full name';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get enterAPassword => 'Please enter a password';

  @override
  String get atLeast6 => 'At least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get errNoAccountEmail => 'No account found for that email.';

  @override
  String get errTooManyAttempts => 'Too many attempts. Please try again later.';

  @override
  String get resetEmailFailed =>
      'Failed to send reset email. Please try again.';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get resetLinkSent => 'We sent you a link to set a new password';

  @override
  String get resetEnterEmail =>
      'Enter your email and we\'ll send reset instructions';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get emailSent => 'Email sent';

  @override
  String resetSentTo(String email) {
    return 'We sent reset instructions to\n$email';
  }

  @override
  String get checkSpam =>
      'Can\'t find it? Check your spam or promotions folder. The email may take a few minutes to arrive.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get sendAgain => 'Send it again';

  @override
  String get freqDaily => 'Daily';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqYearly => 'Yearly';

  @override
  String get freqIrregular => 'Irregular';

  @override
  String get pinsDidNotMatch => 'PINs did not match. Start again.';

  @override
  String get tooManyWait => 'Too many attempts. Please wait.';

  @override
  String incorrectPinLeft(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left tries',
      one: '1 try',
    );
    return 'Incorrect PIN. $_temp0 left before a wait.';
  }

  @override
  String get incorrectPinRetry => 'Incorrect PIN. Try again.';

  @override
  String get createPin => 'Create a PIN';

  @override
  String get confirmYourPin => 'Confirm your PIN';

  @override
  String get enterYourPin => 'Enter your PIN';

  @override
  String get confirmItsYou => 'Confirm it\'s you';

  @override
  String get pinUseToOpen => 'You\'ll use this to open FinWise';

  @override
  String get pinSameAgain => 'Enter the same 4 digits again';

  @override
  String get financesLocked => 'Your finances are locked';

  @override
  String get enterCurrentPin => 'Enter your current PIN to continue';

  @override
  String tooManyTryIn(String time) {
    return 'Too many attempts. Try again in $time';
  }

  @override
  String get forgotPinQ => 'Forgot PIN?';

  @override
  String get forgotYourPin => 'Forgot your PIN?';

  @override
  String get forgotPinBody =>
      'To reset it, sign in again with your email and password.\n\nYou will be signed out and the app lock removed. Your transactions and goals are safe — they sync back as soon as you sign in.';

  @override
  String get signOutReset => 'Sign out & reset';

  @override
  String get welcomeTitle => 'Welcome to FinWise';

  @override
  String get welcomeTagline => 'Smart financial advice for a new era of wealth';

  @override
  String get welcomeFeat1 => 'Smart budget recommendations';

  @override
  String get welcomeFeat2 => 'Automatic spending analysis';

  @override
  String get welcomeFeat3 => 'Goal tracking that keeps you focused';

  @override
  String get getStarted => 'Get Started';

  @override
  String get setupProfile => 'Setup Profile';

  @override
  String get getToKnowYou => 'Let\'s get to know you';

  @override
  String get personalizedGuidance =>
      'This helps us provide personalized financial guidance';

  @override
  String get yourName => 'Your Name';

  @override
  String get currencyAdapts => 'Wherever you are — FinWise adapts to it';

  @override
  String monthlyIncomeCode(String code) {
    return 'Monthly Income ($code)';
  }

  @override
  String get approximateFine => 'Approximate is fine';

  @override
  String get enterIncome => 'Please enter your income';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get incomeFrequency => 'Income Frequency';

  @override
  String get dontWorryUpdate =>
      'Don\'t worry! You can always update this later. We\'ll provide guidance even with approximate values.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catRent => 'Rent';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catVacation => 'Vacation';

  @override
  String get catClothes => 'Clothes';

  @override
  String get catWater => 'Water';

  @override
  String get catShoes => 'Shoes';

  @override
  String get catHealth => 'Health';

  @override
  String get catEducation => 'Education';

  @override
  String get catFamily => 'Family & Support';

  @override
  String get catDebt => 'Debt & Loans';

  @override
  String get catBusiness => 'Business';

  @override
  String get catGiving => 'Giving & Church';

  @override
  String get catFees => 'Fees & Taxes';

  @override
  String get catPersonal => 'Personal Care';

  @override
  String get catMedicine => 'Medicine';

  @override
  String get catAlcohol => 'Alcohol & Drinks';

  @override
  String get catTobacco => 'Tobacco';

  @override
  String get catIncome => 'Income';

  @override
  String get catSavings => 'Savings';

  @override
  String get catOther => 'Other';

  @override
  String get reasonNecessity => 'Necessity';

  @override
  String get reasonBusiness => 'Business';

  @override
  String get reasonEnjoyment => 'Enjoyment';

  @override
  String get reasonEmergency => 'Emergency';

  @override
  String get curRwf => 'Rwandan Franc';

  @override
  String get curUsd => 'US Dollar';

  @override
  String get curEur => 'Euro';

  @override
  String get curGbp => 'British Pound';

  @override
  String get curKes => 'Kenyan Shilling';

  @override
  String get curUgx => 'Ugandan Shilling';

  @override
  String get curTzs => 'Tanzanian Shilling';

  @override
  String get curNgn => 'Nigerian Naira';

  @override
  String get curGhs => 'Ghanaian Cedi';

  @override
  String get curZar => 'South African Rand';

  @override
  String get curXaf => 'Central African CFA Franc';

  @override
  String get curCad => 'Canadian Dollar';

  @override
  String get curInr => 'Indian Rupee';

  @override
  String get giSavings => 'Savings';

  @override
  String get giLaptop => 'Laptop';

  @override
  String get giCar => 'Car';

  @override
  String get giHouse => 'House';

  @override
  String get giLand => 'Land / Plot';

  @override
  String get giEducation => 'Education';

  @override
  String get giBusiness => 'Business';

  @override
  String get giTravel => 'Travel';

  @override
  String get giWedding => 'Wedding';

  @override
  String get giFamily => 'Family';

  @override
  String get giHealth => 'Health';

  @override
  String get giEmergency => 'Emergency fund';

  @override
  String get giPhone => 'Phone';

  @override
  String get giFurniture => 'Furniture';

  @override
  String get giClothes => 'Clothes';

  @override
  String get giGaming => 'Gaming';

  @override
  String get giDebt => 'Pay off debt';

  @override
  String get giGift => 'Gift';

  @override
  String get giOther => 'Other';

  @override
  String get enterRealPrice => 'Enter the real price.';

  @override
  String haveEnoughExtra(String amount) {
    return 'You already have enough — ready to buy. $amount extra reserved can go back to available.';
  }

  @override
  String get haveExactlyEnough =>
      'You already have exactly enough — ready to buy.';

  @override
  String willStillNeed(String amount) {
    return 'You will still need $amount.';
  }

  @override
  String realPriceIntro(String planned, String current) {
    return 'Found the real price in a shop or online? Your goal will follow it. Planned: $planned$current.';
  }

  @override
  String currentPrice(String amount) {
    return ' · current: $amount';
  }

  @override
  String realPriceCode(String code) {
    return 'Real price ($code)';
  }

  @override
  String priceUpdatedExtra(String amount) {
    return 'Price updated. $amount more than needed is reserved.';
  }

  @override
  String priceUpdatedTo(String amount) {
    return 'Price updated to $amount.';
  }

  @override
  String get releaseExtra => 'Release extra';

  @override
  String get noteDown => 'Price went down';

  @override
  String get update => 'Update';

  @override
  String get releaseReserved => 'Release reserved money';

  @override
  String releaseExplain(String amount) {
    return 'Returns money from this goal back to your available balance. Currently reserved: $amount';
  }

  @override
  String amountToRelease(String code) {
    return 'Amount to release ($code)';
  }

  @override
  String get noteReleasedAll => 'Released all';

  @override
  String get releaseAll => 'Release all';

  @override
  String releasedBack(String amount) {
    return 'Released $amount back to available';
  }

  @override
  String get markAsBought => 'Mark as bought';

  @override
  String get alreadyRecorded => 'Did you already record this purchase?';

  @override
  String get linkExisting => 'Link existing';

  @override
  String get createNew => 'Create new';

  @override
  String get tickPayments => 'Tick the payment(s) for this purchase';

  @override
  String get amountEveryPayment => 'Enter an amount on every payment';

  @override
  String get moreThanHolds => 'More than the account holds';

  @override
  String accountShows(String account, String amount) {
    return '$account shows $amount';
  }

  @override
  String get recordNegative =>
      'Recording this will leave it negative. If the purchase really happened, record it anyway — you may just need to add some missing income.';

  @override
  String get goBack => 'Go back';

  @override
  String get recordAnyway => 'Record anyway';

  @override
  String boughtDesc(String goal) {
    return 'Bought: $goal';
  }

  @override
  String get noExpensesToLink =>
      'No expenses in your history to link. Switch to \"Create new\".';

  @override
  String get tickEveryPayment =>
      'Tick every payment for this item — paid part by Mobile Money and part in cash? Tick both. Nothing new will be created.';

  @override
  String get searchNameAmount => 'Search by name or amount';

  @override
  String get matchesPrice => '  ·  matches price';

  @override
  String get recordWhatPaid =>
      'Record what you paid. Paid from more than one account? Add a payment for each.';

  @override
  String get paidFrom => 'Paid from';

  @override
  String get amount => 'Amount';

  @override
  String get addAnotherPayment => 'Add another payment';

  @override
  String get expenseCategory => 'Expense category';

  @override
  String get nothingSelected => 'Nothing selected yet.';

  @override
  String underYourPrice(String amount) {
    return '$amount under your price 🎉';
  }

  @override
  String overYourPrice(String amount) {
    return '$amount over your price';
  }

  @override
  String get exactlyYourPrice => 'Exactly your price';

  @override
  String totalPaidPrice(String total, String price) {
    return 'Total paid: $total  ·  price $price';
  }

  @override
  String completedAt(String amount) {
    return 'The goal will be completed at $amount.';
  }

  @override
  String goalCompletedAt(String amount) {
    return 'Goal completed at $amount.';
  }

  @override
  String returnedToAvailable(String amount) {
    return '$amount returned to available.';
  }

  @override
  String underPlanParty(String amount) {
    return '$amount under plan 🎉';
  }

  @override
  String undoCreatedDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count expenses',
      one: 'The expense',
    );
    return '$_temp0 FinWise created for this purchase will be deleted.';
  }

  @override
  String undoLinkedStay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count linked payments stay',
      one: 'The linked payment stays',
    );
    return '$_temp0 in your history — just unlinked.';
  }

  @override
  String willBeReservedAgain(String amount) {
    return 'Your $amount will be reserved again.';
  }

  @override
  String reopenGoal(String goal) {
    return 'Reopen \"$goal\"?';
  }

  @override
  String get undoneCreatedRemoved =>
      'Purchase undone and the created expense removed.';

  @override
  String get undoneKept =>
      'Purchase undone. Your payments were kept in history.';

  @override
  String get undo => 'Undo';

  @override
  String deleteGoalReserved(String goal, String amount) {
    return 'Delete \"$goal\"? The $amount reserved will return to your available balance.';
  }

  @override
  String deleteGoalNoUndo(String goal) {
    return 'Delete \"$goal\"? This cannot be undone.';
  }

  @override
  String get noteGoalDeleted => 'Goal deleted';

  @override
  String returnedToBalance(String amount) {
    return '$amount returned to your available balance';
  }

  @override
  String versionBuild(String version, String build) {
    return '$version (Build $build)';
  }

  @override
  String get clearTransactionsConfirm =>
      'Are you sure you want to delete all transactions? This action cannot be undone.';

  @override
  String get transactionsCleared => 'All transactions cleared';

  @override
  String get incomeTargetExplain =>
      'A planning target only — used to measure your savings rate. It is never added to your balance.';

  @override
  String get howOften => 'How often';

  @override
  String get clear => 'Clear';

  @override
  String get noTxToExport => 'No transactions to export';

  @override
  String exportedAs(String format) {
    return 'Transactions exported successfully as $format';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get clearGoalsConfirm =>
      'Are you sure you want to delete all goals? This action cannot be undone.';

  @override
  String get goalsCleared => 'All goals cleared';

  @override
  String get deleteAccountQ => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes:\n\n• All your transactions\n• All your goals and reserved money\n• Your profile and settings\n• Your sign-in account\n\nThis cannot be undone. Consider exporting your data first (Data Management → Export).';

  @override
  String enterSignInPassword(String email) {
    return 'Enter the password you use to sign in to FinWise$email.';
  }

  @override
  String get notAppLockPin => 'This is not your app-lock PIN.';

  @override
  String get signInPassword => 'Sign-in password';

  @override
  String get accountDeleted => 'Your account has been deleted';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get logoutConfirm =>
      'Are you sure you want to logout? You will need to login again to access the app.';

  @override
  String get loggedOut => 'You\'ve been logged out successfully';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get editGoalTitle => 'Edit Goal';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get goalName => 'Goal Name';

  @override
  String get enterGoalName => 'Please enter goal name';

  @override
  String targetAmountCode(String code) {
    return 'Target Amount ($code)';
  }

  @override
  String get enterTargetAmount => 'Please enter target amount';

  @override
  String get enterValidNumberShort => 'Please enter valid number';

  @override
  String get targetDate => 'Target Date';

  @override
  String get add => 'Add';

  @override
  String get changeCurrencyQ => 'Change currency?';

  @override
  String changeCurrencyBody(String from, String to) {
    return 'Your existing transactions will NOT be converted.\n\nAn amount recorded as 500 $from will simply display as 500 $to — the number stays the same, only the label changes.\n\nChange currency only if you entered those amounts in $to, or if you plan to clear your data.';
  }

  @override
  String changeTo(String code) {
    return 'Change to $code';
  }

  @override
  String get chooseCurrency => 'Choose your currency';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockOnSub => 'FinWise asks for your PIN when opened';

  @override
  String get appLockOffSub => 'Require a PIN to open FinWise';

  @override
  String get unlockFingerprint => 'Unlock with fingerprint';

  @override
  String get fingerprintSub =>
      'Use your fingerprint or face instead of the PIN';

  @override
  String get noFingerprint => 'No fingerprint or face set up on this phone';

  @override
  String get lockAfter => 'Lock after';

  @override
  String get lockImmediately => 'Immediately when you leave the app';

  @override
  String lockAfterMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'After $_temp0 away';
  }

  @override
  String get instant => 'Instant';

  @override
  String minShort(int n) {
    return '$n min';
  }

  @override
  String get changePin => 'Change PIN';

  @override
  String get changePinSub => 'Set a new 4-digit PIN';

  @override
  String get lockNow => 'Lock now';

  @override
  String get lockNowSub => 'Immediately require the PIN';

  @override
  String get useFingerprintQ => 'Use fingerprint?';

  @override
  String get useFingerprintBody =>
      'Unlock FinWise with your fingerprint or face instead of typing the PIN each time. Your PIN still works as a backup.';

  @override
  String get notNow => 'Not now';

  @override
  String get enable => 'Enable';

  @override
  String get appLockOn => 'App lock is on';

  @override
  String get turnOffLock => 'Turn off app lock';

  @override
  String get lockTurnedOff => 'App lock turned off';

  @override
  String get enterCurrentPinTitle => 'Enter current PIN';

  @override
  String get setNewPin => 'Set a new PIN';

  @override
  String get pinUpdated => 'PIN updated';

  @override
  String get protectFinances => 'Protect your finances';

  @override
  String get protectBody =>
      'Add a PIN so only you can open FinWise. Signing in keeps you logged in, so without a lock anyone holding your phone could see your balance and transactions.';

  @override
  String get setUpPin => 'Set up PIN';

  @override
  String get nameThisPhone => 'Name this phone';

  @override
  String get nameThisPhoneBody =>
      'Transactions recorded on this phone are labelled with this name, so you can tell them apart from ones recorded on your other devices.';

  @override
  String get deviceName => 'Device name';

  @override
  String get thisPhone => 'This phone';

  @override
  String get namingDevice => 'Naming this device…';

  @override
  String shownOnTx(String name) {
    return '$name — shown on transactions recorded here';
  }

  @override
  String get needHelp => 'Need help?';

  @override
  String get needHelpBody =>
      'Most questions are answered in the FAQ. If not, reach out directly and we\'ll get back to you.';

  @override
  String get browseFaq => 'Browse FAQ';

  @override
  String get browseFaqSub => 'Answers to common questions about FinWise';

  @override
  String get emailUs => 'Email us';

  @override
  String get noEmailApp => 'Could not open an email app';

  @override
  String get whatsappUs => 'WhatsApp us';

  @override
  String get whatsappSub => 'Chat with us on WhatsApp';

  @override
  String get whatsappPreview => 'WhatsApp preview';

  @override
  String get finwiseSupport => 'FinWise Support';

  @override
  String get whatsappGreeting =>
      'Hi! Have a question about FinWise, or need help with something? Send us a message and we\'ll get back to you as soon as we can.';

  @override
  String get noWhatsapp => 'Could not open WhatsApp';

  @override
  String get openChat => 'Open chat';

  @override
  String get smsBlocked => 'SMS permission is blocked';

  @override
  String get smsBlockedBody =>
      'Android has stopped asking because the permission was declined before. To turn auto-detect on, allow SMS for FinWise in your phone settings:\n\nPermissions → SMS → Allow';

  @override
  String get openSettings => 'Open settings';

  @override
  String get smsNotGrantedOff =>
      'SMS permission was not granted, so auto-detect stays off.';

  @override
  String get smsNotGranted => 'SMS permission not granted';

  @override
  String get smsBlockedSwitch =>
      'Android has blocked this permission because it was declined before, so the switch above can\'t turn it on. Allow SMS for FinWise in phone settings, then come back.';

  @override
  String get smsNeedsPermission =>
      'Auto-detect needs permission to read Mobile Money messages. Turn the switch on to grant it.';

  @override
  String get openPhoneSettings => 'Open phone settings';

  @override
  String get autoDetectStopped => 'Auto-detect has stopped working';

  @override
  String get autoDetectStoppedBody =>
      'Messages haven\'t been checked in over a day. Turn the switch off and on again to re-grant SMS permission, and make sure FinWise isn\'t battery-restricted.';

  @override
  String get fixBattery => 'Fix battery settings';

  @override
  String get nothingDetected => 'Nothing detected in a while';

  @override
  String lastDetectedCheck(String ago) {
    return 'Last transaction detected $ago. If you have used Mobile Money since then, check that FinWise still has SMS permission and is not battery-restricted.';
  }

  @override
  String lastDetected(String ago) {
    return 'Last transaction detected $ago.';
  }

  @override
  String get watchingNothingYet =>
      'Watching for Mobile Money messages. Nothing detected yet.';

  @override
  String get waitingFirst => 'Waiting for the first Mobile Money message.';

  @override
  String get autoDetectWorking => 'Auto-detect is working';

  @override
  String get improveBackground => 'Improve background detection';

  @override
  String get improveBackgroundBody =>
      'Android may delay detection to save battery. Mark FinWise as \"Unrestricted\" so messages are picked up promptly.';

  @override
  String minAgo(int n) {
    return '$n min ago';
  }

  @override
  String hoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours',
      one: '1 hour',
    );
    return '$_temp0 ago';
  }

  @override
  String daysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0 ago';
  }

  @override
  String get autoDetectTitle => 'Auto-detect Mobile Money transactions';

  @override
  String get autoDetectSub =>
      'Reads MoMo and bank SMS on this device and records transactions automatically. Message content never leaves your phone. A permanent notification is shown while this is on, so Android keeps detecting even when you\'re in another app.';

  @override
  String get selectCategory => 'Please select a category';

  @override
  String get transactionWord => 'Transaction';

  @override
  String categoryAdded(String name) {
    return 'Category \"$name\" added';
  }

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String recordedThisPhone(String name) {
    return 'Recorded on this phone ($name)';
  }

  @override
  String recordedOtherPhone(String name) {
    return 'Recorded on another phone ($name)';
  }

  @override
  String get originalMessage => 'Original message';

  @override
  String get account => 'Account';

  @override
  String get enterAmount => 'Please enter amount';

  @override
  String get category => 'Category';

  @override
  String categoriesCount(int count) {
    return '$count categories';
  }

  @override
  String get addCustomCategory => 'Add Custom Category';

  @override
  String get enterCategoryName => 'Enter category name...';

  @override
  String get yourCustomCategories => 'Your Custom Categories:';

  @override
  String get customCategoriesNote =>
      'FinWise will group these under the closest main category so your budgets stay simple.';

  @override
  String get whySpending => 'Why are you spending this?';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionQ =>
      'Are you sure you want to delete this transaction?';

  @override
  String get autoDetectedTip =>
      'Auto-detected from Mobile Money SMS — tap to review';

  @override
  String get autoBadge => 'Auto';

  @override
  String todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get viewAll => 'View all →';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get hello => 'Hello';

  @override
  String get manageWisely => 'Let\'s manage your money wisely';

  @override
  String get expenses => 'Expenses';

  @override
  String get startTracking => 'Start Tracking Your Finances';

  @override
  String get tapPlusFirst => 'Tap the + button to add your first transaction';

  @override
  String get totalAmount => 'Total';

  @override
  String get available => 'Available';

  @override
  String get accountsOverview => 'Accounts overview';

  @override
  String get balanceReservedAvailable => 'Balance · reserved · available';

  @override
  String get momoShort => 'MoMo';

  @override
  String shortBy(String amount) {
    return 'short $amount';
  }

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get userFallback => 'User';

  @override
  String get healthExcellent => 'Excellent';

  @override
  String get healthGood => 'Good';

  @override
  String get healthFair => 'Fair';

  @override
  String get healthNeedsImprovement => 'Needs Improvement';

  @override
  String get healthCritical => 'Critical';

  @override
  String get adviceExcellent =>
      'Keep up the great work! You\'re managing your finances excellently.';

  @override
  String get adviceGood =>
      'You\'re doing well! Consider increasing your savings rate.';

  @override
  String get adviceFair =>
      'Try to reduce expenses and set some financial goals.';

  @override
  String get adviceNeeds =>
      'Focus on spending less than you earn and create a budget.';

  @override
  String get adviceCritical =>
      'Start by tracking all expenses and creating a savings plan.';

  @override
  String get financialHealth => 'Financial Health';

  @override
  String profileIncomeUsed(String amount) {
    return 'Profile income used: $amount per month';
  }

  @override
  String get notAvailable => 'N/A';

  @override
  String get srGood => 'Good! 👍';

  @override
  String get srOverspending => 'Spending more than income';

  @override
  String get savingsRateTitle => 'Savings Rate';

  @override
  String get usingProfileIncome =>
      'Using your profile income (from onboarding) since no income transactions added yet.';

  @override
  String get basedOnTracked =>
      'Based on your tracked income and expenses from transactions.';

  @override
  String get saved => 'Saved';

  @override
  String get thisMonthLower => 'This month';

  @override
  String get smartTip => 'SMART TIP';

  @override
  String get notEnoughCashFlow => 'Not enough data yet for a cash flow view';

  @override
  String get moneyInVsOut => 'Money in vs out';

  @override
  String get inShort => 'In';

  @override
  String get outShort => 'Out';

  @override
  String monthKept(String amount) {
    return 'This month you kept $amount';
  }

  @override
  String monthOverspent(String amount) {
    return 'This month you spent $amount more than you earned';
  }

  @override
  String get noSpending4Weeks => 'No spending recorded in the last 4 weeks';

  @override
  String get spendingTrend => 'Spending trend · Last 4 weeks';

  @override
  String weekSpentMore(String pct) {
    return 'This week you spent $pct% more than last week';
  }

  @override
  String weekSpentLess(String pct) {
    return 'This week you spent $pct% less than last week';
  }

  @override
  String averagePerWeek(String amount) {
    return 'Average $amount per week';
  }

  @override
  String get whyYouSpend => 'Why you spend';

  @override
  String get tagReasonsHint =>
      'Tag a few expenses as necessity, enjoyment, business or emergency to see what share of your money is essential.';

  @override
  String get whyYouSpentMonth => 'Why you spent · This month';

  @override
  String necessityShare(String pct) {
    return '$pct% of your spending was on necessities';
  }

  @override
  String notTagged(String amount) {
    return '$amount not tagged with a reason';
  }

  @override
  String get spendingByCategoryMonth => 'Spending by category · This month';

  @override
  String get noSpendingMonth => 'No spending recorded this month yet.';

  @override
  String get topCategories => 'Top Spending Categories';

  @override
  String get thisMonthTitle => 'This Month';

  @override
  String pctOfTotal(String pct) {
    return '$pct% of total spending';
  }

  @override
  String get noSpendingData => 'No spending data to display';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get spendingCategories => 'Spending Categories';

  @override
  String get categoriesIntro =>
      'FinWise groups your expenses into simple categories so you can quickly see where your money goes.';

  @override
  String get budgetsIntro =>
      'Budgets here use your profile income from onboarding plus your real spending from transactions.';

  @override
  String get categoryInsight => 'Category insight';

  @override
  String get calMonth => 'Month';

  @override
  String get calTwoWeeks => '2 Weeks';

  @override
  String get calWeek => 'Week';

  @override
  String txCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get noTxThisDay => 'No transactions on this day';

  @override
  String get addForThisDate =>
      'Add an income or expense for this date to see it here.';

  @override
  String get transferBetweenAccounts => 'Transfer between accounts';

  @override
  String get transferFee => 'Transfer fee';

  @override
  String transferConfirmation(String details) {
    return 'Transfer confirmation: $details';
  }

  @override
  String get errGoalNotFound => 'Goal not found';

  @override
  String get errOverRelease =>
      'That would release more than was reserved. Delete or reduce the release first.';

  @override
  String get errOverReleaseAccount =>
      'That would release more from an account than was reserved from it.';

  @override
  String get insightStart =>
      'Start tracking your expenses to get personalized insights!';

  @override
  String insightHighCategory(
      String pct, String category, String amount, String symbol) {
    return 'You\'re spending $pct% on $category. Consider reducing by $amount $symbol to improve your savings rate.';
  }

  @override
  String insightLowSavings(String pct) {
    return 'Your savings rate is $pct%. Try to save at least 20% of your income for better financial health.';
  }

  @override
  String get insightGreat =>
      'Great job! You\'re managing your finances well. Keep tracking to maintain good habits!';

  @override
  String get delNotSignedIn => 'You are not signed in.';

  @override
  String get delNoEmail =>
      'This account has no email sign-in, so it cannot be verified this way. Please contact support.';

  @override
  String get delWrongPassword =>
      'Incorrect password. Use the password you sign in to FinWise with (not your app-lock PIN).';

  @override
  String get delOtherAccount => 'That password belongs to a different account.';

  @override
  String get delTooMany =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get delNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get delReLogin =>
      'Please sign out, sign in again, then retry deletion.';

  @override
  String delVerifyFailedCode(String code) {
    return 'Verification failed ($code). Please try again.';
  }

  @override
  String get delVerifyFailed =>
      'Could not verify your password. Please try again.';

  @override
  String get delDataFailed => 'Could not delete your data. Please try again.';

  @override
  String get delAccountFailed =>
      'Could not delete your account. Please try again.';

  @override
  String get notifChannelName => 'Transaction alerts';

  @override
  String get notifChannelDesc =>
      'Notifies you when a Mobile Money transaction is auto-recorded.';

  @override
  String get notifMoneyReceived => 'Money received';

  @override
  String get notifMoneySent => 'Money sent';

  @override
  String get notifSmsNotRead => 'MoMo SMS not read';

  @override
  String get notifSmsNotReadBody =>
      'Looked like a transaction but the amount/format wasn\'t recognised.';

  @override
  String get notifNotSaved => 'Transaction not saved';

  @override
  String notifNotSavedBody(String description) {
    return 'Could not record \"$description\". Please add it manually.';
  }

  @override
  String get monitorChannelName => 'Mobile Money monitoring';

  @override
  String get monitorChannelDesc =>
      'Shown while FinWise is watching for Mobile Money SMS to auto-track your transactions.';

  @override
  String get monitorTitle => 'FinWise is monitoring for transactions';

  @override
  String get monitorText =>
      'Mobile Money SMS auto-detect is on. Tap to open FinWise.';

  @override
  String csvHeader(String code) {
    return 'Date,Type,Category,Description,Amount ($code)';
  }

  @override
  String get exportSubject => 'FinWise Transactions Export';

  @override
  String get exportText => 'Your FinWise transaction export';

  @override
  String get reportTitle => 'FINWISE TRANSACTION REPORT';

  @override
  String reportGenerated(String date) {
    return 'Generated: $date';
  }

  @override
  String get reportSummary => 'SUMMARY';

  @override
  String reportTotalIncome(String amount) {
    return 'Total Income: $amount';
  }

  @override
  String reportTotalExpenses(String amount) {
    return 'Total Expenses: $amount';
  }

  @override
  String reportBalance(String amount) {
    return 'Balance: $amount';
  }

  @override
  String get reportTransactions => 'TRANSACTIONS';

  @override
  String reportDate(String value) {
    return 'Date: $value';
  }

  @override
  String reportType(String value) {
    return 'Type: $value';
  }

  @override
  String reportCategory(String value) {
    return 'Category: $value';
  }

  @override
  String reportDescription(String value) {
    return 'Description: $value';
  }

  @override
  String reportAmount(String value) {
    return 'Amount: $value';
  }

  @override
  String get reportSubject => 'FinWise Transaction Report';

  @override
  String get reportText => 'Your FinWise transaction report';

  @override
  String get styleSaver => 'Saver';

  @override
  String get styleBalanced => 'Balanced';

  @override
  String get styleSpender => 'Spender';

  @override
  String get styleOverspender => 'Overspender';

  @override
  String get catElectricity => 'Electricity';

  @override
  String get setUpFinwise => 'Set up FinWise';

  @override
  String get back => 'Back';

  @override
  String get letsSetUp => 'Let\'s set up your FinWise';

  @override
  String get tellUsAboutYou =>
      'Tell us a bit about you. You can change this anytime.';

  @override
  String get whyWeNeed => 'Why we need this:';

  @override
  String get whyWeNeedBullets =>
      '• Your name personalizes your dashboard\n• Your currency is used across the whole app\n• Add an income target later in Settings (optional)';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get allWeNeed =>
      'That\'s all we need to get started. You can set an income target and more anytime in Settings.';

  @override
  String get whatsYourStyle => 'What\'s your spending style?';

  @override
  String get chooseStyle =>
      'Choose what fits you best. This helps FinWise suggest realistic budgets.';

  @override
  String get howThisHelps => 'How this helps:';

  @override
  String get howThisHelpsBullets =>
      '• Spending style: Helps FinWise give personalized budget advice later\n• Real spending: We only use your actual transactions to calculate charts and budgets';

  @override
  String get styleSaverSub => 'I save a lot';

  @override
  String get styleBalancedSub => 'I\'m balanced';

  @override
  String get styleSpenderSub => 'I spend most income';

  @override
  String get styleOverspenderSub => 'I often overspend';

  @override
  String get trackRealSpending =>
      'FinWise will track your real spending automatically from the transactions you add on the dashboard.';

  @override
  String get whatDoYouSpendOn => 'What do you spend on?';

  @override
  String get selectAllCategories =>
      'Select all categories that apply to your spending';

  @override
  String get mainCategoriesNote =>
      'FinWise uses these 23 main categories on every page so your budgets and insights stay clear and simple.';

  @override
  String get whyCategoriesMatter => 'Why categories matter:';

  @override
  String get whyCategoriesBullets =>
      '• Track spending by category (Food, Transport, etc.)\n• Get insights like \"You spent 30% on Food this month\"\n• Set budgets per category and get alerts\n• You can add more categories anytime';

  @override
  String get addCustomCategoryHint => 'Add custom category...';

  @override
  String get addRemoveLater =>
      'You can always add or remove categories later in settings.';

  @override
  String get permissionNotGrantedLater =>
      'Permission not granted. You can turn on auto-tracking later in Settings.';

  @override
  String get trackAutomatically => 'Track money automatically';

  @override
  String get trackAutomaticallyBody =>
      'This is what makes FinWise different. It reads your Mobile Money SMS and records every payment and deposit for you — no manual typing.';

  @override
  String get featInstant => 'Instant';

  @override
  String get featInstantBody =>
      'New MoMo transactions appear on your balance within seconds.';

  @override
  String get featPrivate => 'Private';

  @override
  String get featPrivateBody =>
      'Everything stays on your phone. Nothing is uploaded or shared.';

  @override
  String get featAutomatic => 'Automatic';

  @override
  String get featAutomaticBody =>
      'Amount, direction and category are filled in for you.';

  @override
  String get autoTrackingOnFinish =>
      'Auto-tracking is on. Tap Get Started to finish.';

  @override
  String get requestingPermission => 'Requesting permission…';

  @override
  String get enableAutoTracking => 'Enable auto-tracking';

  @override
  String get turnOffAnytime => 'You can turn this off anytime in Settings.';

  @override
  String get optionalSkip =>
      'Optional — you can skip and turn it on later in Settings.';

  @override
  String get faqS1 => 'Automatic tracking (SMS)';

  @override
  String get faqS1Q1 => 'How does auto-detect work?';

  @override
  String get faqS1A1 =>
      'When you turn it on, FinWise reads incoming Mobile Money SMS (MTN, Airtel, bank alerts) on your phone and records the transaction automatically — amount, whether it was money in or out, and who it was with. It works fully offline: nothing is sent anywhere except your own device and, if you\'re signed in, your own FinWise account.';

  @override
  String get faqS1Q2 => 'Does FinWise read my personal messages?';

  @override
  String get faqS1A2 =>
      'No. Only messages that look like Mobile Money or bank notifications are ever processed — everything else is ignored and never stored or transmitted.';

  @override
  String get faqS1Q3 => 'Why did I get two notifications for one payment?';

  @override
  String get faqS1A3 =>
      'That shouldn\'t happen. If the same amount, same person, and same type of message (both \"received\" or both \"sent\") arrives twice within a few minutes, FinWise treats the second one as a repeat and does not record it again. If you still see a duplicate, use \"Email us\" below with the date/amount so it can be fixed.';

  @override
  String get faqS1Q4 =>
      'A promotional or \"bundle expired\" SMS was recorded as an expense.';

  @override
  String get faqS1A4 =>
      'FinWise filters out common promotional wording, but providers change their message templates over time. If one slips through, delete it from your transaction list — swipe left, or tap it and delete.';

  @override
  String get faqS2 => 'Transfers between your own accounts';

  @override
  String get faqS2Q1 =>
      'I moved money from Mobile Money to my bank — why isn\'t it income or an expense?';

  @override
  String get faqS2A1 =>
      'Moving money between accounts you own (Mobile Money ↔ bank, or saving/withdrawing MoCash) isn\'t a real gain or loss — it\'s still your money. FinWise records these as a neutral \"Transfer\" so they never inflate your income or spending totals.';

  @override
  String get faqS2Q2 =>
      'How does FinWise know it\'s a transfer and not a real payment?';

  @override
  String get faqS2A2 =>
      'Mostly by pattern: one movement between your own accounts usually produces two SMS — one saying money left an account, another saying the same amount arrived — with the same amount, the same name, within a few minutes of each other. FinWise pairs those up automatically. It does not rely on your profile name, so it works even if your accounts are registered under a different name.';

  @override
  String get faqS2Q3 => 'What about a loan from MoCash?';

  @override
  String get faqS2A3 =>
      'A loan genuinely changes what you have or owe, so it\'s recorded normally — receiving a loan is income, repaying it is an expense. Only a plain save/withdraw within MoCash is treated as a transfer.';

  @override
  String get faqS2Q4 => 'Does a fee on a transfer get recorded?';

  @override
  String get faqS2A4 =>
      'Yes. The transfer itself is neutral, but any fee charged on it is a real cost, so it\'s recorded separately as a small expense.';

  @override
  String get faqS3 => 'Goals & saved money';

  @override
  String get faqS3Q1 =>
      'When I put money toward a goal, does that count as spent?';

  @override
  String get faqS3A1 =>
      'No. Money reserved for a goal is set aside, not spent — it still shows in your account. It only becomes a real expense once you mark the goal as purchased.';

  @override
  String get faqS3Q2 =>
      'I marked a goal as purchased but I\'d already recorded that expense from an SMS — will it be counted twice?';

  @override
  String get faqS3A2 =>
      'No — when marking a goal purchased, you can link it to a transaction that\'s already recorded (e.g. auto-detected from SMS) instead of creating a new one, so it\'s only counted once.';

  @override
  String get faqS4 => 'Currency & accounts';

  @override
  String get faqS4Q1 =>
      'What happens if I change my currency after adding transactions?';

  @override
  String get faqS4A1 =>
      'Amounts are not converted — a transaction recorded as 500 RWF would simply display as 500 in the new currency, same number, different label. FinWise warns you about this before the change goes through, since it doesn\'t use live exchange rates.';

  @override
  String get faqS5 => 'Privacy & data';

  @override
  String get faqS5Q1 => 'Does FinWise collect my photo or profile picture?';

  @override
  String get faqS5A1 =>
      'No. FinWise shows your initial as your avatar instead of a photo — no images are ever uploaded.';

  @override
  String get faqS5Q2 => 'Can I use FinWise without SMS auto-detect?';

  @override
  String get faqS5A2 =>
      'Yes — it\'s optional. You can add every transaction manually and never grant SMS permission at all.';

  @override
  String get faqS5Q3 => 'How do I delete my account and data?';

  @override
  String get faqS5A3 =>
      'Settings → Delete account. This permanently removes your transactions, goals, profile, and sign-in — it cannot be undone, so consider exporting your data first.';

  @override
  String get faqS5Q4 => 'Can I export my data?';

  @override
  String get faqS5A4 =>
      'Yes — Settings → Export to CSV or Export Report (PDF).';

  @override
  String get faqS6 => 'App lock';

  @override
  String get faqS6Q1 => 'How do I turn on PIN or fingerprint lock?';

  @override
  String get faqS6A1 =>
      'Settings → Security → App Lock. You can use a PIN, or your phone\'s fingerprint/face unlock where supported.';

  @override
  String get faqS6Q2 => 'I forgot my PIN.';

  @override
  String get faqS6A2 =>
      'On the lock screen, tap \"Forgot PIN?\" — this signs you out and back in with your FinWise email/password, then lets you set a new PIN.';

  @override
  String get stillNeedHelp => 'Still need help?';

  @override
  String get reachOutDirectly =>
      'Reach out directly and we\'ll get back to you.';

  @override
  String get legalTermsTitle => 'Terms & Conditions';

  @override
  String get legalTermsIntro =>
      'By creating a FinWise account you agree to these terms. Please read them carefully.';

  @override
  String get legalTermsS1T => '1. Using FinWise';

  @override
  String get legalTermsS1C =>
      '• FinWise helps you track your personal income, spending and savings goals.\n• You must be old enough to enter a binding agreement in your country.\n• You are responsible for keeping your account credentials secure.\n• Use the app only for lawful, personal financial management.';

  @override
  String get legalTermsS2T => '2. Your Data Is Yours';

  @override
  String get legalTermsS2C =>
      '• The financial information you record belongs to you.\n• We store it to provide the service and sync it across your devices.\n• You can export or delete your data at any time from Settings.';

  @override
  String get legalTermsS3T => '3. Mobile Money SMS Detection';

  @override
  String get legalTermsS3C =>
      '• This optional feature reads Mobile Money messages on your device to record transactions automatically.\n• Messages are processed entirely on your phone. Message content is never uploaded or shared.\n• Only financial messages are used; personal SMS are ignored.\n• You can turn this off at any time in Settings.';

  @override
  String get legalTermsS4T => '4. Accuracy & Financial Decisions';

  @override
  String get legalTermsS4C =>
      '• FinWise is a tracking tool, not financial, investment, tax or legal advice.\n• Automatic detection and categorisation may occasionally be wrong — always review your records.\n• You remain responsible for your own financial decisions.';

  @override
  String get legalTermsS5T => '5. Availability';

  @override
  String get legalTermsS5C =>
      '• We aim to keep FinWise available and accurate, but the service is provided \"as is\".\n• Features may change, and syncing depends on your internet connection.';

  @override
  String get legalTermsS6T => '6. Ending Your Account';

  @override
  String get legalTermsS6C =>
      '• You may stop using FinWise and delete your data at any time.\n• We may suspend accounts that misuse the service or breach these terms.';

  @override
  String get legalTermsS7T => '7. Changes to These Terms';

  @override
  String get legalTermsS7C =>
      'We may update these terms as the app evolves. Continuing to use FinWise after an update means you accept the revised terms.';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalPrivacyIntro =>
      'FinWise helps you track your money. This policy explains exactly what we collect, what stays on your phone, and what we never do.';

  @override
  String get legalPrivacyS1T => '1. What Stays Only On Your Phone';

  @override
  String get legalPrivacyS1C =>
      'The following NEVER leaves your device and is never uploaded:\n\n• SMS message content. Mobile Money and bank messages are read and analysed entirely on your phone. We never upload, store or transmit message text.\n• Your app lock PIN. Stored only as a salted, irreversible hash.\n• Fingerprint / face data. Android verifies you in secure hardware and tells the app only \"yes\" or \"no\". FinWise never receives, sees or stores biometric data.';

  @override
  String get legalPrivacyS2T => '2. Mobile Money SMS Detection (Optional)';

  @override
  String get legalPrivacyS2C =>
      'If you enable auto-detection, FinWise uses SMS permissions to record your transactions automatically.\n\n• Purpose: to read financial alerts from Mobile Money providers and banks so transactions are recorded without manual typing.\n• Only financial messages are used. Personal messages are ignored.\n• Only the extracted amount, direction, date and counterparty name are saved as a transaction — never the raw message.\n• Processing happens on your device, offline.\n• You can turn this off at any time in Settings, and revoke the permission in your phone settings.\n\nThis use complies with Google Play\'s permitted use for SMS-based money management.';

  @override
  String get legalPrivacyS3T => '3. Information We Collect';

  @override
  String get legalPrivacyS3C =>
      '• Account: email address and name (for sign-in and personalisation)\n• Financial records: transactions you add or that are detected — amount, description, category, date and account type\n• Goals: names, targets, dates and contribution history\n• Preferences: currency, optional income target, app settings\n\nWe do NOT collect photos. FinWise has no photo upload and does not request camera or gallery access — your avatar is simply the first letter of your name.';

  @override
  String get legalPrivacyS4T => '4. Where Your Data Is Stored';

  @override
  String get legalPrivacyS4C =>
      '• On your device: a local copy of your transactions and settings, so the app works offline and starts quickly.\n• In the cloud (Firebase, operated by Google): your account details, transactions and goals — so your data survives a lost phone and syncs across devices.\n\nCloud data is encrypted in transit and at rest. Security rules ensure only your signed-in account can read your records.';

  @override
  String get legalPrivacyS5T => '5. Notifications & Background Activity';

  @override
  String get legalPrivacyS5C =>
      '• FinWise shows a notification when a transaction is detected.\n• While auto-detection is on, a persistent notification indicates that FinWise is monitoring for transactions. Android requires this for any app doing background work, and it keeps detection reliable.\n• Background activity is used only to detect transactions. We do not track your location or usage of other apps.';

  @override
  String get legalPrivacyS6T => '6. What We Never Do';

  @override
  String get legalPrivacyS6C =>
      '• We never sell your personal information.\n• We never share your financial data with advertisers or data brokers.\n• We never upload SMS content.\n• We do not move money, access your bank or Mobile Money account, or ask for your PIN or banking credentials.\n• We show no advertising.';

  @override
  String get legalPrivacyS7T => '7. Third-Party Services';

  @override
  String get legalPrivacyS7C =>
      'We use Firebase (Google) for sign-in, database and file storage. Google\'s privacy policy applies to their handling of that data: https://policies.google.com/privacy\n\nNo other third-party service receives your data.';

  @override
  String get legalPrivacyS8T => '8. Your Rights & Control';

  @override
  String get legalPrivacyS8C =>
      '• Access: view all of your data inside the app\n• Export: download your transactions as CSV or PDF\n• Delete: remove individual records, clear all data, or delete your account entirely\n• Withdraw consent: turn off SMS detection at any time\n• Sign out: stops cloud sync on that device';

  @override
  String get legalPrivacyS9T => '9. Data Retention';

  @override
  String get legalPrivacyS9C =>
      'Your data is kept until you delete it. Deleting a record removes it from your device and the cloud. Deleting your account removes your stored data permanently.';

  @override
  String get legalPrivacyS10T => '10. Children\'s Privacy';

  @override
  String get legalPrivacyS10C =>
      'FinWise is not intended for anyone under 13. We do not knowingly collect information from children.';

  @override
  String get legalPrivacyS11T => '11. Changes To This Policy';

  @override
  String get legalPrivacyS11C =>
      'If this policy changes, the date below is updated. Significant changes affecting how your data is used will be announced in the app.';

  @override
  String get legalPrivacyS12T => '12. Contact';

  @override
  String get legalPrivacyS12C =>
      'For any privacy question or to request deletion of your data, contact us through Help & Support in the app.';

  @override
  String legalLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get legalUpdatedDate => 'July 2026';

  @override
  String get legalTranslationNote => '';

  @override
  String get biometricReason => 'Unlock FinWise to view your finances';
}
