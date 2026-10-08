import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('rw')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get languageKinyarwanda;

  /// No description provided for @sectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get sectionProfile;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get sectionData;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionAutomation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get sectionAutomation;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @profileOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Profile & onboarding'**
  String get profileOnboarding;

  /// No description provided for @profileOnboardingSub.
  ///
  /// In en, this message translates to:
  /// **'Update your name and currency'**
  String get profileOnboardingSub;

  /// No description provided for @incomeTarget.
  ///
  /// In en, this message translates to:
  /// **'Income target'**
  String get incomeTarget;

  /// No description provided for @incomeTargetSet.
  ///
  /// In en, this message translates to:
  /// **'{amount}/month — used to measure your savings rate'**
  String incomeTargetSet(String amount);

  /// No description provided for @incomeTargetUnset.
  ///
  /// In en, this message translates to:
  /// **'Set an optional target to measure your savings rate'**
  String get incomeTargetUnset;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutSub.
  ///
  /// In en, this message translates to:
  /// **'Sign out and return to login'**
  String get logoutSub;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Permanently erase your account and all data'**
  String get deleteAccountSub;

  /// No description provided for @calendarView.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get calendarView;

  /// No description provided for @calendarViewSub.
  ///
  /// In en, this message translates to:
  /// **'View transactions by date'**
  String get calendarViewSub;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvSub.
  ///
  /// In en, this message translates to:
  /// **'Download transactions as CSV'**
  String get exportCsvSub;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @exportReportSub.
  ///
  /// In en, this message translates to:
  /// **'Generate transaction report'**
  String get exportReportSub;

  /// No description provided for @clearTransactions.
  ///
  /// In en, this message translates to:
  /// **'Clear All Transactions'**
  String get clearTransactions;

  /// No description provided for @clearTransactionsSub.
  ///
  /// In en, this message translates to:
  /// **'Remove all transaction data'**
  String get clearTransactionsSub;

  /// No description provided for @clearGoals.
  ///
  /// In en, this message translates to:
  /// **'Clear All Goals'**
  String get clearGoals;

  /// No description provided for @clearGoalsSub.
  ///
  /// In en, this message translates to:
  /// **'Remove all goal data'**
  String get clearGoalsSub;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSub.
  ///
  /// In en, this message translates to:
  /// **'Toggle dark theme'**
  String get darkModeSub;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @faqHelp.
  ///
  /// In en, this message translates to:
  /// **'FAQ & Help'**
  String get faqHelp;

  /// No description provided for @faqHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Common questions, or contact us directly'**
  String get faqHelpSub;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySub.
  ///
  /// In en, this message translates to:
  /// **'What we collect and what stays on your phone'**
  String get privacyPolicySub;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms;

  /// No description provided for @termsSub.
  ///
  /// In en, this message translates to:
  /// **'The agreement you accepted at sign-up'**
  String get termsSub;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodLastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String periodLastDays(int days);

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTime;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range…'**
  String get periodCustom;

  /// No description provided for @showPeriod.
  ///
  /// In en, this message translates to:
  /// **'Show period'**
  String get showPeriod;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get selectPeriod;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get moneyIn;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @savingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get savingsRate;

  /// No description provided for @setAsideForGoals.
  ///
  /// In en, this message translates to:
  /// **'Set aside for goals: {amount}'**
  String setAsideForGoals(String amount);

  /// No description provided for @safeToSpend.
  ///
  /// In en, this message translates to:
  /// **'Safe to spend: {amount}'**
  String safeToSpend(String amount);

  /// No description provided for @overBy.
  ///
  /// In en, this message translates to:
  /// **'You are over by {amount}'**
  String overBy(String amount);

  /// No description provided for @youKept.
  ///
  /// In en, this message translates to:
  /// **'You kept {amount}'**
  String youKept(String amount);

  /// No description provided for @overspentBy.
  ///
  /// In en, this message translates to:
  /// **'You overspent by {amount}'**
  String overspentBy(String amount);

  /// No description provided for @earnedPctOfIncome.
  ///
  /// In en, this message translates to:
  /// **'earned {pct}% of your usual income'**
  String earnedPctOfIncome(String pct);

  /// No description provided for @greatPace.
  ///
  /// In en, this message translates to:
  /// **'Great pace — keep it up.'**
  String get greatPace;

  /// No description provided for @watchSpending.
  ///
  /// In en, this message translates to:
  /// **'Watch your spending to save more.'**
  String get watchSpending;

  /// No description provided for @noIncomeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Add some income in this period, or set an income target in Settings, to see your savings rate.'**
  String get noIncomeCurrent;

  /// No description provided for @noIncomePast.
  ///
  /// In en, this message translates to:
  /// **'No income recorded in this period. Set an income target in Settings to see your savings rate.'**
  String get noIncomePast;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get historyTitle;

  /// No description provided for @yourHistory.
  ///
  /// In en, this message translates to:
  /// **'Your history'**
  String get yourHistory;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, filter and review all your past transactions in one place.'**
  String get historySubtitle;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTitle;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Type:'**
  String get filterByType;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category:'**
  String get filterByCategory;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactions;

  /// No description provided for @tryAdjusting.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjusting;

  /// No description provided for @nothingInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing in \"{period}\". Try another period, or choose \"All time\".'**
  String nothingInPeriod(String period);

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Save for what matters'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Set a target, reserve money towards it, and watch your progress. Reserved money stays yours — it just won\'t be counted as spendable.'**
  String get goalsEmptyBody;

  /// No description provided for @createFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Create your first goal'**
  String get createFirstGoal;

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get activeGoals;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @goalsOverview.
  ///
  /// In en, this message translates to:
  /// **'Goals overview'**
  String get goalsOverview;

  /// No description provided for @reservedOfTargeted.
  ///
  /// In en, this message translates to:
  /// **'reserved of {target} targeted · {pct}%'**
  String reservedOfTargeted(String target, String pct);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @goalsReady.
  ///
  /// In en, this message translates to:
  /// **'{count} goal(s) fully funded — ready to buy'**
  String goalsReady(int count);

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to buy'**
  String get statusReady;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get statusOnTrack;

  /// No description provided for @statusBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get statusBehind;

  /// No description provided for @pastDue.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get pastDue;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get paid;

  /// No description provided for @paidPlanned.
  ///
  /// In en, this message translates to:
  /// **'paid · planned {amount}'**
  String paidPlanned(String amount);

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofAmount(String amount);

  /// No description provided for @fullyFundedTap.
  ///
  /// In en, this message translates to:
  /// **'Fully funded — tap to mark it bought'**
  String get fullyFundedTap;

  /// No description provided for @addPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Add {amount}/month to finish on time'**
  String addPerMonth(String amount);

  /// No description provided for @addContribution.
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get addContribution;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @reserveMoney.
  ///
  /// In en, this message translates to:
  /// **'Reserve money'**
  String get reserveMoney;

  /// No description provided for @reserveExplain.
  ///
  /// In en, this message translates to:
  /// **'Moves money from an account into this goal. It stays yours — just reserved, so it is not counted as spending.'**
  String get reserveExplain;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccount;

  /// No description provided for @amountWithCode.
  ///
  /// In en, this message translates to:
  /// **'Amount ({code})'**
  String amountWithCode(String code);

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @freeAmount.
  ///
  /// In en, this message translates to:
  /// **'{account} · {amount} free'**
  String freeAmount(String account, String amount);

  /// No description provided for @enterAmountAbove0.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0'**
  String get enterAmountAbove0;

  /// No description provided for @onlyHasAvailable.
  ///
  /// In en, this message translates to:
  /// **'{account} only has {amount} available.'**
  String onlyHasAvailable(String account, String amount);

  /// No description provided for @reservedFrom.
  ///
  /// In en, this message translates to:
  /// **'Reserved {amount} from {account}'**
  String reservedFrom(String amount, String account);

  /// No description provided for @reservedOver.
  ///
  /// In en, this message translates to:
  /// **'Reserved {amount} — that is {over} more than this goal needs. Release it any time.'**
  String reservedOver(String amount, String over);

  /// No description provided for @accountCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountCash;

  /// No description provided for @accountBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountBank;

  /// No description provided for @accountMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get accountMobileMoney;

  /// No description provided for @release.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get release;

  /// No description provided for @bought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get bought;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target {date}'**
  String target(String date);

  /// No description provided for @purchasedOn.
  ///
  /// In en, this message translates to:
  /// **'Purchased {date}'**
  String purchasedOn(String date);

  /// No description provided for @reservedOfPct.
  ///
  /// In en, this message translates to:
  /// **'reserved of {target} · {pct}%'**
  String reservedOfPct(String target, String pct);

  /// No description provided for @paidPlannedCompleted.
  ///
  /// In en, this message translates to:
  /// **'paid · planned {amount} · completed'**
  String paidPlannedCompleted(String amount);

  /// No description provided for @paidCompleted.
  ///
  /// In en, this message translates to:
  /// **'paid · completed'**
  String get paidCompleted;

  /// No description provided for @readyExtra.
  ///
  /// In en, this message translates to:
  /// **'Ready to buy — {amount} more than the price is reserved. You can release the extra.'**
  String readyExtra(String amount);

  /// No description provided for @fullyFundedBought.
  ///
  /// In en, this message translates to:
  /// **'Fully funded — tap Bought when you buy it.'**
  String get fullyFundedBought;

  /// No description provided for @stillNeed.
  ///
  /// In en, this message translates to:
  /// **'Still need {amount} · about {monthly}/month'**
  String stillNeed(String amount, String monthly);

  /// No description provided for @differentPrice.
  ///
  /// In en, this message translates to:
  /// **'Found a different price? Update price'**
  String get differentPrice;

  /// No description provided for @plannedPriceChanged.
  ///
  /// In en, this message translates to:
  /// **'Planned {amount} · Price changed again? Update'**
  String plannedPriceChanged(String amount);

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @editGoalSub.
  ///
  /// In en, this message translates to:
  /// **'Name, target amount, date or icon'**
  String get editGoalSub;

  /// No description provided for @updatePrice.
  ///
  /// In en, this message translates to:
  /// **'Update price'**
  String get updatePrice;

  /// No description provided for @updatePriceSub.
  ///
  /// In en, this message translates to:
  /// **'The real price is higher or lower than planned'**
  String get updatePriceSub;

  /// No description provided for @undoPurchase.
  ///
  /// In en, this message translates to:
  /// **'Undo purchase'**
  String get undoPurchase;

  /// No description provided for @undoPurchaseSub.
  ///
  /// In en, this message translates to:
  /// **'Reopen this goal and reserve again'**
  String get undoPurchaseSub;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get deleteGoal;

  /// No description provided for @deleteGoalSub.
  ///
  /// In en, this message translates to:
  /// **'Reserved money returns to available'**
  String get deleteGoalSub;

  /// No description provided for @reservedFromTitle.
  ///
  /// In en, this message translates to:
  /// **'Reserved from'**
  String get reservedFromTitle;

  /// No description provided for @contributionHistory.
  ///
  /// In en, this message translates to:
  /// **'Contribution history'**
  String get contributionHistory;

  /// No description provided for @tapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap an entry to edit or delete it.'**
  String get tapToEdit;

  /// No description provided for @undoToEdit.
  ///
  /// In en, this message translates to:
  /// **'Undo the purchase to change these entries.'**
  String get undoToEdit;

  /// No description provided for @noMoneyReserved.
  ///
  /// In en, this message translates to:
  /// **'No money reserved yet.'**
  String get noMoneyReserved;

  /// No description provided for @reservedLabel.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reservedLabel;

  /// No description provided for @releasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get releasedLabel;

  /// No description provided for @editOrDelete.
  ///
  /// In en, this message translates to:
  /// **'Edit or delete'**
  String get editOrDelete;

  /// No description provided for @editThisReserve.
  ///
  /// In en, this message translates to:
  /// **'Edit this reserve'**
  String get editThisReserve;

  /// No description provided for @editThisRelease.
  ///
  /// In en, this message translates to:
  /// **'Edit this release'**
  String get editThisRelease;

  /// No description provided for @editEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Change the amount, account or note'**
  String get editEntrySub;

  /// No description provided for @deleteThisReserve.
  ///
  /// In en, this message translates to:
  /// **'Delete this reserve'**
  String get deleteThisReserve;

  /// No description provided for @deleteThisRelease.
  ///
  /// In en, this message translates to:
  /// **'Delete this release'**
  String get deleteThisRelease;

  /// No description provided for @deleteReserveSub.
  ///
  /// In en, this message translates to:
  /// **'The money goes back to available'**
  String get deleteReserveSub;

  /// No description provided for @deleteReleaseSub.
  ///
  /// In en, this message translates to:
  /// **'The money becomes reserved again'**
  String get deleteReleaseSub;

  /// No description provided for @editReserve.
  ///
  /// In en, this message translates to:
  /// **'Edit reserve'**
  String get editReserve;

  /// No description provided for @editRelease.
  ///
  /// In en, this message translates to:
  /// **'Edit release'**
  String get editRelease;

  /// No description provided for @releasedTo.
  ///
  /// In en, this message translates to:
  /// **'Released to'**
  String get releasedTo;

  /// No description provided for @deleteReserveQ.
  ///
  /// In en, this message translates to:
  /// **'Delete reserve?'**
  String get deleteReserveQ;

  /// No description provided for @deleteReleaseQ.
  ///
  /// In en, this message translates to:
  /// **'Delete release?'**
  String get deleteReleaseQ;

  /// No description provided for @deleteReserveBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} will go back to your available money.'**
  String deleteReserveBody(String amount);

  /// No description provided for @deleteReleaseBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} will be reserved for \"{goal}\" again.'**
  String deleteReleaseBody(String amount, String goal);

  /// No description provided for @entryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get entryUpdated;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @purchaseSummary.
  ///
  /// In en, this message translates to:
  /// **'Purchase summary'**
  String get purchaseSummary;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @paidCap.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidCap;

  /// No description provided for @underPlan.
  ///
  /// In en, this message translates to:
  /// **'Under plan'**
  String get underPlan;

  /// No description provided for @overPlan.
  ///
  /// In en, this message translates to:
  /// **'Over plan'**
  String get overPlan;

  /// No description provided for @paidLessThanPlanned.
  ///
  /// In en, this message translates to:
  /// **'You paid {amount} less than planned 🎉'**
  String paidLessThanPlanned(String amount);

  /// No description provided for @paidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get paidWith;

  /// No description provided for @noPaymentLinked.
  ///
  /// In en, this message translates to:
  /// **'No payment linked.'**
  String get noPaymentLinked;

  /// No description provided for @priceUpdates.
  ///
  /// In en, this message translates to:
  /// **'Price updates'**
  String get priceUpdates;

  /// No description provided for @celebrateFundedTitle.
  ///
  /// In en, this message translates to:
  /// **'{goal} is fully funded!'**
  String celebrateFundedTitle(String goal);

  /// No description provided for @celebrateFundedReserved.
  ///
  /// In en, this message translates to:
  /// **'You have {amount} reserved.'**
  String celebrateFundedReserved(String amount);

  /// No description provided for @celebrateFundedReservedSpan.
  ///
  /// In en, this message translates to:
  /// **'You have {amount} reserved — saved over {span}.'**
  String celebrateFundedReservedSpan(String amount, String span);

  /// No description provided for @celebrateFundedAsk.
  ///
  /// In en, this message translates to:
  /// **'Bought it already? Close the goal now.'**
  String get celebrateFundedAsk;

  /// No description provided for @iBoughtIt.
  ///
  /// In en, this message translates to:
  /// **'I bought it'**
  String get iBoughtIt;

  /// No description provided for @celebrateCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal completed!'**
  String get celebrateCompletedTitle;

  /// No description provided for @celebratePaid.
  ///
  /// In en, this message translates to:
  /// **'{goal} — paid {amount}'**
  String celebratePaid(String goal, String amount);

  /// No description provided for @celebratePaidUnder.
  ///
  /// In en, this message translates to:
  /// **'{goal} — paid {amount} · {under} under plan'**
  String celebratePaidUnder(String goal, String amount, String under);

  /// No description provided for @celebrateSavedOver.
  ///
  /// In en, this message translates to:
  /// **'You saved for it over {span}.'**
  String celebrateSavedOver(String span);

  /// No description provided for @celebrateReturned.
  ///
  /// In en, this message translates to:
  /// **'{amount} went back to your available money.'**
  String celebrateReturned(String amount);

  /// No description provided for @startNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Start a new goal'**
  String get startNewGoal;

  /// No description provided for @spanLessThanMonth.
  ///
  /// In en, this message translates to:
  /// **'less than a month'**
  String get spanLessThanMonth;

  /// No description provided for @spanMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month} other{{months} months}}'**
  String spanMonths(int months);

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalTitle;

  /// No description provided for @goalNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This goal no longer exists.'**
  String get goalNoLongerExists;

  /// No description provided for @boughtWithoutReserving.
  ///
  /// In en, this message translates to:
  /// **'Bought without reserving money in FinWise first.'**
  String get boughtWithoutReserving;

  /// No description provided for @savedOverContributions.
  ///
  /// In en, this message translates to:
  /// **'Saved over {span} · {count, plural, =1{1 contribution} other{{count} contributions}}'**
  String savedOverContributions(String span, int count);

  /// No description provided for @missingPayments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 linked payment is} other{{count} linked payments are}} no longer in your history.'**
  String missingPayments(int count);

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for that email. Please sign up first.'**
  String get errUserNotFound;

  /// No description provided for @errWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please check your password and try again.'**
  String get errWrongPassword;

  /// No description provided for @errInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please check your credentials.'**
  String get errInvalidCredential;

  /// No description provided for @errInvalidEmailEnter.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address. Please enter a valid email.'**
  String get errInvalidEmailEnter;

  /// No description provided for @errUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Please contact support.'**
  String get errUserDisabled;

  /// No description provided for @errTooManyFailed.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please wait a few minutes and try again.'**
  String get errTooManyFailed;

  /// No description provided for @errNetworkInternet.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get errNetworkInternet;

  /// No description provided for @errLoginDisabled.
  ///
  /// In en, this message translates to:
  /// **'Login is currently disabled. Please contact support.'**
  String get errLoginDisabled;

  /// No description provided for @errReLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log out and log in again to continue.'**
  String get errReLogin;

  /// No description provided for @errLoginFailedCode.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {code}. Please check your email and password.'**
  String errLoginFailedCode(String code);

  /// No description provided for @loginFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailedRetry;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep track of your money'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @newToFinwise.
  ///
  /// In en, this message translates to:
  /// **'New to FinWise?'**
  String get newToFinwise;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @agreeTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms and conditions'**
  String get agreeTermsRequired;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered. Try logging in instead.'**
  String get errEmailInUse;

  /// No description provided for @errInvalidEmailCheck.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address. Please check and try again.'**
  String get errInvalidEmailCheck;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get errWeakPassword;

  /// No description provided for @errSignupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Signup is currently disabled. Please contact support.'**
  String get errSignupDisabled;

  /// No description provided for @errNetworkConnection.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errNetworkConnection;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed. Please try again.'**
  String get signupFailed;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your money in minutes'**
  String get signupSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterAPassword;

  /// No description provided for @atLeast6.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @errNoAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'No account found for that email.'**
  String get errNoAccountEmail;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get errTooManyAttempts;

  /// No description provided for @resetEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email. Please try again.'**
  String get resetEmailFailed;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a link to set a new password'**
  String get resetLinkSent;

  /// No description provided for @resetEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send reset instructions'**
  String get resetEnterEmail;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get emailSent;

  /// No description provided for @resetSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent reset instructions to\n{email}'**
  String resetSentTo(String email);

  /// No description provided for @checkSpam.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Check your spam or promotions folder. The email may take a few minutes to arrive.'**
  String get checkSpam;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send it again'**
  String get sendAgain;

  /// No description provided for @freqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get freqDaily;

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqMonthly;

  /// No description provided for @freqYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get freqYearly;

  /// No description provided for @freqIrregular.
  ///
  /// In en, this message translates to:
  /// **'Irregular'**
  String get freqIrregular;

  /// No description provided for @pinsDidNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs did not match. Start again.'**
  String get pinsDidNotMatch;

  /// No description provided for @tooManyWait.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait.'**
  String get tooManyWait;

  /// No description provided for @incorrectPinLeft.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. {left, plural, =1{1 try} other{{left} tries}} left before a wait.'**
  String incorrectPinLeft(int left);

  /// No description provided for @incorrectPinRetry.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get incorrectPinRetry;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get createPin;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmYourPin;

  /// No description provided for @enterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterYourPin;

  /// No description provided for @confirmItsYou.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get confirmItsYou;

  /// No description provided for @pinUseToOpen.
  ///
  /// In en, this message translates to:
  /// **'You\'ll use this to open FinWise'**
  String get pinUseToOpen;

  /// No description provided for @pinSameAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter the same 4 digits again'**
  String get pinSameAgain;

  /// No description provided for @financesLocked.
  ///
  /// In en, this message translates to:
  /// **'Your finances are locked'**
  String get financesLocked;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN to continue'**
  String get enterCurrentPin;

  /// No description provided for @tooManyTryIn.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {time}'**
  String tooManyTryIn(String time);

  /// No description provided for @forgotPinQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPinQ;

  /// No description provided for @forgotYourPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get forgotYourPin;

  /// No description provided for @forgotPinBody.
  ///
  /// In en, this message translates to:
  /// **'To reset it, sign in again with your email and password.\n\nYou will be signed out and the app lock removed. Your transactions and goals are safe — they sync back as soon as you sign in.'**
  String get forgotPinBody;

  /// No description provided for @signOutReset.
  ///
  /// In en, this message translates to:
  /// **'Sign out & reset'**
  String get signOutReset;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FinWise'**
  String get welcomeTitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart financial advice for a new era of wealth'**
  String get welcomeTagline;

  /// No description provided for @welcomeFeat1.
  ///
  /// In en, this message translates to:
  /// **'Smart budget recommendations'**
  String get welcomeFeat1;

  /// No description provided for @welcomeFeat2.
  ///
  /// In en, this message translates to:
  /// **'Automatic spending analysis'**
  String get welcomeFeat2;

  /// No description provided for @welcomeFeat3.
  ///
  /// In en, this message translates to:
  /// **'Goal tracking that keeps you focused'**
  String get welcomeFeat3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @setupProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup Profile'**
  String get setupProfile;

  /// No description provided for @getToKnowYou.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get getToKnowYou;

  /// No description provided for @personalizedGuidance.
  ///
  /// In en, this message translates to:
  /// **'This helps us provide personalized financial guidance'**
  String get personalizedGuidance;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @currencyAdapts.
  ///
  /// In en, this message translates to:
  /// **'Wherever you are — FinWise adapts to it'**
  String get currencyAdapts;

  /// No description provided for @monthlyIncomeCode.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income ({code})'**
  String monthlyIncomeCode(String code);

  /// No description provided for @approximateFine.
  ///
  /// In en, this message translates to:
  /// **'Approximate is fine'**
  String get approximateFine;

  /// No description provided for @enterIncome.
  ///
  /// In en, this message translates to:
  /// **'Please enter your income'**
  String get enterIncome;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @incomeFrequency.
  ///
  /// In en, this message translates to:
  /// **'Income Frequency'**
  String get incomeFrequency;

  /// No description provided for @dontWorryUpdate.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! You can always update this later. We\'ll provide guidance even with approximate values.'**
  String get dontWorryUpdate;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get catVacation;

  /// No description provided for @catClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get catClothes;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @catShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get catShoes;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catFamily.
  ///
  /// In en, this message translates to:
  /// **'Family & Support'**
  String get catFamily;

  /// No description provided for @catDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt & Loans'**
  String get catDebt;

  /// No description provided for @catBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catBusiness;

  /// No description provided for @catGiving.
  ///
  /// In en, this message translates to:
  /// **'Giving & Church'**
  String get catGiving;

  /// No description provided for @catFees.
  ///
  /// In en, this message translates to:
  /// **'Fees & Taxes'**
  String get catFees;

  /// No description provided for @catPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get catPersonal;

  /// No description provided for @catMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get catMedicine;

  /// No description provided for @catAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol & Drinks'**
  String get catAlcohol;

  /// No description provided for @catTobacco.
  ///
  /// In en, this message translates to:
  /// **'Tobacco'**
  String get catTobacco;

  /// No description provided for @catIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get catIncome;

  /// No description provided for @catSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get catSavings;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @reasonNecessity.
  ///
  /// In en, this message translates to:
  /// **'Necessity'**
  String get reasonNecessity;

  /// No description provided for @reasonBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get reasonBusiness;

  /// No description provided for @reasonEnjoyment.
  ///
  /// In en, this message translates to:
  /// **'Enjoyment'**
  String get reasonEnjoyment;

  /// No description provided for @reasonEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get reasonEmergency;

  /// No description provided for @curRwf.
  ///
  /// In en, this message translates to:
  /// **'Rwandan Franc'**
  String get curRwf;

  /// No description provided for @curUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get curUsd;

  /// No description provided for @curEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get curEur;

  /// No description provided for @curGbp.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get curGbp;

  /// No description provided for @curKes.
  ///
  /// In en, this message translates to:
  /// **'Kenyan Shilling'**
  String get curKes;

  /// No description provided for @curUgx.
  ///
  /// In en, this message translates to:
  /// **'Ugandan Shilling'**
  String get curUgx;

  /// No description provided for @curTzs.
  ///
  /// In en, this message translates to:
  /// **'Tanzanian Shilling'**
  String get curTzs;

  /// No description provided for @curNgn.
  ///
  /// In en, this message translates to:
  /// **'Nigerian Naira'**
  String get curNgn;

  /// No description provided for @curGhs.
  ///
  /// In en, this message translates to:
  /// **'Ghanaian Cedi'**
  String get curGhs;

  /// No description provided for @curZar.
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get curZar;

  /// No description provided for @curXaf.
  ///
  /// In en, this message translates to:
  /// **'Central African CFA Franc'**
  String get curXaf;

  /// No description provided for @curCad.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get curCad;

  /// No description provided for @curInr.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get curInr;

  /// No description provided for @giSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get giSavings;

  /// No description provided for @giLaptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get giLaptop;

  /// No description provided for @giCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get giCar;

  /// No description provided for @giHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get giHouse;

  /// No description provided for @giLand.
  ///
  /// In en, this message translates to:
  /// **'Land / Plot'**
  String get giLand;

  /// No description provided for @giEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get giEducation;

  /// No description provided for @giBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get giBusiness;

  /// No description provided for @giTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get giTravel;

  /// No description provided for @giWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get giWedding;

  /// No description provided for @giFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get giFamily;

  /// No description provided for @giHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get giHealth;

  /// No description provided for @giEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get giEmergency;

  /// No description provided for @giPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get giPhone;

  /// No description provided for @giFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get giFurniture;

  /// No description provided for @giClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get giClothes;

  /// No description provided for @giGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get giGaming;

  /// No description provided for @giDebt.
  ///
  /// In en, this message translates to:
  /// **'Pay off debt'**
  String get giDebt;

  /// No description provided for @giGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get giGift;

  /// No description provided for @giOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get giOther;

  /// No description provided for @enterRealPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter the real price.'**
  String get enterRealPrice;

  /// No description provided for @haveEnoughExtra.
  ///
  /// In en, this message translates to:
  /// **'You already have enough — ready to buy. {amount} extra reserved can go back to available.'**
  String haveEnoughExtra(String amount);

  /// No description provided for @haveExactlyEnough.
  ///
  /// In en, this message translates to:
  /// **'You already have exactly enough — ready to buy.'**
  String get haveExactlyEnough;

  /// No description provided for @willStillNeed.
  ///
  /// In en, this message translates to:
  /// **'You will still need {amount}.'**
  String willStillNeed(String amount);

  /// No description provided for @realPriceIntro.
  ///
  /// In en, this message translates to:
  /// **'Found the real price in a shop or online? Your goal will follow it. Planned: {planned}{current}.'**
  String realPriceIntro(String planned, String current);

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **' · current: {amount}'**
  String currentPrice(String amount);

  /// No description provided for @realPriceCode.
  ///
  /// In en, this message translates to:
  /// **'Real price ({code})'**
  String realPriceCode(String code);

  /// No description provided for @priceUpdatedExtra.
  ///
  /// In en, this message translates to:
  /// **'Price updated. {amount} more than needed is reserved.'**
  String priceUpdatedExtra(String amount);

  /// No description provided for @priceUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Price updated to {amount}.'**
  String priceUpdatedTo(String amount);

  /// No description provided for @releaseExtra.
  ///
  /// In en, this message translates to:
  /// **'Release extra'**
  String get releaseExtra;

  /// No description provided for @noteDown.
  ///
  /// In en, this message translates to:
  /// **'Price went down'**
  String get noteDown;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @releaseReserved.
  ///
  /// In en, this message translates to:
  /// **'Release reserved money'**
  String get releaseReserved;

  /// No description provided for @releaseExplain.
  ///
  /// In en, this message translates to:
  /// **'Returns money from this goal back to your available balance. Currently reserved: {amount}'**
  String releaseExplain(String amount);

  /// No description provided for @amountToRelease.
  ///
  /// In en, this message translates to:
  /// **'Amount to release ({code})'**
  String amountToRelease(String code);

  /// No description provided for @noteReleasedAll.
  ///
  /// In en, this message translates to:
  /// **'Released all'**
  String get noteReleasedAll;

  /// No description provided for @releaseAll.
  ///
  /// In en, this message translates to:
  /// **'Release all'**
  String get releaseAll;

  /// No description provided for @releasedBack.
  ///
  /// In en, this message translates to:
  /// **'Released {amount} back to available'**
  String releasedBack(String amount);

  /// No description provided for @markAsBought.
  ///
  /// In en, this message translates to:
  /// **'Mark as bought'**
  String get markAsBought;

  /// No description provided for @alreadyRecorded.
  ///
  /// In en, this message translates to:
  /// **'Did you already record this purchase?'**
  String get alreadyRecorded;

  /// No description provided for @linkExisting.
  ///
  /// In en, this message translates to:
  /// **'Link existing'**
  String get linkExisting;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @tickPayments.
  ///
  /// In en, this message translates to:
  /// **'Tick the payment(s) for this purchase'**
  String get tickPayments;

  /// No description provided for @amountEveryPayment.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount on every payment'**
  String get amountEveryPayment;

  /// No description provided for @moreThanHolds.
  ///
  /// In en, this message translates to:
  /// **'More than the account holds'**
  String get moreThanHolds;

  /// No description provided for @accountShows.
  ///
  /// In en, this message translates to:
  /// **'{account} shows {amount}'**
  String accountShows(String account, String amount);

  /// No description provided for @recordNegative.
  ///
  /// In en, this message translates to:
  /// **'Recording this will leave it negative. If the purchase really happened, record it anyway — you may just need to add some missing income.'**
  String get recordNegative;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @recordAnyway.
  ///
  /// In en, this message translates to:
  /// **'Record anyway'**
  String get recordAnyway;

  /// No description provided for @boughtDesc.
  ///
  /// In en, this message translates to:
  /// **'Bought: {goal}'**
  String boughtDesc(String goal);

  /// No description provided for @noExpensesToLink.
  ///
  /// In en, this message translates to:
  /// **'No expenses in your history to link. Switch to \"Create new\".'**
  String get noExpensesToLink;

  /// No description provided for @tickEveryPayment.
  ///
  /// In en, this message translates to:
  /// **'Tick every payment for this item — paid part by Mobile Money and part in cash? Tick both. Nothing new will be created.'**
  String get tickEveryPayment;

  /// No description provided for @searchNameAmount.
  ///
  /// In en, this message translates to:
  /// **'Search by name or amount'**
  String get searchNameAmount;

  /// No description provided for @matchesPrice.
  ///
  /// In en, this message translates to:
  /// **'  ·  matches price'**
  String get matchesPrice;

  /// No description provided for @recordWhatPaid.
  ///
  /// In en, this message translates to:
  /// **'Record what you paid. Paid from more than one account? Add a payment for each.'**
  String get recordWhatPaid;

  /// No description provided for @paidFrom.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get paidFrom;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @addAnotherPayment.
  ///
  /// In en, this message translates to:
  /// **'Add another payment'**
  String get addAnotherPayment;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get expenseCategory;

  /// No description provided for @nothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected yet.'**
  String get nothingSelected;

  /// No description provided for @underYourPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} under your price 🎉'**
  String underYourPrice(String amount);

  /// No description provided for @overYourPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} over your price'**
  String overYourPrice(String amount);

  /// No description provided for @exactlyYourPrice.
  ///
  /// In en, this message translates to:
  /// **'Exactly your price'**
  String get exactlyYourPrice;

  /// No description provided for @totalPaidPrice.
  ///
  /// In en, this message translates to:
  /// **'Total paid: {total}  ·  price {price}'**
  String totalPaidPrice(String total, String price);

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'The goal will be completed at {amount}.'**
  String completedAt(String amount);

  /// No description provided for @goalCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Goal completed at {amount}.'**
  String goalCompletedAt(String amount);

  /// No description provided for @returnedToAvailable.
  ///
  /// In en, this message translates to:
  /// **'{amount} returned to available.'**
  String returnedToAvailable(String amount);

  /// No description provided for @underPlanParty.
  ///
  /// In en, this message translates to:
  /// **'{amount} under plan 🎉'**
  String underPlanParty(String amount);

  /// No description provided for @undoCreatedDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The expense} other{The {count} expenses}} FinWise created for this purchase will be deleted.'**
  String undoCreatedDeleted(int count);

  /// No description provided for @undoLinkedStay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The linked payment stays} other{The {count} linked payments stay}} in your history — just unlinked.'**
  String undoLinkedStay(int count);

  /// No description provided for @willBeReservedAgain.
  ///
  /// In en, this message translates to:
  /// **'Your {amount} will be reserved again.'**
  String willBeReservedAgain(String amount);

  /// No description provided for @reopenGoal.
  ///
  /// In en, this message translates to:
  /// **'Reopen \"{goal}\"?'**
  String reopenGoal(String goal);

  /// No description provided for @undoneCreatedRemoved.
  ///
  /// In en, this message translates to:
  /// **'Purchase undone and the created expense removed.'**
  String get undoneCreatedRemoved;

  /// No description provided for @undoneKept.
  ///
  /// In en, this message translates to:
  /// **'Purchase undone. Your payments were kept in history.'**
  String get undoneKept;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @deleteGoalReserved.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{goal}\"? The {amount} reserved will return to your available balance.'**
  String deleteGoalReserved(String goal, String amount);

  /// No description provided for @deleteGoalNoUndo.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{goal}\"? This cannot be undone.'**
  String deleteGoalNoUndo(String goal);

  /// No description provided for @noteGoalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted'**
  String get noteGoalDeleted;

  /// No description provided for @returnedToBalance.
  ///
  /// In en, this message translates to:
  /// **'{amount} returned to your available balance'**
  String returnedToBalance(String amount);

  /// No description provided for @versionBuild.
  ///
  /// In en, this message translates to:
  /// **'{version} (Build {build})'**
  String versionBuild(String version, String build);

  /// No description provided for @clearTransactionsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all transactions? This action cannot be undone.'**
  String get clearTransactionsConfirm;

  /// No description provided for @transactionsCleared.
  ///
  /// In en, this message translates to:
  /// **'All transactions cleared'**
  String get transactionsCleared;

  /// No description provided for @incomeTargetExplain.
  ///
  /// In en, this message translates to:
  /// **'A planning target only — used to measure your savings rate. It is never added to your balance.'**
  String get incomeTargetExplain;

  /// No description provided for @howOften.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get howOften;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noTxToExport.
  ///
  /// In en, this message translates to:
  /// **'No transactions to export'**
  String get noTxToExport;

  /// No description provided for @exportedAs.
  ///
  /// In en, this message translates to:
  /// **'Transactions exported successfully as {format}'**
  String exportedAs(String format);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @clearGoalsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all goals? This action cannot be undone.'**
  String get clearGoalsConfirm;

  /// No description provided for @goalsCleared.
  ///
  /// In en, this message translates to:
  /// **'All goals cleared'**
  String get goalsCleared;

  /// No description provided for @deleteAccountQ.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountQ;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes:\n\n• All your transactions\n• All your goals and reserved money\n• Your profile and settings\n• Your sign-in account\n\nThis cannot be undone. Consider exporting your data first (Data Management → Export).'**
  String get deleteAccountBody;

  /// No description provided for @enterSignInPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the password you use to sign in to FinWise{email}.'**
  String enterSignInPassword(String email);

  /// No description provided for @notAppLockPin.
  ///
  /// In en, this message translates to:
  /// **'This is not your app-lock PIN.'**
  String get notAppLockPin;

  /// No description provided for @signInPassword.
  ///
  /// In en, this message translates to:
  /// **'Sign-in password'**
  String get signInPassword;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get accountDeleted;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? You will need to login again to access the app.'**
  String get logoutConfirm;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been logged out successfully'**
  String get loggedOut;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @editGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoalTitle;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @enterGoalName.
  ///
  /// In en, this message translates to:
  /// **'Please enter goal name'**
  String get enterGoalName;

  /// No description provided for @targetAmountCode.
  ///
  /// In en, this message translates to:
  /// **'Target Amount ({code})'**
  String targetAmountCode(String code);

  /// No description provided for @enterTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter target amount'**
  String get enterTargetAmount;

  /// No description provided for @enterValidNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid number'**
  String get enterValidNumberShort;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @changeCurrencyQ.
  ///
  /// In en, this message translates to:
  /// **'Change currency?'**
  String get changeCurrencyQ;

  /// No description provided for @changeCurrencyBody.
  ///
  /// In en, this message translates to:
  /// **'Your existing transactions will NOT be converted.\n\nAn amount recorded as 500 {from} will simply display as 500 {to} — the number stays the same, only the label changes.\n\nChange currency only if you entered those amounts in {to}, or if you plan to clear your data.'**
  String changeCurrencyBody(String from, String to);

  /// No description provided for @changeTo.
  ///
  /// In en, this message translates to:
  /// **'Change to {code}'**
  String changeTo(String code);

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose your currency'**
  String get chooseCurrency;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockOnSub.
  ///
  /// In en, this message translates to:
  /// **'FinWise asks for your PIN when opened'**
  String get appLockOnSub;

  /// No description provided for @appLockOffSub.
  ///
  /// In en, this message translates to:
  /// **'Require a PIN to open FinWise'**
  String get appLockOffSub;

  /// No description provided for @unlockFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get unlockFingerprint;

  /// No description provided for @fingerprintSub.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face instead of the PIN'**
  String get fingerprintSub;

  /// No description provided for @noFingerprint.
  ///
  /// In en, this message translates to:
  /// **'No fingerprint or face set up on this phone'**
  String get noFingerprint;

  /// No description provided for @lockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get lockAfter;

  /// No description provided for @lockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately when you leave the app'**
  String get lockImmediately;

  /// No description provided for @lockAfterMinutes.
  ///
  /// In en, this message translates to:
  /// **'After {minutes, plural, =1{1 minute} other{{minutes} minutes}} away'**
  String lockAfterMinutes(int minutes);

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @minShort.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minShort(int n);

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @changePinSub.
  ///
  /// In en, this message translates to:
  /// **'Set a new 4-digit PIN'**
  String get changePinSub;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @lockNowSub.
  ///
  /// In en, this message translates to:
  /// **'Immediately require the PIN'**
  String get lockNowSub;

  /// No description provided for @useFingerprintQ.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint?'**
  String get useFingerprintQ;

  /// No description provided for @useFingerprintBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock FinWise with your fingerprint or face instead of typing the PIN each time. Your PIN still works as a backup.'**
  String get useFingerprintBody;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @appLockOn.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get appLockOn;

  /// No description provided for @turnOffLock.
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock'**
  String get turnOffLock;

  /// No description provided for @lockTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'App lock turned off'**
  String get lockTurnedOff;

  /// No description provided for @enterCurrentPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPinTitle;

  /// No description provided for @setNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set a new PIN'**
  String get setNewPin;

  /// No description provided for @pinUpdated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get pinUpdated;

  /// No description provided for @protectFinances.
  ///
  /// In en, this message translates to:
  /// **'Protect your finances'**
  String get protectFinances;

  /// No description provided for @protectBody.
  ///
  /// In en, this message translates to:
  /// **'Add a PIN so only you can open FinWise. Signing in keeps you logged in, so without a lock anyone holding your phone could see your balance and transactions.'**
  String get protectBody;

  /// No description provided for @setUpPin.
  ///
  /// In en, this message translates to:
  /// **'Set up PIN'**
  String get setUpPin;

  /// No description provided for @nameThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Name this phone'**
  String get nameThisPhone;

  /// No description provided for @nameThisPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Transactions recorded on this phone are labelled with this name, so you can tell them apart from ones recorded on your other devices.'**
  String get nameThisPhoneBody;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @thisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get thisPhone;

  /// No description provided for @namingDevice.
  ///
  /// In en, this message translates to:
  /// **'Naming this device…'**
  String get namingDevice;

  /// No description provided for @shownOnTx.
  ///
  /// In en, this message translates to:
  /// **'{name} — shown on transactions recorded here'**
  String shownOnTx(String name);

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @needHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Most questions are answered in the FAQ. If not, reach out directly and we\'ll get back to you.'**
  String get needHelpBody;

  /// No description provided for @browseFaq.
  ///
  /// In en, this message translates to:
  /// **'Browse FAQ'**
  String get browseFaq;

  /// No description provided for @browseFaqSub.
  ///
  /// In en, this message translates to:
  /// **'Answers to common questions about FinWise'**
  String get browseFaqSub;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get emailUs;

  /// No description provided for @noEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open an email app'**
  String get noEmailApp;

  /// No description provided for @whatsappUs.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp us'**
  String get whatsappUs;

  /// No description provided for @whatsappSub.
  ///
  /// In en, this message translates to:
  /// **'Chat with us on WhatsApp'**
  String get whatsappSub;

  /// No description provided for @whatsappPreview.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp preview'**
  String get whatsappPreview;

  /// No description provided for @finwiseSupport.
  ///
  /// In en, this message translates to:
  /// **'FinWise Support'**
  String get finwiseSupport;

  /// No description provided for @whatsappGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! Have a question about FinWise, or need help with something? Send us a message and we\'ll get back to you as soon as we can.'**
  String get whatsappGreeting;

  /// No description provided for @noWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get noWhatsapp;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChat;

  /// No description provided for @smsBlocked.
  ///
  /// In en, this message translates to:
  /// **'SMS permission is blocked'**
  String get smsBlocked;

  /// No description provided for @smsBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Android has stopped asking because the permission was declined before. To turn auto-detect on, allow SMS for FinWise in your phone settings:\n\nPermissions → SMS → Allow'**
  String get smsBlockedBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @smsNotGrantedOff.
  ///
  /// In en, this message translates to:
  /// **'SMS permission was not granted, so auto-detect stays off.'**
  String get smsNotGrantedOff;

  /// No description provided for @smsNotGranted.
  ///
  /// In en, this message translates to:
  /// **'SMS permission not granted'**
  String get smsNotGranted;

  /// No description provided for @smsBlockedSwitch.
  ///
  /// In en, this message translates to:
  /// **'Android has blocked this permission because it was declined before, so the switch above can\'t turn it on. Allow SMS for FinWise in phone settings, then come back.'**
  String get smsBlockedSwitch;

  /// No description provided for @smsNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect needs permission to read Mobile Money messages. Turn the switch on to grant it.'**
  String get smsNeedsPermission;

  /// No description provided for @openPhoneSettings.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get openPhoneSettings;

  /// No description provided for @autoDetectStopped.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect has stopped working'**
  String get autoDetectStopped;

  /// No description provided for @autoDetectStoppedBody.
  ///
  /// In en, this message translates to:
  /// **'Messages haven\'t been checked in over a day. Turn the switch off and on again to re-grant SMS permission, and make sure FinWise isn\'t battery-restricted.'**
  String get autoDetectStoppedBody;

  /// No description provided for @fixBattery.
  ///
  /// In en, this message translates to:
  /// **'Fix battery settings'**
  String get fixBattery;

  /// No description provided for @nothingDetected.
  ///
  /// In en, this message translates to:
  /// **'Nothing detected in a while'**
  String get nothingDetected;

  /// No description provided for @lastDetectedCheck.
  ///
  /// In en, this message translates to:
  /// **'Last transaction detected {ago}. If you have used Mobile Money since then, check that FinWise still has SMS permission and is not battery-restricted.'**
  String lastDetectedCheck(String ago);

  /// No description provided for @lastDetected.
  ///
  /// In en, this message translates to:
  /// **'Last transaction detected {ago}.'**
  String lastDetected(String ago);

  /// No description provided for @watchingNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Watching for Mobile Money messages. Nothing detected yet.'**
  String get watchingNothingYet;

  /// No description provided for @waitingFirst.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the first Mobile Money message.'**
  String get waitingFirst;

  /// No description provided for @autoDetectWorking.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect is working'**
  String get autoDetectWorking;

  /// No description provided for @improveBackground.
  ///
  /// In en, this message translates to:
  /// **'Improve background detection'**
  String get improveBackground;

  /// No description provided for @improveBackgroundBody.
  ///
  /// In en, this message translates to:
  /// **'Android may delay detection to save battery. Mark FinWise as \"Unrestricted\" so messages are picked up promptly.'**
  String get improveBackgroundBody;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String minAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 hour} other{{n} hours}} ago'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}} ago'**
  String daysAgo(int n);

  /// No description provided for @autoDetectTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect Mobile Money transactions'**
  String get autoDetectTitle;

  /// No description provided for @autoDetectSub.
  ///
  /// In en, this message translates to:
  /// **'Reads MoMo and bank SMS on this device and records transactions automatically. Message content never leaves your phone. A permanent notification is shown while this is on, so Android keeps detecting even when you\'re in another app.'**
  String get autoDetectSub;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategory;

  /// No description provided for @transactionWord.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionWord;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" added'**
  String categoryAdded(String name);

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @recordedThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Recorded on this phone ({name})'**
  String recordedThisPhone(String name);

  /// No description provided for @recordedOtherPhone.
  ///
  /// In en, this message translates to:
  /// **'Recorded on another phone ({name})'**
  String recordedOtherPhone(String name);

  /// No description provided for @originalMessage.
  ///
  /// In en, this message translates to:
  /// **'Original message'**
  String get originalMessage;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get enterAmount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String categoriesCount(int count);

  /// No description provided for @addCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Category'**
  String get addCustomCategory;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name...'**
  String get enterCategoryName;

  /// No description provided for @yourCustomCategories.
  ///
  /// In en, this message translates to:
  /// **'Your Custom Categories:'**
  String get yourCustomCategories;

  /// No description provided for @customCategoriesNote.
  ///
  /// In en, this message translates to:
  /// **'FinWise will group these under the closest main category so your budgets stay simple.'**
  String get customCategoriesNote;

  /// No description provided for @whySpending.
  ///
  /// In en, this message translates to:
  /// **'Why are you spending this?'**
  String get whySpending;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionQ.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionQ;

  /// No description provided for @autoDetectedTip.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected from Mobile Money SMS — tap to review'**
  String get autoDetectedTip;

  /// No description provided for @autoBadge.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoBadge;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayAt(String time);

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all →'**
  String get viewAll;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @manageWisely.
  ///
  /// In en, this message translates to:
  /// **'Let\'s manage your money wisely'**
  String get manageWisely;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking Your Finances'**
  String get startTracking;

  /// No description provided for @tapPlusFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first transaction'**
  String get tapPlusFirst;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalAmount;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @accountsOverview.
  ///
  /// In en, this message translates to:
  /// **'Accounts overview'**
  String get accountsOverview;

  /// No description provided for @balanceReservedAvailable.
  ///
  /// In en, this message translates to:
  /// **'Balance · reserved · available'**
  String get balanceReservedAvailable;

  /// No description provided for @momoShort.
  ///
  /// In en, this message translates to:
  /// **'MoMo'**
  String get momoShort;

  /// No description provided for @shortBy.
  ///
  /// In en, this message translates to:
  /// **'short {amount}'**
  String shortBy(String amount);

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @healthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthExcellent;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthGood;

  /// No description provided for @healthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthFair;

  /// No description provided for @healthNeedsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get healthNeedsImprovement;

  /// No description provided for @healthCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get healthCritical;

  /// No description provided for @adviceExcellent.
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work! You\'re managing your finances excellently.'**
  String get adviceExcellent;

  /// No description provided for @adviceGood.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing well! Consider increasing your savings rate.'**
  String get adviceGood;

  /// No description provided for @adviceFair.
  ///
  /// In en, this message translates to:
  /// **'Try to reduce expenses and set some financial goals.'**
  String get adviceFair;

  /// No description provided for @adviceNeeds.
  ///
  /// In en, this message translates to:
  /// **'Focus on spending less than you earn and create a budget.'**
  String get adviceNeeds;

  /// No description provided for @adviceCritical.
  ///
  /// In en, this message translates to:
  /// **'Start by tracking all expenses and creating a savings plan.'**
  String get adviceCritical;

  /// No description provided for @financialHealth.
  ///
  /// In en, this message translates to:
  /// **'Financial Health'**
  String get financialHealth;

  /// No description provided for @profileIncomeUsed.
  ///
  /// In en, this message translates to:
  /// **'Profile income used: {amount} per month'**
  String profileIncomeUsed(String amount);

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @srGood.
  ///
  /// In en, this message translates to:
  /// **'Good! 👍'**
  String get srGood;

  /// No description provided for @srOverspending.
  ///
  /// In en, this message translates to:
  /// **'Spending more than income'**
  String get srOverspending;

  /// No description provided for @savingsRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get savingsRateTitle;

  /// No description provided for @usingProfileIncome.
  ///
  /// In en, this message translates to:
  /// **'Using your profile income (from onboarding) since no income transactions added yet.'**
  String get usingProfileIncome;

  /// No description provided for @basedOnTracked.
  ///
  /// In en, this message translates to:
  /// **'Based on your tracked income and expenses from transactions.'**
  String get basedOnTracked;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @thisMonthLower.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonthLower;

  /// No description provided for @smartTip.
  ///
  /// In en, this message translates to:
  /// **'SMART TIP'**
  String get smartTip;

  /// No description provided for @notEnoughCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet for a cash flow view'**
  String get notEnoughCashFlow;

  /// No description provided for @moneyInVsOut.
  ///
  /// In en, this message translates to:
  /// **'Money in vs out'**
  String get moneyInVsOut;

  /// No description provided for @inShort.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inShort;

  /// No description provided for @outShort.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outShort;

  /// No description provided for @monthKept.
  ///
  /// In en, this message translates to:
  /// **'This month you kept {amount}'**
  String monthKept(String amount);

  /// No description provided for @monthOverspent.
  ///
  /// In en, this message translates to:
  /// **'This month you spent {amount} more than you earned'**
  String monthOverspent(String amount);

  /// No description provided for @noSpending4Weeks.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded in the last 4 weeks'**
  String get noSpending4Weeks;

  /// No description provided for @spendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Spending trend · Last 4 weeks'**
  String get spendingTrend;

  /// No description provided for @weekSpentMore.
  ///
  /// In en, this message translates to:
  /// **'This week you spent {pct}% more than last week'**
  String weekSpentMore(String pct);

  /// No description provided for @weekSpentLess.
  ///
  /// In en, this message translates to:
  /// **'This week you spent {pct}% less than last week'**
  String weekSpentLess(String pct);

  /// No description provided for @averagePerWeek.
  ///
  /// In en, this message translates to:
  /// **'Average {amount} per week'**
  String averagePerWeek(String amount);

  /// No description provided for @whyYouSpend.
  ///
  /// In en, this message translates to:
  /// **'Why you spend'**
  String get whyYouSpend;

  /// No description provided for @tagReasonsHint.
  ///
  /// In en, this message translates to:
  /// **'Tag a few expenses as necessity, enjoyment, business or emergency to see what share of your money is essential.'**
  String get tagReasonsHint;

  /// No description provided for @whyYouSpentMonth.
  ///
  /// In en, this message translates to:
  /// **'Why you spent · This month'**
  String get whyYouSpentMonth;

  /// No description provided for @necessityShare.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of your spending was on necessities'**
  String necessityShare(String pct);

  /// No description provided for @notTagged.
  ///
  /// In en, this message translates to:
  /// **'{amount} not tagged with a reason'**
  String notTagged(String amount);

  /// No description provided for @spendingByCategoryMonth.
  ///
  /// In en, this message translates to:
  /// **'Spending by category · This month'**
  String get spendingByCategoryMonth;

  /// No description provided for @noSpendingMonth.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded this month yet.'**
  String get noSpendingMonth;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Spending Categories'**
  String get topCategories;

  /// No description provided for @thisMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthTitle;

  /// No description provided for @pctOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of total spending'**
  String pctOfTotal(String pct);

  /// No description provided for @noSpendingData.
  ///
  /// In en, this message translates to:
  /// **'No spending data to display'**
  String get noSpendingData;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @spendingCategories.
  ///
  /// In en, this message translates to:
  /// **'Spending Categories'**
  String get spendingCategories;

  /// No description provided for @categoriesIntro.
  ///
  /// In en, this message translates to:
  /// **'FinWise groups your expenses into simple categories so you can quickly see where your money goes.'**
  String get categoriesIntro;

  /// No description provided for @budgetsIntro.
  ///
  /// In en, this message translates to:
  /// **'Budgets here use your profile income from onboarding plus your real spending from transactions.'**
  String get budgetsIntro;

  /// No description provided for @categoryInsight.
  ///
  /// In en, this message translates to:
  /// **'Category insight'**
  String get categoryInsight;

  /// No description provided for @calMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calMonth;

  /// No description provided for @calTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get calTwoWeeks;

  /// No description provided for @calWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calWeek;

  /// No description provided for @txCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String txCount(int count);

  /// No description provided for @noTxThisDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions on this day'**
  String get noTxThisDay;

  /// No description provided for @addForThisDate.
  ///
  /// In en, this message translates to:
  /// **'Add an income or expense for this date to see it here.'**
  String get addForThisDate;

  /// No description provided for @transferBetweenAccounts.
  ///
  /// In en, this message translates to:
  /// **'Transfer between accounts'**
  String get transferBetweenAccounts;

  /// No description provided for @transferFee.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get transferFee;

  /// No description provided for @transferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Transfer confirmation: {details}'**
  String transferConfirmation(String details);

  /// No description provided for @errGoalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get errGoalNotFound;

  /// No description provided for @errOverRelease.
  ///
  /// In en, this message translates to:
  /// **'That would release more than was reserved. Delete or reduce the release first.'**
  String get errOverRelease;

  /// No description provided for @errOverReleaseAccount.
  ///
  /// In en, this message translates to:
  /// **'That would release more from an account than was reserved from it.'**
  String get errOverReleaseAccount;

  /// No description provided for @insightStart.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your expenses to get personalized insights!'**
  String get insightStart;

  /// No description provided for @insightHighCategory.
  ///
  /// In en, this message translates to:
  /// **'You\'re spending {pct}% on {category}. Consider reducing by {amount} {symbol} to improve your savings rate.'**
  String insightHighCategory(
      String pct, String category, String amount, String symbol);

  /// No description provided for @insightLowSavings.
  ///
  /// In en, this message translates to:
  /// **'Your savings rate is {pct}%. Try to save at least 20% of your income for better financial health.'**
  String insightLowSavings(String pct);

  /// No description provided for @insightGreat.
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'re managing your finances well. Keep tracking to maintain good habits!'**
  String get insightGreat;

  /// No description provided for @delNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in.'**
  String get delNotSignedIn;

  /// No description provided for @delNoEmail.
  ///
  /// In en, this message translates to:
  /// **'This account has no email sign-in, so it cannot be verified this way. Please contact support.'**
  String get delNoEmail;

  /// No description provided for @delWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Use the password you sign in to FinWise with (not your app-lock PIN).'**
  String get delWrongPassword;

  /// No description provided for @delOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'That password belongs to a different account.'**
  String get delOtherAccount;

  /// No description provided for @delTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get delTooMany;

  /// No description provided for @delNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get delNetwork;

  /// No description provided for @delReLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign out, sign in again, then retry deletion.'**
  String get delReLogin;

  /// No description provided for @delVerifyFailedCode.
  ///
  /// In en, this message translates to:
  /// **'Verification failed ({code}). Please try again.'**
  String delVerifyFailedCode(String code);

  /// No description provided for @delVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify your password. Please try again.'**
  String get delVerifyFailed;

  /// No description provided for @delDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your data. Please try again.'**
  String get delDataFailed;

  /// No description provided for @delAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get delAccountFailed;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Transaction alerts'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifies you when a Mobile Money transaction is auto-recorded.'**
  String get notifChannelDesc;

  /// No description provided for @notifMoneyReceived.
  ///
  /// In en, this message translates to:
  /// **'Money received'**
  String get notifMoneyReceived;

  /// No description provided for @notifMoneySent.
  ///
  /// In en, this message translates to:
  /// **'Money sent'**
  String get notifMoneySent;

  /// No description provided for @notifSmsNotRead.
  ///
  /// In en, this message translates to:
  /// **'MoMo SMS not read'**
  String get notifSmsNotRead;

  /// No description provided for @notifSmsNotReadBody.
  ///
  /// In en, this message translates to:
  /// **'Looked like a transaction but the amount/format wasn\'t recognised.'**
  String get notifSmsNotReadBody;

  /// No description provided for @notifNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction not saved'**
  String get notifNotSaved;

  /// No description provided for @notifNotSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Could not record \"{description}\". Please add it manually.'**
  String notifNotSavedBody(String description);

  /// No description provided for @monitorChannelName.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money monitoring'**
  String get monitorChannelName;

  /// No description provided for @monitorChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Shown while FinWise is watching for Mobile Money SMS to auto-track your transactions.'**
  String get monitorChannelDesc;

  /// No description provided for @monitorTitle.
  ///
  /// In en, this message translates to:
  /// **'FinWise is monitoring for transactions'**
  String get monitorTitle;

  /// No description provided for @monitorText.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money SMS auto-detect is on. Tap to open FinWise.'**
  String get monitorText;

  /// No description provided for @csvHeader.
  ///
  /// In en, this message translates to:
  /// **'Date,Type,Category,Description,Amount ({code})'**
  String csvHeader(String code);

  /// No description provided for @exportSubject.
  ///
  /// In en, this message translates to:
  /// **'FinWise Transactions Export'**
  String get exportSubject;

  /// No description provided for @exportText.
  ///
  /// In en, this message translates to:
  /// **'Your FinWise transaction export'**
  String get exportText;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'FINWISE TRANSACTION REPORT'**
  String get reportTitle;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated: {date}'**
  String reportGenerated(String date);

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get reportSummary;

  /// No description provided for @reportTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income: {amount}'**
  String reportTotalIncome(String amount);

  /// No description provided for @reportTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses: {amount}'**
  String reportTotalExpenses(String amount);

  /// No description provided for @reportBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String reportBalance(String amount);

  /// No description provided for @reportTransactions.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTIONS'**
  String get reportTransactions;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {value}'**
  String reportDate(String value);

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Type: {value}'**
  String reportType(String value);

  /// No description provided for @reportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category: {value}'**
  String reportCategory(String value);

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description: {value}'**
  String reportDescription(String value);

  /// No description provided for @reportAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount: {value}'**
  String reportAmount(String value);

  /// No description provided for @reportSubject.
  ///
  /// In en, this message translates to:
  /// **'FinWise Transaction Report'**
  String get reportSubject;

  /// No description provided for @reportText.
  ///
  /// In en, this message translates to:
  /// **'Your FinWise transaction report'**
  String get reportText;

  /// No description provided for @styleSaver.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get styleSaver;

  /// No description provided for @styleBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get styleBalanced;

  /// No description provided for @styleSpender.
  ///
  /// In en, this message translates to:
  /// **'Spender'**
  String get styleSpender;

  /// No description provided for @styleOverspender.
  ///
  /// In en, this message translates to:
  /// **'Overspender'**
  String get styleOverspender;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @setUpFinwise.
  ///
  /// In en, this message translates to:
  /// **'Set up FinWise'**
  String get setUpFinwise;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @letsSetUp.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your FinWise'**
  String get letsSetUp;

  /// No description provided for @tellUsAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about you. You can change this anytime.'**
  String get tellUsAboutYou;

  /// No description provided for @whyWeNeed.
  ///
  /// In en, this message translates to:
  /// **'Why we need this:'**
  String get whyWeNeed;

  /// No description provided for @whyWeNeedBullets.
  ///
  /// In en, this message translates to:
  /// **'• Your name personalizes your dashboard\n• Your currency is used across the whole app\n• Add an income target later in Settings (optional)'**
  String get whyWeNeedBullets;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get selectCurrency;

  /// No description provided for @allWeNeed.
  ///
  /// In en, this message translates to:
  /// **'That\'s all we need to get started. You can set an income target and more anytime in Settings.'**
  String get allWeNeed;

  /// No description provided for @whatsYourStyle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your spending style?'**
  String get whatsYourStyle;

  /// No description provided for @chooseStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose what fits you best. This helps FinWise suggest realistic budgets.'**
  String get chooseStyle;

  /// No description provided for @howThisHelps.
  ///
  /// In en, this message translates to:
  /// **'How this helps:'**
  String get howThisHelps;

  /// No description provided for @howThisHelpsBullets.
  ///
  /// In en, this message translates to:
  /// **'• Spending style: Helps FinWise give personalized budget advice later\n• Real spending: We only use your actual transactions to calculate charts and budgets'**
  String get howThisHelpsBullets;

  /// No description provided for @styleSaverSub.
  ///
  /// In en, this message translates to:
  /// **'I save a lot'**
  String get styleSaverSub;

  /// No description provided for @styleBalancedSub.
  ///
  /// In en, this message translates to:
  /// **'I\'m balanced'**
  String get styleBalancedSub;

  /// No description provided for @styleSpenderSub.
  ///
  /// In en, this message translates to:
  /// **'I spend most income'**
  String get styleSpenderSub;

  /// No description provided for @styleOverspenderSub.
  ///
  /// In en, this message translates to:
  /// **'I often overspend'**
  String get styleOverspenderSub;

  /// No description provided for @trackRealSpending.
  ///
  /// In en, this message translates to:
  /// **'FinWise will track your real spending automatically from the transactions you add on the dashboard.'**
  String get trackRealSpending;

  /// No description provided for @whatDoYouSpendOn.
  ///
  /// In en, this message translates to:
  /// **'What do you spend on?'**
  String get whatDoYouSpendOn;

  /// No description provided for @selectAllCategories.
  ///
  /// In en, this message translates to:
  /// **'Select all categories that apply to your spending'**
  String get selectAllCategories;

  /// No description provided for @mainCategoriesNote.
  ///
  /// In en, this message translates to:
  /// **'FinWise uses these 23 main categories on every page so your budgets and insights stay clear and simple.'**
  String get mainCategoriesNote;

  /// No description provided for @whyCategoriesMatter.
  ///
  /// In en, this message translates to:
  /// **'Why categories matter:'**
  String get whyCategoriesMatter;

  /// No description provided for @whyCategoriesBullets.
  ///
  /// In en, this message translates to:
  /// **'• Track spending by category (Food, Transport, etc.)\n• Get insights like \"You spent 30% on Food this month\"\n• Set budgets per category and get alerts\n• You can add more categories anytime'**
  String get whyCategoriesBullets;

  /// No description provided for @addCustomCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Add custom category...'**
  String get addCustomCategoryHint;

  /// No description provided for @addRemoveLater.
  ///
  /// In en, this message translates to:
  /// **'You can always add or remove categories later in settings.'**
  String get addRemoveLater;

  /// No description provided for @permissionNotGrantedLater.
  ///
  /// In en, this message translates to:
  /// **'Permission not granted. You can turn on auto-tracking later in Settings.'**
  String get permissionNotGrantedLater;

  /// No description provided for @trackAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Track money automatically'**
  String get trackAutomatically;

  /// No description provided for @trackAutomaticallyBody.
  ///
  /// In en, this message translates to:
  /// **'This is what makes FinWise different. It reads your Mobile Money SMS and records every payment and deposit for you — no manual typing.'**
  String get trackAutomaticallyBody;

  /// No description provided for @featInstant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get featInstant;

  /// No description provided for @featInstantBody.
  ///
  /// In en, this message translates to:
  /// **'New MoMo transactions appear on your balance within seconds.'**
  String get featInstantBody;

  /// No description provided for @featPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get featPrivate;

  /// No description provided for @featPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on your phone. Nothing is uploaded or shared.'**
  String get featPrivateBody;

  /// No description provided for @featAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get featAutomatic;

  /// No description provided for @featAutomaticBody.
  ///
  /// In en, this message translates to:
  /// **'Amount, direction and category are filled in for you.'**
  String get featAutomaticBody;

  /// No description provided for @autoTrackingOnFinish.
  ///
  /// In en, this message translates to:
  /// **'Auto-tracking is on. Tap Get Started to finish.'**
  String get autoTrackingOnFinish;

  /// No description provided for @requestingPermission.
  ///
  /// In en, this message translates to:
  /// **'Requesting permission…'**
  String get requestingPermission;

  /// No description provided for @enableAutoTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable auto-tracking'**
  String get enableAutoTracking;

  /// No description provided for @turnOffAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can turn this off anytime in Settings.'**
  String get turnOffAnytime;

  /// No description provided for @optionalSkip.
  ///
  /// In en, this message translates to:
  /// **'Optional — you can skip and turn it on later in Settings.'**
  String get optionalSkip;

  /// No description provided for @faqS1.
  ///
  /// In en, this message translates to:
  /// **'Automatic tracking (SMS)'**
  String get faqS1;

  /// No description provided for @faqS1Q1.
  ///
  /// In en, this message translates to:
  /// **'How does auto-detect work?'**
  String get faqS1Q1;

  /// No description provided for @faqS1A1.
  ///
  /// In en, this message translates to:
  /// **'When you turn it on, FinWise reads incoming Mobile Money SMS (MTN, Airtel, bank alerts) on your phone and records the transaction automatically — amount, whether it was money in or out, and who it was with. It works fully offline: nothing is sent anywhere except your own device and, if you\'re signed in, your own FinWise account.'**
  String get faqS1A1;

  /// No description provided for @faqS1Q2.
  ///
  /// In en, this message translates to:
  /// **'Does FinWise read my personal messages?'**
  String get faqS1Q2;

  /// No description provided for @faqS1A2.
  ///
  /// In en, this message translates to:
  /// **'No. Only messages that look like Mobile Money or bank notifications are ever processed — everything else is ignored and never stored or transmitted.'**
  String get faqS1A2;

  /// No description provided for @faqS1Q3.
  ///
  /// In en, this message translates to:
  /// **'Why did I get two notifications for one payment?'**
  String get faqS1Q3;

  /// No description provided for @faqS1A3.
  ///
  /// In en, this message translates to:
  /// **'That shouldn\'t happen. If the same amount, same person, and same type of message (both \"received\" or both \"sent\") arrives twice within a few minutes, FinWise treats the second one as a repeat and does not record it again. If you still see a duplicate, use \"Email us\" below with the date/amount so it can be fixed.'**
  String get faqS1A3;

  /// No description provided for @faqS1Q4.
  ///
  /// In en, this message translates to:
  /// **'A promotional or \"bundle expired\" SMS was recorded as an expense.'**
  String get faqS1Q4;

  /// No description provided for @faqS1A4.
  ///
  /// In en, this message translates to:
  /// **'FinWise filters out common promotional wording, but providers change their message templates over time. If one slips through, delete it from your transaction list — swipe left, or tap it and delete.'**
  String get faqS1A4;

  /// No description provided for @faqS2.
  ///
  /// In en, this message translates to:
  /// **'Transfers between your own accounts'**
  String get faqS2;

  /// No description provided for @faqS2Q1.
  ///
  /// In en, this message translates to:
  /// **'I moved money from Mobile Money to my bank — why isn\'t it income or an expense?'**
  String get faqS2Q1;

  /// No description provided for @faqS2A1.
  ///
  /// In en, this message translates to:
  /// **'Moving money between accounts you own (Mobile Money ↔ bank, or saving/withdrawing MoCash) isn\'t a real gain or loss — it\'s still your money. FinWise records these as a neutral \"Transfer\" so they never inflate your income or spending totals.'**
  String get faqS2A1;

  /// No description provided for @faqS2Q2.
  ///
  /// In en, this message translates to:
  /// **'How does FinWise know it\'s a transfer and not a real payment?'**
  String get faqS2Q2;

  /// No description provided for @faqS2A2.
  ///
  /// In en, this message translates to:
  /// **'Mostly by pattern: one movement between your own accounts usually produces two SMS — one saying money left an account, another saying the same amount arrived — with the same amount, the same name, within a few minutes of each other. FinWise pairs those up automatically. It does not rely on your profile name, so it works even if your accounts are registered under a different name.'**
  String get faqS2A2;

  /// No description provided for @faqS2Q3.
  ///
  /// In en, this message translates to:
  /// **'What about a loan from MoCash?'**
  String get faqS2Q3;

  /// No description provided for @faqS2A3.
  ///
  /// In en, this message translates to:
  /// **'A loan genuinely changes what you have or owe, so it\'s recorded normally — receiving a loan is income, repaying it is an expense. Only a plain save/withdraw within MoCash is treated as a transfer.'**
  String get faqS2A3;

  /// No description provided for @faqS2Q4.
  ///
  /// In en, this message translates to:
  /// **'Does a fee on a transfer get recorded?'**
  String get faqS2Q4;

  /// No description provided for @faqS2A4.
  ///
  /// In en, this message translates to:
  /// **'Yes. The transfer itself is neutral, but any fee charged on it is a real cost, so it\'s recorded separately as a small expense.'**
  String get faqS2A4;

  /// No description provided for @faqS3.
  ///
  /// In en, this message translates to:
  /// **'Goals & saved money'**
  String get faqS3;

  /// No description provided for @faqS3Q1.
  ///
  /// In en, this message translates to:
  /// **'When I put money toward a goal, does that count as spent?'**
  String get faqS3Q1;

  /// No description provided for @faqS3A1.
  ///
  /// In en, this message translates to:
  /// **'No. Money reserved for a goal is set aside, not spent — it still shows in your account. It only becomes a real expense once you mark the goal as purchased.'**
  String get faqS3A1;

  /// No description provided for @faqS3Q2.
  ///
  /// In en, this message translates to:
  /// **'I marked a goal as purchased but I\'d already recorded that expense from an SMS — will it be counted twice?'**
  String get faqS3Q2;

  /// No description provided for @faqS3A2.
  ///
  /// In en, this message translates to:
  /// **'No — when marking a goal purchased, you can link it to a transaction that\'s already recorded (e.g. auto-detected from SMS) instead of creating a new one, so it\'s only counted once.'**
  String get faqS3A2;

  /// No description provided for @faqS4.
  ///
  /// In en, this message translates to:
  /// **'Currency & accounts'**
  String get faqS4;

  /// No description provided for @faqS4Q1.
  ///
  /// In en, this message translates to:
  /// **'What happens if I change my currency after adding transactions?'**
  String get faqS4Q1;

  /// No description provided for @faqS4A1.
  ///
  /// In en, this message translates to:
  /// **'Amounts are not converted — a transaction recorded as 500 RWF would simply display as 500 in the new currency, same number, different label. FinWise warns you about this before the change goes through, since it doesn\'t use live exchange rates.'**
  String get faqS4A1;

  /// No description provided for @faqS5.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get faqS5;

  /// No description provided for @faqS5Q1.
  ///
  /// In en, this message translates to:
  /// **'Does FinWise collect my photo or profile picture?'**
  String get faqS5Q1;

  /// No description provided for @faqS5A1.
  ///
  /// In en, this message translates to:
  /// **'No. FinWise shows your initial as your avatar instead of a photo — no images are ever uploaded.'**
  String get faqS5A1;

  /// No description provided for @faqS5Q2.
  ///
  /// In en, this message translates to:
  /// **'Can I use FinWise without SMS auto-detect?'**
  String get faqS5Q2;

  /// No description provided for @faqS5A2.
  ///
  /// In en, this message translates to:
  /// **'Yes — it\'s optional. You can add every transaction manually and never grant SMS permission at all.'**
  String get faqS5A2;

  /// No description provided for @faqS5Q3.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account and data?'**
  String get faqS5Q3;

  /// No description provided for @faqS5A3.
  ///
  /// In en, this message translates to:
  /// **'Settings → Delete account. This permanently removes your transactions, goals, profile, and sign-in — it cannot be undone, so consider exporting your data first.'**
  String get faqS5A3;

  /// No description provided for @faqS5Q4.
  ///
  /// In en, this message translates to:
  /// **'Can I export my data?'**
  String get faqS5Q4;

  /// No description provided for @faqS5A4.
  ///
  /// In en, this message translates to:
  /// **'Yes — Settings → Export to CSV or Export Report (PDF).'**
  String get faqS5A4;

  /// No description provided for @faqS6.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get faqS6;

  /// No description provided for @faqS6Q1.
  ///
  /// In en, this message translates to:
  /// **'How do I turn on PIN or fingerprint lock?'**
  String get faqS6Q1;

  /// No description provided for @faqS6A1.
  ///
  /// In en, this message translates to:
  /// **'Settings → Security → App Lock. You can use a PIN, or your phone\'s fingerprint/face unlock where supported.'**
  String get faqS6A1;

  /// No description provided for @faqS6Q2.
  ///
  /// In en, this message translates to:
  /// **'I forgot my PIN.'**
  String get faqS6Q2;

  /// No description provided for @faqS6A2.
  ///
  /// In en, this message translates to:
  /// **'On the lock screen, tap \"Forgot PIN?\" — this signs you out and back in with your FinWise email/password, then lets you set a new PIN.'**
  String get faqS6A2;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get stillNeedHelp;

  /// No description provided for @reachOutDirectly.
  ///
  /// In en, this message translates to:
  /// **'Reach out directly and we\'ll get back to you.'**
  String get reachOutDirectly;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get legalTermsTitle;

  /// No description provided for @legalTermsIntro.
  ///
  /// In en, this message translates to:
  /// **'By creating a FinWise account you agree to these terms. Please read them carefully.'**
  String get legalTermsIntro;

  /// No description provided for @legalTermsS1T.
  ///
  /// In en, this message translates to:
  /// **'1. Using FinWise'**
  String get legalTermsS1T;

  /// No description provided for @legalTermsS1C.
  ///
  /// In en, this message translates to:
  /// **'• FinWise helps you track your personal income, spending and savings goals.\n• You must be old enough to enter a binding agreement in your country.\n• You are responsible for keeping your account credentials secure.\n• Use the app only for lawful, personal financial management.'**
  String get legalTermsS1C;

  /// No description provided for @legalTermsS2T.
  ///
  /// In en, this message translates to:
  /// **'2. Your Data Is Yours'**
  String get legalTermsS2T;

  /// No description provided for @legalTermsS2C.
  ///
  /// In en, this message translates to:
  /// **'• The financial information you record belongs to you.\n• We store it to provide the service and sync it across your devices.\n• You can export or delete your data at any time from Settings.'**
  String get legalTermsS2C;

  /// No description provided for @legalTermsS3T.
  ///
  /// In en, this message translates to:
  /// **'3. Mobile Money SMS Detection'**
  String get legalTermsS3T;

  /// No description provided for @legalTermsS3C.
  ///
  /// In en, this message translates to:
  /// **'• This optional feature reads Mobile Money messages on your device to record transactions automatically.\n• Messages are processed entirely on your phone. Message content is never uploaded or shared.\n• Only financial messages are used; personal SMS are ignored.\n• You can turn this off at any time in Settings.'**
  String get legalTermsS3C;

  /// No description provided for @legalTermsS4T.
  ///
  /// In en, this message translates to:
  /// **'4. Accuracy & Financial Decisions'**
  String get legalTermsS4T;

  /// No description provided for @legalTermsS4C.
  ///
  /// In en, this message translates to:
  /// **'• FinWise is a tracking tool, not financial, investment, tax or legal advice.\n• Automatic detection and categorisation may occasionally be wrong — always review your records.\n• You remain responsible for your own financial decisions.'**
  String get legalTermsS4C;

  /// No description provided for @legalTermsS5T.
  ///
  /// In en, this message translates to:
  /// **'5. Availability'**
  String get legalTermsS5T;

  /// No description provided for @legalTermsS5C.
  ///
  /// In en, this message translates to:
  /// **'• We aim to keep FinWise available and accurate, but the service is provided \"as is\".\n• Features may change, and syncing depends on your internet connection.'**
  String get legalTermsS5C;

  /// No description provided for @legalTermsS6T.
  ///
  /// In en, this message translates to:
  /// **'6. Ending Your Account'**
  String get legalTermsS6T;

  /// No description provided for @legalTermsS6C.
  ///
  /// In en, this message translates to:
  /// **'• You may stop using FinWise and delete your data at any time.\n• We may suspend accounts that misuse the service or breach these terms.'**
  String get legalTermsS6C;

  /// No description provided for @legalTermsS7T.
  ///
  /// In en, this message translates to:
  /// **'7. Changes to These Terms'**
  String get legalTermsS7T;

  /// No description provided for @legalTermsS7C.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms as the app evolves. Continuing to use FinWise after an update means you accept the revised terms.'**
  String get legalTermsS7C;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacyIntro.
  ///
  /// In en, this message translates to:
  /// **'FinWise helps you track your money. This policy explains exactly what we collect, what stays on your phone, and what we never do.'**
  String get legalPrivacyIntro;

  /// No description provided for @legalPrivacyS1T.
  ///
  /// In en, this message translates to:
  /// **'1. What Stays Only On Your Phone'**
  String get legalPrivacyS1T;

  /// No description provided for @legalPrivacyS1C.
  ///
  /// In en, this message translates to:
  /// **'The following NEVER leaves your device and is never uploaded:\n\n• SMS message content. Mobile Money and bank messages are read and analysed entirely on your phone. We never upload, store or transmit message text.\n• Your app lock PIN. Stored only as a salted, irreversible hash.\n• Fingerprint / face data. Android verifies you in secure hardware and tells the app only \"yes\" or \"no\". FinWise never receives, sees or stores biometric data.'**
  String get legalPrivacyS1C;

  /// No description provided for @legalPrivacyS2T.
  ///
  /// In en, this message translates to:
  /// **'2. Mobile Money SMS Detection (Optional)'**
  String get legalPrivacyS2T;

  /// No description provided for @legalPrivacyS2C.
  ///
  /// In en, this message translates to:
  /// **'If you enable auto-detection, FinWise uses SMS permissions to record your transactions automatically.\n\n• Purpose: to read financial alerts from Mobile Money providers and banks so transactions are recorded without manual typing.\n• Only financial messages are used. Personal messages are ignored.\n• Only the extracted amount, direction, date and counterparty name are saved as a transaction — never the raw message.\n• Processing happens on your device, offline.\n• You can turn this off at any time in Settings, and revoke the permission in your phone settings.\n\nThis use complies with Google Play\'s permitted use for SMS-based money management.'**
  String get legalPrivacyS2C;

  /// No description provided for @legalPrivacyS3T.
  ///
  /// In en, this message translates to:
  /// **'3. Information We Collect'**
  String get legalPrivacyS3T;

  /// No description provided for @legalPrivacyS3C.
  ///
  /// In en, this message translates to:
  /// **'• Account: email address and name (for sign-in and personalisation)\n• Financial records: transactions you add or that are detected — amount, description, category, date and account type\n• Goals: names, targets, dates and contribution history\n• Preferences: currency, optional income target, app settings\n\nWe do NOT collect photos. FinWise has no photo upload and does not request camera or gallery access — your avatar is simply the first letter of your name.'**
  String get legalPrivacyS3C;

  /// No description provided for @legalPrivacyS4T.
  ///
  /// In en, this message translates to:
  /// **'4. Where Your Data Is Stored'**
  String get legalPrivacyS4T;

  /// No description provided for @legalPrivacyS4C.
  ///
  /// In en, this message translates to:
  /// **'• On your device: a local copy of your transactions and settings, so the app works offline and starts quickly.\n• In the cloud (Firebase, operated by Google): your account details, transactions and goals — so your data survives a lost phone and syncs across devices.\n\nCloud data is encrypted in transit and at rest. Security rules ensure only your signed-in account can read your records.'**
  String get legalPrivacyS4C;

  /// No description provided for @legalPrivacyS5T.
  ///
  /// In en, this message translates to:
  /// **'5. Notifications & Background Activity'**
  String get legalPrivacyS5T;

  /// No description provided for @legalPrivacyS5C.
  ///
  /// In en, this message translates to:
  /// **'• FinWise shows a notification when a transaction is detected.\n• While auto-detection is on, a persistent notification indicates that FinWise is monitoring for transactions. Android requires this for any app doing background work, and it keeps detection reliable.\n• Background activity is used only to detect transactions. We do not track your location or usage of other apps.'**
  String get legalPrivacyS5C;

  /// No description provided for @legalPrivacyS6T.
  ///
  /// In en, this message translates to:
  /// **'6. What We Never Do'**
  String get legalPrivacyS6T;

  /// No description provided for @legalPrivacyS6C.
  ///
  /// In en, this message translates to:
  /// **'• We never sell your personal information.\n• We never share your financial data with advertisers or data brokers.\n• We never upload SMS content.\n• We do not move money, access your bank or Mobile Money account, or ask for your PIN or banking credentials.\n• We show no advertising.'**
  String get legalPrivacyS6C;

  /// No description provided for @legalPrivacyS7T.
  ///
  /// In en, this message translates to:
  /// **'7. Third-Party Services'**
  String get legalPrivacyS7T;

  /// No description provided for @legalPrivacyS7C.
  ///
  /// In en, this message translates to:
  /// **'We use Firebase (Google) for sign-in, database and file storage. Google\'s privacy policy applies to their handling of that data: https://policies.google.com/privacy\n\nNo other third-party service receives your data.'**
  String get legalPrivacyS7C;

  /// No description provided for @legalPrivacyS8T.
  ///
  /// In en, this message translates to:
  /// **'8. Your Rights & Control'**
  String get legalPrivacyS8T;

  /// No description provided for @legalPrivacyS8C.
  ///
  /// In en, this message translates to:
  /// **'• Access: view all of your data inside the app\n• Export: download your transactions as CSV or PDF\n• Delete: remove individual records, clear all data, or delete your account entirely\n• Withdraw consent: turn off SMS detection at any time\n• Sign out: stops cloud sync on that device'**
  String get legalPrivacyS8C;

  /// No description provided for @legalPrivacyS9T.
  ///
  /// In en, this message translates to:
  /// **'9. Data Retention'**
  String get legalPrivacyS9T;

  /// No description provided for @legalPrivacyS9C.
  ///
  /// In en, this message translates to:
  /// **'Your data is kept until you delete it. Deleting a record removes it from your device and the cloud. Deleting your account removes your stored data permanently.'**
  String get legalPrivacyS9C;

  /// No description provided for @legalPrivacyS10T.
  ///
  /// In en, this message translates to:
  /// **'10. Children\'s Privacy'**
  String get legalPrivacyS10T;

  /// No description provided for @legalPrivacyS10C.
  ///
  /// In en, this message translates to:
  /// **'FinWise is not intended for anyone under 13. We do not knowingly collect information from children.'**
  String get legalPrivacyS10C;

  /// No description provided for @legalPrivacyS11T.
  ///
  /// In en, this message translates to:
  /// **'11. Changes To This Policy'**
  String get legalPrivacyS11T;

  /// No description provided for @legalPrivacyS11C.
  ///
  /// In en, this message translates to:
  /// **'If this policy changes, the date below is updated. Significant changes affecting how your data is used will be announced in the app.'**
  String get legalPrivacyS11C;

  /// No description provided for @legalPrivacyS12T.
  ///
  /// In en, this message translates to:
  /// **'12. Contact'**
  String get legalPrivacyS12T;

  /// No description provided for @legalPrivacyS12C.
  ///
  /// In en, this message translates to:
  /// **'For any privacy question or to request deletion of your data, contact us through Help & Support in the app.'**
  String get legalPrivacyS12C;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @legalUpdatedDate.
  ///
  /// In en, this message translates to:
  /// **'July 2026'**
  String get legalUpdatedDate;

  /// No description provided for @legalTranslationNote.
  ///
  /// In en, this message translates to:
  /// **''**
  String get legalTranslationNote;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock FinWise to view your finances'**
  String get biometricReason;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
