// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kinyarwanda (`rw`).
class AppLocalizationsRw extends AppLocalizations {
  AppLocalizationsRw([String locale = 'rw']) : super(locale);

  @override
  String get cancel => 'Hagarika';

  @override
  String get save => 'Bika';

  @override
  String get delete => 'Siba';

  @override
  String get confirm => 'Emeza';

  @override
  String get close => 'Funga';

  @override
  String get done => 'Byarangiye';

  @override
  String get later => 'Nyuma';

  @override
  String get clearAll => 'Siba byose';

  @override
  String get all => 'Byose';

  @override
  String get previous => 'Ibibanza';

  @override
  String get next => 'Ibikurikira';

  @override
  String get navHome => 'Ahabanza';

  @override
  String get navBudget => 'Ingengo';

  @override
  String get navGoals => 'Intego';

  @override
  String get navHistory => 'Amateka';

  @override
  String get navSettings => 'Igenamiterere';

  @override
  String get settingsTitle => 'Igenamiterere';

  @override
  String get language => 'Ururimi';

  @override
  String get chooseLanguage => 'Hitamo ururimi';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKinyarwanda => 'Ikinyarwanda';

  @override
  String get sectionProfile => 'Umwirondoro';

  @override
  String get sectionData => 'Gucunga amakuru';

  @override
  String get sectionSecurity => 'Umutekano';

  @override
  String get sectionAutomation => 'Ibikora ubwabyo';

  @override
  String get sectionAppearance => 'Imigaragarire';

  @override
  String get sectionAbout => 'Ibyerekeye porogaramu';

  @override
  String get profileOnboarding => 'Umwirondoro n\'amakuru y\'ibanze';

  @override
  String get profileOnboardingSub => 'Hindura izina n\'ifaranga';

  @override
  String get incomeTarget => 'Intego y\'amafaranga winjiza';

  @override
  String incomeTargetSet(String amount) {
    return '$amount ku kwezi — ikoreshwa mu kubara igipimo cyo kuzigama';
  }

  @override
  String get incomeTargetUnset =>
      'Shyiraho intego (bitari ngombwa) yo kubara igipimo cyo kuzigama';

  @override
  String get logout => 'Sohoka';

  @override
  String get logoutSub => 'Sohoka usubire ku kwinjira';

  @override
  String get deleteAccount => 'Siba konti';

  @override
  String get deleteAccountSub => 'Siba burundu konti yawe n\'amakuru yose';

  @override
  String get calendarView => 'Kalendari';

  @override
  String get calendarViewSub => 'Reba ibikorwa ukurikije amatariki';

  @override
  String get exportCsv => 'Kohereza nka CSV';

  @override
  String get exportCsvSub => 'Kuramo ibikorwa nka CSV';

  @override
  String get exportReport => 'Kohereza raporo';

  @override
  String get exportReportSub => 'Kora raporo y\'ibikorwa';

  @override
  String get clearTransactions => 'Siba ibikorwa byose';

  @override
  String get clearTransactionsSub => 'Kuraho amakuru yose y\'ibikorwa';

  @override
  String get clearGoals => 'Siba intego zose';

  @override
  String get clearGoalsSub => 'Kuraho amakuru yose y\'intego';

  @override
  String get darkMode => 'Ibara ryijimye';

  @override
  String get darkModeSub => 'Hindura ibara rya porogaramu';

  @override
  String get currency => 'Ifaranga';

  @override
  String get appVersion => 'Verisiyo ya porogaramu';

  @override
  String get loading => 'Biratangira…';

  @override
  String get faqHelp => 'Ibibazo n\'ubufasha';

  @override
  String get faqHelpSub => 'Ibibazo bikunze kubazwa, cyangwa utwandikire';

  @override
  String get privacyPolicy => 'Politiki y\'ibanga';

  @override
  String get privacyPolicySub => 'Ibyo dukusanya n\'ibiguma kuri telefoni yawe';

  @override
  String get terms => 'Amategeko n\'amabwiriza';

  @override
  String get termsSub => 'Amasezerano wemeye wiyandikisha';

  @override
  String get periodThisMonth => 'Uku kwezi';

  @override
  String get periodLastMonth => 'Ukwezi gushize';

  @override
  String get periodThisYear => 'Uyu mwaka';

  @override
  String periodLastDays(int days) {
    return 'Iminsi $days ishize';
  }

  @override
  String get periodAllTime => 'Igihe cyose';

  @override
  String get periodCustom => 'Hitamo amatariki…';

  @override
  String get showPeriod => 'Erekana igihe';

  @override
  String get selectPeriod => 'Hitamo igihe';

  @override
  String get show => 'Erekana';

  @override
  String get moneyIn => 'Ayinjiye';

  @override
  String get spent => 'Ayakoreshejwe';

  @override
  String get left => 'Asigaye';

  @override
  String get savingsRate => 'Igipimo cyo kuzigama';

  @override
  String setAsideForGoals(String amount) {
    return 'Ayabikiwe intego: $amount';
  }

  @override
  String safeToSpend(String amount) {
    return 'Ushobora gukoresha: $amount';
  }

  @override
  String overBy(String amount) {
    return 'Warengejeho $amount';
  }

  @override
  String youKept(String amount) {
    return 'Wasigaranye $amount';
  }

  @override
  String overspentBy(String amount) {
    return 'Wakoresheje arenga $amount';
  }

  @override
  String earnedPctOfIncome(String pct) {
    return 'winjije $pct% by\'ayo usanzwe winjiza';
  }

  @override
  String get greatPace => 'Uri mu nzira nziza — komereza aho.';

  @override
  String get watchSpending =>
      'Gabanya ibyo ukoresha kugira ngo uzigame byinshi.';

  @override
  String get noIncomeCurrent =>
      'Andika amafaranga winjije muri iki gihe, cyangwa ushyireho intego y\'amafaranga winjiza mu Igenamiterere, kugira ngo ubone igipimo cyo kuzigama.';

  @override
  String get noIncomePast =>
      'Nta mafaranga yinjiye yanditswe muri iki gihe. Shyiraho intego y\'amafaranga winjiza mu Igenamiterere kugira ngo ubone igipimo cyo kuzigama.';

  @override
  String get historyTitle => 'Amateka y\'amafaranga';

  @override
  String get yourHistory => 'Amateka yawe';

  @override
  String get historySubtitle =>
      'Shakisha, shungura kandi urebe ibikorwa byawe byose ahantu hamwe.';

  @override
  String get searchTransactions => 'Shakisha...';

  @override
  String get filter => 'Shungura';

  @override
  String get filterTitle => 'Shungura ibikorwa';

  @override
  String get filterByType => 'Ubwoko:';

  @override
  String get filterByCategory => 'Icyiciro:';

  @override
  String get income => 'Ayinjiye';

  @override
  String get expense => 'Ayasohotse';

  @override
  String get transfer => 'Ihererekanya';

  @override
  String get items => 'Umubare';

  @override
  String get noTransactions => 'Nta bikorwa bibonetse';

  @override
  String get tryAdjusting =>
      'Gerageza guhindura ibyo ushakisha cyangwa ibyo washunguye';

  @override
  String nothingInPeriod(String period) {
    return 'Nta kintu muri \"$period\". Gerageza ikindi gihe, cyangwa uhitemo \"Igihe cyose\".';
  }

  @override
  String get goalsTitle => 'Intego';

  @override
  String get goalsEmptyTitle => 'Zigamira ibikunezeza';

  @override
  String get goalsEmptyBody =>
      'Shyiraho intego, ubikire amafaranga, maze ukurikirane aho ugeze. Amafaranga ubikiye aguma ari ayawe — gusa ntabarwa nk\'ayo ushobora gukoresha.';

  @override
  String get createFirstGoal => 'Kora intego yawe ya mbere';

  @override
  String get activeGoals => 'Intego zikomeje';

  @override
  String get completed => 'Zagezweho';

  @override
  String get goalsOverview => 'Incamake y\'intego';

  @override
  String reservedOfTargeted(String target, String pct) {
    return 'abikiwe kuri $target y\'intego · $pct%';
  }

  @override
  String get total => 'Zose';

  @override
  String get active => 'Zikomeje';

  @override
  String goalsReady(int count) {
    return 'Intego $count zuzuye — witeguye kugura';
  }

  @override
  String get statusReady => 'Witeguye kugura';

  @override
  String get statusOverdue => 'Igihe cyarenze';

  @override
  String get statusOnTrack => 'Biragenda neza';

  @override
  String get statusBehind => 'Uri inyuma';

  @override
  String get pastDue => 'Igihe cyarenze';

  @override
  String daysLeft(int days) {
    return 'Hasigaye iminsi $days';
  }

  @override
  String get paid => 'yishyuwe';

  @override
  String paidPlanned(String amount) {
    return 'yishyuwe · wari wateganyije $amount';
  }

  @override
  String ofAmount(String amount) {
    return 'kuri $amount';
  }

  @override
  String get fullyFundedTap => 'Amafaranga yuzuye — kanda wemeze ko waguze';

  @override
  String addPerMonth(String amount) {
    return 'Bika $amount buri kwezi kugira ngo urangize ku gihe';
  }

  @override
  String get addContribution => 'Ongeraho amafaranga';

  @override
  String get details => 'Ibisobanuro';

  @override
  String get reserveMoney => 'Bika amafaranga';

  @override
  String get reserveExplain =>
      'Ashyira amafaranga yo kuri konti muri iyi ntego. Aguma ari ayawe — arabikwa gusa, ntabarwa nk\'ayakoreshejwe.';

  @override
  String get fromAccount => 'Kuva kuri konti';

  @override
  String amountWithCode(String code) {
    return 'Amafaranga ($code)';
  }

  @override
  String get noteOptional => 'Icyitonderwa (bitari ngombwa)';

  @override
  String get reserve => 'Bika';

  @override
  String freeAmount(String account, String amount) {
    return '$account · $amount aboneka';
  }

  @override
  String get enterAmountAbove0 => 'Andika amafaranga arenze 0';

  @override
  String onlyHasAvailable(String account, String amount) {
    return '$account ifite gusa $amount aboneka.';
  }

  @override
  String reservedFrom(String amount, String account) {
    return 'Wabitse $amount kuva kuri $account';
  }

  @override
  String reservedOver(String amount, String over) {
    return 'Wabitse $amount — ni $over birenze ibyo iyi ntego ikeneye. Ushobora kuyagarura igihe icyo ari cyo cyose.';
  }

  @override
  String get accountCash => 'Amafaranga mu ntoki';

  @override
  String get accountBank => 'Banki';

  @override
  String get accountMobileMoney => 'Mobile Money';

  @override
  String get release => 'Garura';

  @override
  String get bought => 'Naraguze';

  @override
  String target(String date) {
    return 'Intego: $date';
  }

  @override
  String purchasedOn(String date) {
    return 'Byaguzwe $date';
  }

  @override
  String reservedOfPct(String target, String pct) {
    return 'abikiwe kuri $target · $pct%';
  }

  @override
  String paidPlannedCompleted(String amount) {
    return 'yishyuwe · wari wateganyije $amount · byagezweho';
  }

  @override
  String get paidCompleted => 'yishyuwe · byagezweho';

  @override
  String readyExtra(String amount) {
    return 'Witeguye kugura — wabitse $amount birenze igiciro. Ushobora kugarura ayarenze.';
  }

  @override
  String get fullyFundedBought => 'Amafaranga yuzuye — kanda Naraguze nugura.';

  @override
  String stillNeed(String amount, String monthly) {
    return 'Hasigaye $amount · hafi $monthly buri kwezi';
  }

  @override
  String get differentPrice => 'Wabonye ikindi giciro? Hindura igiciro';

  @override
  String plannedPriceChanged(String amount) {
    return 'Wari wateganyije $amount · Igiciro cyongeye guhinduka? Hindura';
  }

  @override
  String get editGoal => 'Hindura intego';

  @override
  String get editGoalSub => 'Izina, amafaranga, itariki cyangwa ishusho';

  @override
  String get updatePrice => 'Hindura igiciro';

  @override
  String get updatePriceSub =>
      'Igiciro nyacyo kiri hejuru cyangwa hasi y\'icyo wateganyije';

  @override
  String get undoPurchase => 'Hagarika kugura';

  @override
  String get undoPurchaseSub => 'Ongera ufungure iyi ntego wongere ubike';

  @override
  String get deleteGoal => 'Siba intego';

  @override
  String get deleteGoalSub => 'Amafaranga abikiwe asubira mu aboneka';

  @override
  String get reservedFromTitle => 'Yabikiwe kuva';

  @override
  String get contributionHistory => 'Amateka y\'ibyo wabitse';

  @override
  String get tapToEdit =>
      'Kanda ku gikorwa kugira ngo ugihindure cyangwa ugisibe.';

  @override
  String get undoToEdit => 'Hagarika kugura kugira ngo uhindure ibi bikorwa.';

  @override
  String get noMoneyReserved => 'Nta mafaranga arabikwa.';

  @override
  String get reservedLabel => 'Wabitse';

  @override
  String get releasedLabel => 'Wagaruye';

  @override
  String get editOrDelete => 'Hindura cyangwa usibe';

  @override
  String get editThisReserve => 'Hindura ibi wabitse';

  @override
  String get editThisRelease => 'Hindura ibi wagaruye';

  @override
  String get editEntrySub => 'Hindura amafaranga, konti cyangwa icyitonderwa';

  @override
  String get deleteThisReserve => 'Siba ibi wabitse';

  @override
  String get deleteThisRelease => 'Siba ibi wagaruye';

  @override
  String get deleteReserveSub => 'Amafaranga asubira mu aboneka';

  @override
  String get deleteReleaseSub => 'Amafaranga yongera kubikwa';

  @override
  String get editReserve => 'Hindura ibyabitswe';

  @override
  String get editRelease => 'Hindura ibyagaruwe';

  @override
  String get releasedTo => 'Yagaruwe kuri';

  @override
  String get deleteReserveQ => 'Gusiba ibyabitswe?';

  @override
  String get deleteReleaseQ => 'Gusiba ibyagaruwe?';

  @override
  String deleteReserveBody(String amount) {
    return '$amount azasubira mu mafaranga yawe aboneka.';
  }

  @override
  String deleteReleaseBody(String amount, String goal) {
    return '$amount azongera abikirwe \"$goal\".';
  }

  @override
  String get entryUpdated => 'Byahinduwe';

  @override
  String get entryDeleted => 'Byasibwe';

  @override
  String get purchaseSummary => 'Incamake yo kugura';

  @override
  String get planned => 'Wateganyije';

  @override
  String get paidCap => 'Wishyuye';

  @override
  String get underPlan => 'Munsi y\'igenamigambi';

  @override
  String get overPlan => 'Hejuru y\'igenamigambi';

  @override
  String paidLessThanPlanned(String amount) {
    return 'Wishyuye $amount munsi y\'ibyo wateganyije 🎉';
  }

  @override
  String get paidWith => 'Wishyuye ukoresheje';

  @override
  String get noPaymentLinked => 'Nta bwishyu buhujwe.';

  @override
  String get priceUpdates => 'Ihinduka ry\'igiciro';

  @override
  String celebrateFundedTitle(String goal) {
    return '$goal: amafaranga yuzuye!';
  }

  @override
  String celebrateFundedReserved(String amount) {
    return 'Ufite $amount wabitse.';
  }

  @override
  String celebrateFundedReservedSpan(String amount, String span) {
    return 'Ufite $amount wabitse — wazigamye mu $span.';
  }

  @override
  String get celebrateFundedAsk => 'Waramaze kugura? Funga intego ubu.';

  @override
  String get iBoughtIt => 'Naraguze';

  @override
  String get celebrateCompletedTitle => 'Intego yagezweho!';

  @override
  String celebratePaid(String goal, String amount) {
    return '$goal — wishyuye $amount';
  }

  @override
  String celebratePaidUnder(String goal, String amount, String under) {
    return '$goal — wishyuye $amount · $under munsi y\'igenamigambi';
  }

  @override
  String celebrateSavedOver(String span) {
    return 'Wabizigamiye mu $span.';
  }

  @override
  String celebrateReturned(String amount) {
    return '$amount yasubiye mu mafaranga yawe aboneka.';
  }

  @override
  String get startNewGoal => 'Tangira indi ntego';

  @override
  String get spanLessThanMonth => 'munsi y\'ukwezi';

  @override
  String spanMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'mezi $months',
      one: 'kwezi 1',
    );
    return '$_temp0';
  }

  @override
  String get goalTitle => 'Intego';

  @override
  String get goalNoLongerExists => 'Iyi ntego ntikibaho.';

  @override
  String get boughtWithoutReserving =>
      'Byaguzwe utabanje kubika amafaranga muri FinWise.';

  @override
  String savedOverContributions(String span, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'inshuro $count',
      one: 'inshuro 1',
    );
    return 'Wazigamye mu $span · $_temp0';
  }

  @override
  String missingPayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ubwishyu $count buhujwe ntibukiri',
      one: 'Ubwishyu 1 buhujwe ntibukiri',
    );
    return '$_temp0 mu mateka yawe.';
  }

  @override
  String get loginSuccess => 'Winjiye neza!';

  @override
  String get errUserNotFound =>
      'Nta konti ibonetse kuri iyo imeyili. Banza wiyandikishe.';

  @override
  String get errWrongPassword =>
      'Ijambo ry\'ibanga si ryo. Risuzume wongere ugerageze.';

  @override
  String get errInvalidCredential =>
      'Imeyili cyangwa ijambo ry\'ibanga si byo. Bisuzume.';

  @override
  String get errInvalidEmailEnter => 'Imeyili si yo. Andika imeyili nyayo.';

  @override
  String get errUserDisabled => 'Iyi konti yahagaritswe. Vugana n\'ubufasha.';

  @override
  String get errTooManyFailed =>
      'Wagerageje inshuro nyinshi. Tegereza iminota mike wongere ugerageze.';

  @override
  String get errNetworkInternet =>
      'Ikibazo cya interineti. Suzuma ko ufite interineti.';

  @override
  String get errLoginDisabled =>
      'Kwinjira byahagaritswe by\'agateganyo. Vugana n\'ubufasha.';

  @override
  String get errReLogin => 'Sohoka wongere winjire kugira ngo ukomeze.';

  @override
  String errLoginFailedCode(String code) {
    return 'Kwinjira byanze: $code. Suzuma imeyili n\'ijambo ry\'ibanga.';
  }

  @override
  String get loginFailedRetry => 'Kwinjira byanze. Ongera ugerageze.';

  @override
  String get welcomeBack => 'Murakaza neza nanone';

  @override
  String get signInSubtitle => 'Injira ukomeze gukurikirana amafaranga yawe';

  @override
  String get email => 'Imeyili';

  @override
  String get enterEmail => 'Andika imeyili yawe';

  @override
  String get enterValidEmail => 'Andika imeyili nyayo';

  @override
  String get password => 'Ijambo ry\'ibanga';

  @override
  String get enterPassword => 'Andika ijambo ry\'ibanga';

  @override
  String get passwordMin6 =>
      'Ijambo ry\'ibanga rigomba kugira nibura inyuguti 6';

  @override
  String get forgotPassword => 'Wibagiwe ijambo ry\'ibanga?';

  @override
  String get signIn => 'Injira';

  @override
  String get newToFinwise => 'Uri mushya kuri FinWise?';

  @override
  String get createAnAccount => 'Fungura konti';

  @override
  String get agreeTermsRequired => 'Banza wemere amategeko n\'amabwiriza';

  @override
  String get accountCreated => 'Konti yafunguwe neza!';

  @override
  String get errEmailInUse =>
      'Iyo imeyili isanzwe yanditswe. Gerageza kwinjira.';

  @override
  String get errInvalidEmailCheck =>
      'Imeyili si yo. Isuzume wongere ugerageze.';

  @override
  String get errWeakPassword =>
      'Ijambo ry\'ibanga ntirikomeye. Koresha nibura inyuguti 6.';

  @override
  String get errSignupDisabled =>
      'Kwiyandikisha byahagaritswe by\'agateganyo. Vugana n\'ubufasha.';

  @override
  String get errNetworkConnection =>
      'Ikibazo cya interineti. Suzuma ko uhuye na interineti.';

  @override
  String get signupFailed => 'Kwiyandikisha byanze. Ongera ugerageze.';

  @override
  String get createYourAccount => 'Fungura konti yawe';

  @override
  String get signupSubtitle =>
      'Tangira gukurikirana amafaranga yawe mu minota mike';

  @override
  String get fullName => 'Amazina yose';

  @override
  String get enterName => 'Andika izina ryawe';

  @override
  String get enterAPassword => 'Andika ijambo ry\'ibanga';

  @override
  String get atLeast6 => 'Nibura inyuguti 6';

  @override
  String get confirmPassword => 'Emeza ijambo ry\'ibanga';

  @override
  String get pleaseConfirmPassword => 'Emeza ijambo ry\'ibanga ryawe';

  @override
  String get passwordsDontMatch => 'Amagambo y\'ibanga ntahura';

  @override
  String get iAgreeToThe => 'Nemera ';

  @override
  String get createAccount => 'Fungura konti';

  @override
  String get haveAccount => 'Usanzwe ufite konti?';

  @override
  String get errNoAccountEmail => 'Nta konti ibonetse kuri iyo imeyili.';

  @override
  String get errTooManyAttempts =>
      'Wagerageje inshuro nyinshi. Ongera ugerageze nyuma.';

  @override
  String get resetEmailFailed =>
      'Kohereza imeyili yo guhindura byanze. Ongera ugerageze.';

  @override
  String get checkYourEmail => 'Reba imeyili yawe';

  @override
  String get resetYourPassword => 'Hindura ijambo ry\'ibanga';

  @override
  String get resetLinkSent =>
      'Twakoherereje umurongo wo gushyiraho ijambo ry\'ibanga rishya';

  @override
  String get resetEnterEmail =>
      'Andika imeyili yawe tukoherereze amabwiriza yo kurihindura';

  @override
  String get sendResetLink => 'Ohereza umurongo';

  @override
  String get emailSent => 'Imeyili yoherejwe';

  @override
  String resetSentTo(String email) {
    return 'Twohereje amabwiriza kuri\n$email';
  }

  @override
  String get checkSpam =>
      'Ntuyibona? Reba muri spam cyangwa promotions. Imeyili ishobora gutinda iminota mike.';

  @override
  String get backToSignIn => 'Subira ku kwinjira';

  @override
  String get sendAgain => 'Yohereze nanone';

  @override
  String get freqDaily => 'Buri munsi';

  @override
  String get freqWeekly => 'Buri cyumweru';

  @override
  String get freqMonthly => 'Buri kwezi';

  @override
  String get freqYearly => 'Buri mwaka';

  @override
  String get freqIrregular => 'Bidahoraho';

  @override
  String get pinsDidNotMatch => 'PIN ntizihura. Ongera utangire.';

  @override
  String get tooManyWait => 'Wagerageje inshuro nyinshi. Tegereza gato.';

  @override
  String incorrectPinLeft(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Usigaje kugerageza inshuro $left',
      one: 'Usigaje kugerageza inshuro 1',
    );
    return 'PIN si yo. $_temp0 mbere yo gutegereza.';
  }

  @override
  String get incorrectPinRetry => 'PIN si yo. Ongera ugerageze.';

  @override
  String get createPin => 'Shyiraho PIN';

  @override
  String get confirmYourPin => 'Emeza PIN yawe';

  @override
  String get enterYourPin => 'Andika PIN yawe';

  @override
  String get confirmItsYou => 'Emeza ko ari wowe';

  @override
  String get pinUseToOpen => 'Uzayikoresha ufungura FinWise';

  @override
  String get pinSameAgain => 'Ongera wandike imibare 4 imwe';

  @override
  String get financesLocked => 'Amakuru y\'imari yawe arafunze';

  @override
  String get enterCurrentPin =>
      'Andika PIN yawe ikoreshwa ubu kugira ngo ukomeze';

  @override
  String tooManyTryIn(String time) {
    return 'Wagerageje inshuro nyinshi. Ongera ugerageze nyuma ya $time';
  }

  @override
  String get forgotPinQ => 'Wibagiwe PIN?';

  @override
  String get forgotYourPin => 'Wibagiwe PIN yawe?';

  @override
  String get forgotPinBody =>
      'Kugira ngo uyihindure, ongera winjire ukoresheje imeyili n\'ijambo ry\'ibanga.\n\nUrasohorwa kandi ifunga rya porogaramu rivanweho. Ibikorwa byawe n\'intego byawe birinzwe — bigaruka ukimara kwinjira.';

  @override
  String get signOutReset => 'Sohoka uhindure';

  @override
  String get welcomeTitle => 'Murakaza neza kuri FinWise';

  @override
  String get welcomeTagline =>
      'Inama z\'ubwenge ku mari, mu bihe bishya by\'ubukire';

  @override
  String get welcomeFeat1 => 'Inama z\'ubwenge ku ngengo y\'imari';

  @override
  String get welcomeFeat2 => 'Isesengura ry\'ibyo ukoresha ryikora';

  @override
  String get welcomeFeat3 => 'Gukurikirana intego bigufasha kudatandukira';

  @override
  String get getStarted => 'Tangira';

  @override
  String get setupProfile => 'Tegura umwirondoro';

  @override
  String get getToKnowYou => 'Reka tukumenye';

  @override
  String get personalizedGuidance =>
      'Ibi bidufasha kuguha inama z\'imari zikubereye';

  @override
  String get yourName => 'Izina ryawe';

  @override
  String get currencyAdapts => 'Aho uri hose — FinWise irakwiyumvamo';

  @override
  String monthlyIncomeCode(String code) {
    return 'Amafaranga winjiza ku kwezi ($code)';
  }

  @override
  String get approximateFine => 'Hafi y\'ukuri birahagije';

  @override
  String get enterIncome => 'Andika amafaranga winjiza';

  @override
  String get enterValidNumber => 'Andika umubare nyawo';

  @override
  String get incomeFrequency => 'Inshuro winjiza amafaranga';

  @override
  String get dontWorryUpdate =>
      'Humura! Ushobora kubihindura nyuma igihe icyo ari cyo cyose. Tuzaguha inama n\'iyo imibare yaba ari iyegereye.';

  @override
  String get continueBtn => 'Komeza';

  @override
  String get catFood => 'Ibiryo';

  @override
  String get catTransport => 'Ingendo';

  @override
  String get catEntertainment => 'Imyidagaduro';

  @override
  String get catUtilities => 'Fagitire (umuriro…)';

  @override
  String get catRent => 'Ubukode';

  @override
  String get catShopping => 'Guhaha';

  @override
  String get catVacation => 'Ikiruhuko';

  @override
  String get catClothes => 'Imyenda';

  @override
  String get catWater => 'Amazi';

  @override
  String get catShoes => 'Inkweto';

  @override
  String get catHealth => 'Ubuzima';

  @override
  String get catEducation => 'Uburezi';

  @override
  String get catFamily => 'Umuryango n\'ubufasha';

  @override
  String get catDebt => 'Amadeni n\'inguzanyo';

  @override
  String get catBusiness => 'Ubucuruzi';

  @override
  String get catGiving => 'Gutanga n\'itorero';

  @override
  String get catFees => 'Amahoro n\'imisoro';

  @override
  String get catPersonal => 'Kwiyitaho';

  @override
  String get catMedicine => 'Imiti';

  @override
  String get catAlcohol => 'Inzoga n\'ibinyobwa';

  @override
  String get catTobacco => 'Itabi';

  @override
  String get catIncome => 'Ayinjiye';

  @override
  String get catSavings => 'Kuzigama';

  @override
  String get catOther => 'Ibindi';

  @override
  String get reasonNecessity => 'Ibikenewe';

  @override
  String get reasonBusiness => 'Ubucuruzi';

  @override
  String get reasonEnjoyment => 'Kwishimisha';

  @override
  String get reasonEmergency => 'Ibitunguranye';

  @override
  String get curRwf => 'Ifaranga ry\'u Rwanda';

  @override
  String get curUsd => 'Idolari rya Amerika';

  @override
  String get curEur => 'Ewuro';

  @override
  String get curGbp => 'Ipawundi y\'Ubwongereza';

  @override
  String get curKes => 'Ishilingi rya Kenya';

  @override
  String get curUgx => 'Ishilingi rya Uganda';

  @override
  String get curTzs => 'Ishilingi rya Tanzaniya';

  @override
  String get curNgn => 'Nayira ya Nijeriya';

  @override
  String get curGhs => 'Sedi ya Gana';

  @override
  String get curZar => 'Randi ya Afurika y\'Epfo';

  @override
  String get curXaf => 'Ifaranga rya CFA (Afurika yo Hagati)';

  @override
  String get curCad => 'Idolari rya Kanada';

  @override
  String get curInr => 'Rupiya y\'Ubuhinde';

  @override
  String get giSavings => 'Kuzigama';

  @override
  String get giLaptop => 'Mudasobwa';

  @override
  String get giCar => 'Imodoka';

  @override
  String get giHouse => 'Inzu';

  @override
  String get giLand => 'Ikibanza';

  @override
  String get giEducation => 'Uburezi';

  @override
  String get giBusiness => 'Ubucuruzi';

  @override
  String get giTravel => 'Ingendo';

  @override
  String get giWedding => 'Ubukwe';

  @override
  String get giFamily => 'Umuryango';

  @override
  String get giHealth => 'Ubuzima';

  @override
  String get giEmergency => 'Ikigega cy\'ibitunguranye';

  @override
  String get giPhone => 'Telefoni';

  @override
  String get giFurniture => 'Ibikoresho byo mu nzu';

  @override
  String get giClothes => 'Imyenda';

  @override
  String get giGaming => 'Imikino';

  @override
  String get giDebt => 'Kwishyura amadeni';

  @override
  String get giGift => 'Impano';

  @override
  String get giOther => 'Ibindi';

  @override
  String get enterRealPrice => 'Andika igiciro nyacyo.';

  @override
  String haveEnoughExtra(String amount) {
    return 'Usanzwe ufite ahagije — witeguye kugura. $amount birenze ushobora kuyasubiza mu aboneka.';
  }

  @override
  String get haveExactlyEnough => 'Ufite ahagije neza — witeguye kugura.';

  @override
  String willStillNeed(String amount) {
    return 'Uzaba ugikeneye $amount.';
  }

  @override
  String realPriceIntro(String planned, String current) {
    return 'Wabonye igiciro nyacyo mu iduka cyangwa kuri interineti? Intego yawe izagikurikiza. Wateganyije: $planned$current.';
  }

  @override
  String currentPrice(String amount) {
    return ' · ubu: $amount';
  }

  @override
  String realPriceCode(String code) {
    return 'Igiciro nyacyo ($code)';
  }

  @override
  String priceUpdatedExtra(String amount) {
    return 'Igiciro cyahinduwe. Wabitse $amount birenze ibikenewe.';
  }

  @override
  String priceUpdatedTo(String amount) {
    return 'Igiciro cyahinduwe kiba $amount.';
  }

  @override
  String get releaseExtra => 'Garura ayarenze';

  @override
  String get noteDown => 'Igiciro cyagabanutse';

  @override
  String get update => 'Hindura';

  @override
  String get releaseReserved => 'Garura amafaranga wabitse';

  @override
  String releaseExplain(String amount) {
    return 'Isubiza amafaranga y\'iyi ntego mu yo ushobora gukoresha. Abitswe ubu: $amount';
  }

  @override
  String amountToRelease(String code) {
    return 'Amafaranga ugarura ($code)';
  }

  @override
  String get noteReleasedAll => 'Byose byagaruwe';

  @override
  String get releaseAll => 'Garura byose';

  @override
  String releasedBack(String amount) {
    return 'Wagaruye $amount mu aboneka';
  }

  @override
  String get markAsBought => 'Emeza ko waguze';

  @override
  String get alreadyRecorded => 'Waba waramaze kwandika uku kugura?';

  @override
  String get linkExisting => 'Huza ibihari';

  @override
  String get createNew => 'Kora gishya';

  @override
  String get tickPayments => 'Hitamo ubwishyu bw\'uku kugura';

  @override
  String get amountEveryPayment => 'Andika amafaranga kuri buri bwishyu';

  @override
  String get moreThanHolds => 'Birenze ibiri kuri konti';

  @override
  String accountShows(String account, String amount) {
    return '$account ifite $amount';
  }

  @override
  String get recordNegative =>
      'Kubyandika bizatuma konti ijya munsi ya zeru. Niba koko waraguze, byandike — ushobora kuba ukeneye kongeramo amafaranga winjije utanditse.';

  @override
  String get goBack => 'Subira inyuma';

  @override
  String get recordAnyway => 'Andika uko byakabaye kose';

  @override
  String boughtDesc(String goal) {
    return 'Byaguzwe: $goal';
  }

  @override
  String get noExpensesToLink =>
      'Nta byakoreshejwe biri mu mateka byo guhuza. Hitamo \"Kora gishya\".';

  @override
  String get tickEveryPayment =>
      'Hitamo ubwishyu bwose bw\'iki kintu — wishyuye igice kuri Mobile Money n\'ikindi mu ntoki? Hitamo byombi. Nta gishya kizakorwa.';

  @override
  String get searchNameAmount => 'Shakisha ukoresheje izina cyangwa amafaranga';

  @override
  String get matchesPrice => '  ·  bihuye n\'igiciro';

  @override
  String get recordWhatPaid =>
      'Andika ibyo wishyuye. Wishyuye ukoresheje konti zirenze imwe? Ongeraho ubwishyu kuri buri imwe.';

  @override
  String get paidFrom => 'Byishyuwe na';

  @override
  String get amount => 'Amafaranga';

  @override
  String get addAnotherPayment => 'Ongeraho ubundi bwishyu';

  @override
  String get expenseCategory => 'Icyiciro cy\'ibyakoreshejwe';

  @override
  String get nothingSelected => 'Nta kintu urahitamo.';

  @override
  String underYourPrice(String amount) {
    return '$amount munsi y\'igiciro cyawe 🎉';
  }

  @override
  String overYourPrice(String amount) {
    return '$amount hejuru y\'igiciro cyawe';
  }

  @override
  String get exactlyYourPrice => 'Ni igiciro cyawe neza';

  @override
  String totalPaidPrice(String total, String price) {
    return 'Wishyuye: $total  ·  igiciro $price';
  }

  @override
  String completedAt(String amount) {
    return 'Intego izagerwaho kuri $amount.';
  }

  @override
  String goalCompletedAt(String amount) {
    return 'Intego yagezweho kuri $amount.';
  }

  @override
  String returnedToAvailable(String amount) {
    return '$amount yasubiye mu aboneka.';
  }

  @override
  String underPlanParty(String amount) {
    return '$amount munsi y\'igenamigambi 🎉';
  }

  @override
  String undoCreatedDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ibyakoreshejwe $count FinWise yanditse',
      one: 'Ibyakoreshejwe FinWise yanditse',
    );
    return '$_temp0 kuri uku kugura bizasibwa.';
  }

  @override
  String undoLinkedStay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ubwishyu $count buhujwe buguma',
      one: 'Ubwishyu buhujwe buguma',
    );
    return '$_temp0 mu mateka yawe — butandukanywa gusa.';
  }

  @override
  String willBeReservedAgain(String amount) {
    return '$amount yawe izongera ibikwe.';
  }

  @override
  String reopenGoal(String goal) {
    return 'Ongera ufungure \"$goal\"?';
  }

  @override
  String get undoneCreatedRemoved =>
      'Kugura kwahagaritswe kandi ibyari byanditswe byasibwe.';

  @override
  String get undoneKept =>
      'Kugura kwahagaritswe. Ubwishyu bwawe bwagumye mu mateka.';

  @override
  String get undo => 'Hagarika';

  @override
  String deleteGoalReserved(String goal, String amount) {
    return 'Gusiba \"$goal\"? $amount wabitse azasubira mu mafaranga yawe aboneka.';
  }

  @override
  String deleteGoalNoUndo(String goal) {
    return 'Gusiba \"$goal\"? Ntibishobora gusubizwaho.';
  }

  @override
  String get noteGoalDeleted => 'Intego yasibwe';

  @override
  String returnedToBalance(String amount) {
    return '$amount yasubiye mu mafaranga yawe aboneka';
  }

  @override
  String versionBuild(String version, String build) {
    return '$version (Verisiyo $build)';
  }

  @override
  String get clearTransactionsConfirm =>
      'Urizera ko ushaka gusiba ibikorwa byose? Ntibishobora gusubizwaho.';

  @override
  String get transactionsCleared => 'Ibikorwa byose byasibwe';

  @override
  String get incomeTargetExplain =>
      'Ni intego yo gutegura gusa — ikoreshwa mu kubara igipimo cyo kuzigama. Ntiyongerwa ku mafaranga ufite.';

  @override
  String get howOften => 'Inshuro';

  @override
  String get clear => 'Kuraho';

  @override
  String get noTxToExport => 'Nta bikorwa byo kohereza';

  @override
  String exportedAs(String format) {
    return 'Ibikorwa byoherejwe neza nka $format';
  }

  @override
  String exportFailed(String error) {
    return 'Kohereza byanze: $error';
  }

  @override
  String get clearGoalsConfirm =>
      'Urizera ko ushaka gusiba intego zose? Ntibishobora gusubizwaho.';

  @override
  String get goalsCleared => 'Intego zose zasibwe';

  @override
  String get deleteAccountQ => 'Gusiba konti yawe?';

  @override
  String get deleteAccountBody =>
      'Ibi bisiba burundu:\n\n• Ibikorwa byawe byose\n• Intego zawe zose n\'amafaranga wabitse\n• Umwirondoro n\'igenamiterere byawe\n• Konti ukoresha winjira\n\nNtibishobora gusubizwaho. Banza wohereze amakuru yawe (Gucunga amakuru → Kohereza).';

  @override
  String enterSignInPassword(String email) {
    return 'Andika ijambo ry\'ibanga ukoresha winjira muri FinWise$email.';
  }

  @override
  String get notAppLockPin => 'Iyi si PIN ifunga porogaramu.';

  @override
  String get signInPassword => 'Ijambo ry\'ibanga ryo kwinjira';

  @override
  String get accountDeleted => 'Konti yawe yasibwe';

  @override
  String get deleteForever => 'Siba burundu';

  @override
  String get logoutConfirm =>
      'Urizera ko ushaka gusohoka? Uzongera winjire kugira ngo ukoreshe porogaramu.';

  @override
  String get loggedOut => 'Wasohotse neza';

  @override
  String get addGoal => 'Ongeraho intego';

  @override
  String get editGoalTitle => 'Hindura intego';

  @override
  String get selectIcon => 'Hitamo ishusho';

  @override
  String get goalName => 'Izina ry\'intego';

  @override
  String get enterGoalName => 'Andika izina ry\'intego';

  @override
  String targetAmountCode(String code) {
    return 'Amafaranga y\'intego ($code)';
  }

  @override
  String get enterTargetAmount => 'Andika amafaranga y\'intego';

  @override
  String get enterValidNumberShort => 'Andika umubare nyawo';

  @override
  String get targetDate => 'Itariki y\'intego';

  @override
  String get add => 'Ongeraho';

  @override
  String get changeCurrencyQ => 'Guhindura ifaranga?';

  @override
  String changeCurrencyBody(String from, String to) {
    return 'Ibikorwa byawe bisanzwe NTIBIZAHINDURWA.\n\nAmafaranga yanditswe ari 500 $from azagaragara ari 500 $to — umubare uguma uko wari uri, hahinduka izina ry\'ifaranga gusa.\n\nHindura ifaranga gusa niba ayo mafaranga wayanditse muri $to, cyangwa niba uteganya gusiba amakuru yawe.';
  }

  @override
  String changeTo(String code) {
    return 'Hindura ube $code';
  }

  @override
  String get chooseCurrency => 'Hitamo ifaranga ryawe';

  @override
  String get appLock => 'Ifunga rya porogaramu';

  @override
  String get appLockOnSub => 'FinWise isaba PIN yawe iyo uyifunguye';

  @override
  String get appLockOffSub => 'Saba PIN kugira ngo ufungure FinWise';

  @override
  String get unlockFingerprint => 'Fungura ukoresheje igikumwe';

  @override
  String get fingerprintSub =>
      'Koresha igikumwe cyangwa isura aho gukoresha PIN';

  @override
  String get noFingerprint =>
      'Iyi telefoni nta gikumwe cyangwa isura byashyizweho';

  @override
  String get lockAfter => 'Funga nyuma ya';

  @override
  String get lockImmediately => 'Ako kanya iyo uvuye muri porogaramu';

  @override
  String lockAfterMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'y\'iminota $minutes',
      one: 'y\'umunota 1',
    );
    return 'Nyuma $_temp0 utariho';
  }

  @override
  String get instant => 'Ako kanya';

  @override
  String minShort(int n) {
    return 'Imin $n';
  }

  @override
  String get changePin => 'Hindura PIN';

  @override
  String get changePinSub => 'Shyiraho PIN nshya y\'imibare 4';

  @override
  String get lockNow => 'Funga ubu';

  @override
  String get lockNowSub => 'Saba PIN ako kanya';

  @override
  String get useFingerprintQ => 'Gukoresha igikumwe?';

  @override
  String get useFingerprintBody =>
      'Fungura FinWise ukoresheje igikumwe cyangwa isura aho kwandika PIN buri gihe. PIN yawe iracyakora nk\'inyunganizi.';

  @override
  String get notNow => 'Si ubu';

  @override
  String get enable => 'Emera';

  @override
  String get appLockOn => 'Ifunga rya porogaramu rirakora';

  @override
  String get turnOffLock => 'Zimya ifunga rya porogaramu';

  @override
  String get lockTurnedOff => 'Ifunga rya porogaramu ryazimijwe';

  @override
  String get enterCurrentPinTitle => 'Andika PIN usanzwe ukoresha';

  @override
  String get setNewPin => 'Shyiraho PIN nshya';

  @override
  String get pinUpdated => 'PIN yahinduwe';

  @override
  String get protectFinances => 'Rinda amakuru y\'imari yawe';

  @override
  String get protectBody =>
      'Shyiraho PIN kugira ngo ari wowe wenyine ufungura FinWise. Kwinjira bituma uguma winjiye, bityo nta funga, uwafata telefoni yawe yabona amafaranga yawe n\'ibikorwa byawe.';

  @override
  String get setUpPin => 'Shyiraho PIN';

  @override
  String get nameThisPhone => 'Ita izina iyi telefoni';

  @override
  String get nameThisPhoneBody =>
      'Ibikorwa byanditswe kuri iyi telefoni bishyirwaho iri zina, kugira ngo ubitandukanye n\'ibyanditswe ku zindi telefoni zawe.';

  @override
  String get deviceName => 'Izina rya telefoni';

  @override
  String get thisPhone => 'Iyi telefoni';

  @override
  String get namingDevice => 'Turimo kwita izina iyi telefoni…';

  @override
  String shownOnTx(String name) {
    return '$name — rigaragara ku bikorwa byanditswe hano';
  }

  @override
  String get needHelp => 'Ukeneye ubufasha?';

  @override
  String get needHelpBody =>
      'Ibibazo byinshi bifite ibisubizo mu Bibazo bikunze kubazwa. Niba atari ko bimeze, twandikire tuzagusubiza.';

  @override
  String get browseFaq => 'Reba ibibazo bikunze kubazwa';

  @override
  String get browseFaqSub =>
      'Ibisubizo by\'ibibazo bikunze kubazwa kuri FinWise';

  @override
  String get emailUs => 'Twandikire kuri imeyili';

  @override
  String get noEmailApp => 'Ntibyashobotse gufungura porogaramu ya imeyili';

  @override
  String get whatsappUs => 'Twandikire kuri WhatsApp';

  @override
  String get whatsappSub => 'Muganire natwe kuri WhatsApp';

  @override
  String get whatsappPreview => 'Incamake ya WhatsApp';

  @override
  String get finwiseSupport => 'Ubufasha bwa FinWise';

  @override
  String get whatsappGreeting =>
      'Muraho! Ufite ikibazo kuri FinWise, cyangwa ukeneye ubufasha? Twoherereze ubutumwa tuzagusubiza vuba bishoboka.';

  @override
  String get noWhatsapp => 'Ntibyashobotse gufungura WhatsApp';

  @override
  String get openChat => 'Fungura ikiganiro';

  @override
  String get smsBlocked => 'Uruhushya rwa SMS rwafunzwe';

  @override
  String get smsBlockedBody =>
      'Android yahagaritse kubaza kuko uruhushya rwanzwe mbere. Kugira ngo ufungure kumenya ubwabyo, emerera FinWise SMS mu igenamiterere rya telefoni:\n\nUruhushya → SMS → Emera';

  @override
  String get openSettings => 'Fungura igenamiterere';

  @override
  String get smsNotGrantedOff =>
      'Uruhushya rwa SMS ntirwatanzwe, bityo kumenya ubwabyo bikomeza kuzima.';

  @override
  String get smsNotGranted => 'Uruhushya rwa SMS ntirwatanzwe';

  @override
  String get smsBlockedSwitch =>
      'Android yafunze uru ruhushya kuko rwanzwe mbere, bityo buto iri hejuru ntiyarufungura. Emerera FinWise SMS mu igenamiterere rya telefoni, hanyuma ugaruke.';

  @override
  String get smsNeedsPermission =>
      'Kumenya ubwabyo bikeneye uruhushya rwo gusoma ubutumwa bwa Mobile Money. Fungura buto kugira ngo urutange.';

  @override
  String get openPhoneSettings => 'Fungura igenamiterere rya telefoni';

  @override
  String get autoDetectStopped => 'Kumenya ubwabyo byahagaze gukora';

  @override
  String get autoDetectStoppedBody =>
      'Ubutumwa ntibumaze umunsi busuzumwa. Zimya buto wongere uyifungure kugira ngo wongere utange uruhushya rwa SMS, kandi urebe ko FinWise idakumirwa na batiri.';

  @override
  String get fixBattery => 'Kosora igenamiterere rya batiri';

  @override
  String get nothingDetected => 'Nta kintu kimaze igihe kimenyekana';

  @override
  String lastDetectedCheck(String ago) {
    return 'Igikorwa giheruka cyamenyekanye $ago. Niba warakoresheje Mobile Money kuva icyo gihe, reba ko FinWise igifite uruhushya rwa SMS kandi idakumirwa na batiri.';
  }

  @override
  String lastDetected(String ago) {
    return 'Igikorwa giheruka cyamenyekanye $ago.';
  }

  @override
  String get watchingNothingYet =>
      'Turimo gukurikirana ubutumwa bwa Mobile Money. Nta kintu kiramenyekana.';

  @override
  String get waitingFirst => 'Dutegereje ubutumwa bwa mbere bwa Mobile Money.';

  @override
  String get autoDetectWorking => 'Kumenya ubwabyo birakora';

  @override
  String get improveBackground => 'Noza kumenya ubwabyo inyuma';

  @override
  String get improveBackgroundBody =>
      'Android ishobora gutinza kumenya kugira ngo izigame batiri. Shyira FinWise kuri \"Unrestricted\" kugira ngo ubutumwa bumenyekane vuba.';

  @override
  String minAgo(int n) {
    return 'hashize iminota $n';
  }

  @override
  String hoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'amasaha $n',
      one: 'isaha 1',
    );
    return 'hashize $_temp0';
  }

  @override
  String daysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'iminsi $n',
      one: 'umunsi 1',
    );
    return 'hashize $_temp0';
  }

  @override
  String get autoDetectTitle => 'Menya ubwabyo ibikorwa bya Mobile Money';

  @override
  String get autoDetectSub =>
      'Isoma SMS za MoMo na banki kuri iyi telefoni ikandika ibikorwa ubwayo. Ibikubiye mu butumwa ntibiva kuri telefoni yawe. Ubutumwa buhoraho bugaragara igihe ibi bifunguye, kugira ngo Android ikomeze kumenya n\'iyo uri muri indi porogaramu.';

  @override
  String get selectCategory => 'Hitamo icyiciro';

  @override
  String get transactionWord => 'Igikorwa';

  @override
  String categoryAdded(String name) {
    return 'Icyiciro \"$name\" cyongeweho';
  }

  @override
  String get addTransaction => 'Ongeraho igikorwa';

  @override
  String get editTransaction => 'Hindura igikorwa';

  @override
  String recordedThisPhone(String name) {
    return 'Cyanditswe kuri iyi telefoni ($name)';
  }

  @override
  String recordedOtherPhone(String name) {
    return 'Cyanditswe ku yindi telefoni ($name)';
  }

  @override
  String get originalMessage => 'Ubutumwa bw\'umwimerere';

  @override
  String get account => 'Konti';

  @override
  String get enterAmount => 'Andika amafaranga';

  @override
  String get category => 'Icyiciro';

  @override
  String categoriesCount(int count) {
    return 'Ibyiciro $count';
  }

  @override
  String get addCustomCategory => 'Ongeraho icyiciro cyawe';

  @override
  String get enterCategoryName => 'Andika izina ry\'icyiciro...';

  @override
  String get yourCustomCategories => 'Ibyiciro byawe:';

  @override
  String get customCategoriesNote =>
      'FinWise izabishyira mu cyiciro nyamukuru kibyegereye kugira ngo ingengo y\'imari yawe yoroshye.';

  @override
  String get whySpending => 'Kuki ukoresha aya mafaranga?';

  @override
  String get descriptionOptional => 'Ibisobanuro (bitari ngombwa)';

  @override
  String get deleteTransaction => 'Siba igikorwa';

  @override
  String get deleteTransactionQ => 'Urizera ko ushaka gusiba iki gikorwa?';

  @override
  String get autoDetectedTip =>
      'Cyamenyekanye ubwacyo muri SMS ya Mobile Money — kanda ugisuzume';

  @override
  String get autoBadge => 'Ubwacyo';

  @override
  String todayAt(String time) {
    return 'Uyu munsi, $time';
  }

  @override
  String get recentTransactions => 'Ibikorwa biheruka';

  @override
  String get viewAll => 'Reba byose →';

  @override
  String get transactionDeleted => 'Igikorwa cyasibwe';

  @override
  String get hello => 'Muraho';

  @override
  String get manageWisely => 'Reka ducunge amafaranga yawe neza';

  @override
  String get expenses => 'Ayasohotse';

  @override
  String get startTracking => 'Tangira gukurikirana imari yawe';

  @override
  String get tapPlusFirst => 'Kanda kuri + wandike igikorwa cyawe cya mbere';

  @override
  String get totalAmount => 'Yose';

  @override
  String get available => 'Aboneka';

  @override
  String get accountsOverview => 'Incamake ya konti';

  @override
  String get balanceReservedAvailable => 'Ayo ufite · wabitse · aboneka';

  @override
  String get momoShort => 'MoMo';

  @override
  String shortBy(String amount) {
    return 'habura $amount';
  }

  @override
  String get totalBalance => 'Amafaranga yose';

  @override
  String get addIncome => 'Ongeraho ayinjiye';

  @override
  String get addExpense => 'Ongeraho ayasohotse';

  @override
  String get goodMorning => 'Mwaramutse';

  @override
  String get goodAfternoon => 'Mwiriwe';

  @override
  String get goodEvening => 'Muraho';

  @override
  String get userFallback => 'Mukoresha';

  @override
  String get healthExcellent => 'Byiza cyane';

  @override
  String get healthGood => 'Byiza';

  @override
  String get healthFair => 'Biringaniye';

  @override
  String get healthNeedsImprovement => 'Bikeneye kunozwa';

  @override
  String get healthCritical => 'Biteye impungenge';

  @override
  String get adviceExcellent => 'Komereza aho! Ucunga imari yawe neza cyane.';

  @override
  String get adviceGood =>
      'Uri gukora neza! Tekereza kongera igipimo cyo kuzigama.';

  @override
  String get adviceFair =>
      'Gerageza kugabanya ibyo ukoresha no gushyiraho intego z\'imari.';

  @override
  String get adviceNeeds =>
      'Shyira imbaraga mu gukoresha bike kurusha ibyo winjiza kandi ukore ingengo y\'imari.';

  @override
  String get adviceCritical =>
      'Tangira wandika ibyo ukoresha byose kandi ukore gahunda yo kuzigama.';

  @override
  String get financialHealth => 'Ubuzima bw\'imari';

  @override
  String profileIncomeUsed(String amount) {
    return 'Hakoreshejwe amafaranga winjiza yanditswe: $amount ku kwezi';
  }

  @override
  String get notAvailable => 'Ntibihari';

  @override
  String get srGood => 'Byiza! 👍';

  @override
  String get srOverspending => 'Ukoresha arenze ayo winjiza';

  @override
  String get savingsRateTitle => 'Igipimo cyo kuzigama';

  @override
  String get usingProfileIncome =>
      'Hakoreshejwe amafaranga winjiza wanditse utangira, kuko nta mafaranga yinjiye arandikwa.';

  @override
  String get basedOnTracked =>
      'Bishingiye ku mafaranga yinjiye n\'ayasohotse wanditse.';

  @override
  String get saved => 'Wazigamye';

  @override
  String get thisMonthLower => 'Uku kwezi';

  @override
  String get smartTip => 'INAMA Y\'UBWENGE';

  @override
  String get notEnoughCashFlow =>
      'Nta makuru ahagije arahari yo kwerekana amafaranga yinjira n\'asohoka';

  @override
  String get moneyInVsOut => 'Ayinjiye n\'ayasohotse';

  @override
  String get inShort => 'Ayinjiye';

  @override
  String get outShort => 'Ayasohotse';

  @override
  String monthKept(String amount) {
    return 'Uku kwezi wasigaranye $amount';
  }

  @override
  String monthOverspent(String amount) {
    return 'Uku kwezi wakoresheje $amount birenze ibyo winjije';
  }

  @override
  String get noSpending4Weeks =>
      'Nta byakoreshejwe byanditswe mu byumweru 4 bishize';

  @override
  String get spendingTrend => 'Uko ukoresha · Ibyumweru 4 bishize';

  @override
  String weekSpentMore(String pct) {
    return 'Iki cyumweru wakoresheje $pct% birenze icyumweru gishize';
  }

  @override
  String weekSpentLess(String pct) {
    return 'Iki cyumweru wakoresheje $pct% munsi y\'icyumweru gishize';
  }

  @override
  String averagePerWeek(String amount) {
    return 'Impuzandengo $amount ku cyumweru';
  }

  @override
  String get whyYouSpend => 'Impamvu ukoresha';

  @override
  String get tagReasonsHint =>
      'Shyira impamvu ku byo ukoresha (ibikenewe, kwishimisha, ubucuruzi cyangwa ibitunguranye) urebe igice cy\'amafaranga yawe kijya ku by\'ingenzi.';

  @override
  String get whyYouSpentMonth => 'Impamvu wakoresheje · Uku kwezi';

  @override
  String necessityShare(String pct) {
    return '$pct% by\'ibyo wakoresheje byari ibikenewe';
  }

  @override
  String notTagged(String amount) {
    return '$amount nta mpamvu yashyizweho';
  }

  @override
  String get spendingByCategoryMonth => 'Ibyakoreshejwe ku byiciro · Uku kwezi';

  @override
  String get noSpendingMonth => 'Nta byakoreshejwe birandikwa uku kwezi.';

  @override
  String get topCategories => 'Ibyiciro ukoreshamo menshi';

  @override
  String get thisMonthTitle => 'Uku kwezi';

  @override
  String pctOfTotal(String pct) {
    return '$pct% by\'ibyakoreshejwe byose';
  }

  @override
  String get noSpendingData => 'Nta makuru y\'ibyakoreshejwe yo kwerekana';

  @override
  String get spendingByCategory => 'Ibyakoreshejwe ku byiciro';

  @override
  String get categoriesTitle => 'Ibyiciro';

  @override
  String get spendingCategories => 'Ibyiciro by\'ibyakoreshejwe';

  @override
  String get categoriesIntro =>
      'FinWise ishyira ibyo ukoresha mu byiciro byoroshye kugira ngo ubone vuba aho amafaranga yawe ajya.';

  @override
  String get budgetsIntro =>
      'Ingengo y\'imari hano ikoresha amafaranga winjiza wanditse utangira hamwe n\'ibyo ukoresha koko.';

  @override
  String get categoryInsight => 'Inama ku byiciro';

  @override
  String get calMonth => 'Ukwezi';

  @override
  String get calTwoWeeks => 'Ibyumweru 2';

  @override
  String get calWeek => 'Icyumweru';

  @override
  String txCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ibikorwa $count',
      one: 'Igikorwa 1',
    );
    return '$_temp0';
  }

  @override
  String get noTxThisDay => 'Nta bikorwa kuri uyu munsi';

  @override
  String get addForThisDate =>
      'Ongeraho amafaranga yinjiye cyangwa yasohotse kuri iyi tariki kugira ngo ubibone hano.';

  @override
  String get transferBetweenAccounts => 'Ihererekanya hagati ya konti zawe';

  @override
  String get transferFee => 'Amafaranga y\'ihererekanya';

  @override
  String transferConfirmation(String details) {
    return 'Kwemeza ihererekanya: $details';
  }

  @override
  String get errGoalNotFound => 'Intego ntiyabonetse';

  @override
  String get errOverRelease =>
      'Byagarura arenze ayabitswe. Banza usibe cyangwa ugabanye ibyagaruwe.';

  @override
  String get errOverReleaseAccount =>
      'Byagarura kuri konti arenze ayayibitsweho.';

  @override
  String get insightStart =>
      'Tangira wandika ibyo ukoresha kugira ngo ubone inama zikubereye!';

  @override
  String insightHighCategory(
      String pct, String category, String amount, String symbol) {
    return 'Ukoresha $pct% ku $category. Tekereza kugabanya $amount $symbol kugira ngo wongere igipimo cyo kuzigama.';
  }

  @override
  String insightLowSavings(String pct) {
    return 'Igipimo cyawe cyo kuzigama ni $pct%. Gerageza kuzigama nibura 20% by\'ayo winjiza kugira ngo imari yawe imere neza.';
  }

  @override
  String get insightGreat =>
      'Wakoze neza! Ucunga imari yawe neza. Komeza wandike kugira ngo ugumane ingeso nziza!';

  @override
  String get delNotSignedIn => 'Ntabwo winjiye.';

  @override
  String get delNoEmail =>
      'Iyi konti ntikoresha imeyili mu kwinjira, bityo ntishobora kwemezwa gutya. Vugana n\'ubufasha.';

  @override
  String get delWrongPassword =>
      'Ijambo ry\'ibanga si ryo. Koresha ijambo ry\'ibanga winjiza muri FinWise (si PIN ifunga porogaramu).';

  @override
  String get delOtherAccount => 'Iryo jambo ry\'ibanga ni irya indi konti.';

  @override
  String get delTooMany =>
      'Wagerageje inshuro nyinshi. Tegereza iminota mike wongere ugerageze.';

  @override
  String get delNetwork =>
      'Ikibazo cya interineti. Suzuma ko uhuye na interineti wongere ugerageze.';

  @override
  String get delReLogin =>
      'Sohoka, wongere winjire, hanyuma wongere ugerageze gusiba.';

  @override
  String delVerifyFailedCode(String code) {
    return 'Kwemeza byanze ($code). Ongera ugerageze.';
  }

  @override
  String get delVerifyFailed =>
      'Ntibyashobotse kwemeza ijambo ry\'ibanga. Ongera ugerageze.';

  @override
  String get delDataFailed =>
      'Ntibyashobotse gusiba amakuru yawe. Ongera ugerageze.';

  @override
  String get delAccountFailed =>
      'Ntibyashobotse gusiba konti yawe. Ongera ugerageze.';

  @override
  String get notifChannelName => 'Imenyesha ry\'ibikorwa';

  @override
  String get notifChannelDesc =>
      'Ikumenyesha iyo igikorwa cya Mobile Money cyanditswe ubwacyo.';

  @override
  String get notifMoneyReceived => 'Wakiriye amafaranga';

  @override
  String get notifMoneySent => 'Wohereje amafaranga';

  @override
  String get notifSmsNotRead => 'SMS ya MoMo ntiyasomwe';

  @override
  String get notifSmsNotReadBody =>
      'Byasaga n\'igikorwa ariko amafaranga cyangwa imiterere ntibyamenyekanye.';

  @override
  String get notifNotSaved => 'Igikorwa ntikyabitswe';

  @override
  String notifNotSavedBody(String description) {
    return 'Ntibyashobotse kwandika \"$description\". Cyandike ubwawe.';
  }

  @override
  String get monitorChannelName => 'Gukurikirana Mobile Money';

  @override
  String get monitorChannelDesc =>
      'Bigaragara igihe FinWise ikurikirana SMS za Mobile Money kugira ngo yandike ibikorwa byawe ubwayo.';

  @override
  String get monitorTitle => 'FinWise irimo gukurikirana ibikorwa';

  @override
  String get monitorText =>
      'Kumenya SMS za Mobile Money ubwabyo birakora. Kanda ufungure FinWise.';

  @override
  String csvHeader(String code) {
    return 'Itariki,Ubwoko,Icyiciro,Ibisobanuro,Amafaranga ($code)';
  }

  @override
  String get exportSubject => 'Ibikorwa bya FinWise byoherejwe';

  @override
  String get exportText => 'Ibikorwa byawe bya FinWise byoherejwe';

  @override
  String get reportTitle => 'RAPORO Y\'IBIKORWA BYA FINWISE';

  @override
  String reportGenerated(String date) {
    return 'Yakozwe: $date';
  }

  @override
  String get reportSummary => 'INCAMAKE';

  @override
  String reportTotalIncome(String amount) {
    return 'Ayinjiye yose: $amount';
  }

  @override
  String reportTotalExpenses(String amount) {
    return 'Ayasohotse yose: $amount';
  }

  @override
  String reportBalance(String amount) {
    return 'Asigaye: $amount';
  }

  @override
  String get reportTransactions => 'IBIKORWA';

  @override
  String reportDate(String value) {
    return 'Itariki: $value';
  }

  @override
  String reportType(String value) {
    return 'Ubwoko: $value';
  }

  @override
  String reportCategory(String value) {
    return 'Icyiciro: $value';
  }

  @override
  String reportDescription(String value) {
    return 'Ibisobanuro: $value';
  }

  @override
  String reportAmount(String value) {
    return 'Amafaranga: $value';
  }

  @override
  String get reportSubject => 'Raporo y\'ibikorwa bya FinWise';

  @override
  String get reportText => 'Raporo y\'ibikorwa byawe bya FinWise';

  @override
  String get styleSaver => 'Uzigama';

  @override
  String get styleBalanced => 'Uringaniza';

  @override
  String get styleSpender => 'Ukoresha cyane';

  @override
  String get styleOverspender => 'Ukoresha birenze';

  @override
  String get catElectricity => 'Umuriro';

  @override
  String get setUpFinwise => 'Tegura FinWise';

  @override
  String get back => 'Subira inyuma';

  @override
  String get letsSetUp => 'Reka dutegure FinWise yawe';

  @override
  String get tellUsAboutYou =>
      'Tubwire bike kuri wowe. Ushobora kubihindura igihe icyo ari cyo cyose.';

  @override
  String get whyWeNeed => 'Impamvu tubikeneye:';

  @override
  String get whyWeNeedBullets =>
      '• Izina ryawe rituma ahabanza hakubera\n• Ifaranga ryawe rikoreshwa muri porogaramu yose\n• Ushobora kongeraho intego y\'amafaranga winjiza nyuma mu Igenamiterere (bitari ngombwa)';

  @override
  String get selectCurrency => 'Hitamo ifaranga';

  @override
  String get allWeNeed =>
      'Ibyo ni byo dukeneye byose kugira ngo dutangire. Ushobora gushyiraho intego y\'amafaranga winjiza n\'ibindi mu Igenamiterere igihe icyo ari cyo cyose.';

  @override
  String get whatsYourStyle => 'Ukoresha amafaranga ute?';

  @override
  String get chooseStyle =>
      'Hitamo igukwiriye. Ibi bifasha FinWise kuguha ingengo y\'imari ishoboka.';

  @override
  String get howThisHelps => 'Uko bifasha:';

  @override
  String get howThisHelpsBullets =>
      '• Uko ukoresha: bifasha FinWise kuguha inama z\'ingengo y\'imari zikubereye\n• Ibyo ukoresha koko: dukoresha gusa ibikorwa byawe nyabyo mu kubara imbonerahamwe n\'ingengo y\'imari';

  @override
  String get styleSaverSub => 'Nzigama cyane';

  @override
  String get styleBalancedSub => 'Ndaringaniza';

  @override
  String get styleSpenderSub => 'Nkoresha menshi mu yo ninjiza';

  @override
  String get styleOverspenderSub => 'Kenshi nkoresha birenze';

  @override
  String get trackRealSpending =>
      'FinWise izakurikirana ibyo ukoresha koko ubwayo ikoresheje ibikorwa wongeraho ku ahabanza.';

  @override
  String get whatDoYouSpendOn => 'Ukoresha amafaranga kuki?';

  @override
  String get selectAllCategories =>
      'Hitamo ibyiciro byose bijyanye n\'ibyo ukoresha';

  @override
  String get mainCategoriesNote =>
      'FinWise ikoresha ibi byiciro 23 nyamukuru ahantu hose kugira ngo ingengo y\'imari n\'inama byawe bisobanuke kandi byoroshye.';

  @override
  String get whyCategoriesMatter => 'Akamaro k\'ibyiciro:';

  @override
  String get whyCategoriesBullets =>
      '• Kurikirana ibyo ukoresha ku byiciro (Ibiryo, Ingendo, n\'ibindi)\n• Bona inama nka \"Uku kwezi wakoresheje 30% ku biryo\"\n• Shyiraho ingengo y\'imari kuri buri cyiciro maze ubone imenyesha\n• Ushobora kongeraho ibyiciro igihe icyo ari cyo cyose';

  @override
  String get addCustomCategoryHint => 'Ongeraho icyiciro cyawe...';

  @override
  String get addRemoveLater =>
      'Ushobora kongeraho cyangwa gukuraho ibyiciro nyuma mu igenamiterere.';

  @override
  String get permissionNotGrantedLater =>
      'Uruhushya ntirwatanzwe. Ushobora gufungura gukurikirana ubwabyo nyuma mu Igenamiterere.';

  @override
  String get trackAutomatically => 'Kurikirana amafaranga ubwabyo';

  @override
  String get trackAutomaticallyBody =>
      'Iki ni cyo gituma FinWise itandukana n\'izindi. Isoma SMS za Mobile Money ikandika buri bwishyu n\'ayinjiye — nta kwandika n\'intoki.';

  @override
  String get featInstant => 'Ako kanya';

  @override
  String get featInstantBody =>
      'Ibikorwa bishya bya MoMo bigaragara ku mafaranga yawe mu masegonda make.';

  @override
  String get featPrivate => 'Ibanga';

  @override
  String get featPrivateBody =>
      'Byose biguma kuri telefoni yawe. Nta kintu cyoherezwa cyangwa gisangizwa.';

  @override
  String get featAutomatic => 'Byikora';

  @override
  String get featAutomaticBody =>
      'Amafaranga, icyerekezo n\'icyiciro byuzuzwa nawe utabikoze.';

  @override
  String get autoTrackingOnFinish =>
      'Gukurikirana ubwabyo birakora. Kanda Tangira urangize.';

  @override
  String get requestingPermission => 'Turimo gusaba uruhushya…';

  @override
  String get enableAutoTracking => 'Fungura gukurikirana ubwabyo';

  @override
  String get turnOffAnytime =>
      'Ushobora kubizimya igihe icyo ari cyo cyose mu Igenamiterere.';

  @override
  String get optionalSkip =>
      'Si ngombwa — ushobora gusimbuka ukabifungura nyuma mu Igenamiterere.';

  @override
  String get faqS1 => 'Gukurikirana ubwabyo (SMS)';

  @override
  String get faqS1Q1 => 'Kumenya ubwabyo bikora gute?';

  @override
  String get faqS1A1 =>
      'Iyo ubifunguye, FinWise isoma SMS za Mobile Money zinjira (MTN, Airtel, ubutumwa bwa banki) kuri telefoni yawe ikandika igikorwa ubwayo — amafaranga, niba ari ayinjiye cyangwa ayasohotse, n\'uwo mwakoranye. Ikora nta interineti: nta kintu cyoherezwa ahandi uretse kuri telefoni yawe n\'iyo winjiye, kuri konti yawe ya FinWise.';

  @override
  String get faqS1Q2 => 'FinWise isoma ubutumwa bwanjye bwite?';

  @override
  String get faqS1A2 =>
      'Oya. Ubutumwa busa n\'ubwa Mobile Money cyangwa ubwa banki ni bwo bwonyine busesengurwa — ubundi bwose burirengagizwa kandi ntibubikwa cyangwa ngo bwoherezwe.';

  @override
  String get faqS1Q3 => 'Kuki nabonye imenyesha abiri ku bwishyu bumwe?';

  @override
  String get faqS1A3 =>
      'Ntibyakagombye kubaho. Iyo amafaranga amwe, umuntu umwe, n\'ubwoko bumwe bw\'ubutumwa (byombi \"wakiriye\" cyangwa byombi \"wohereje\") bigeze kabiri mu minota mike, FinWise ifata ubwa kabiri nk\'ubusubiyemo ntibwongere kwandikwa. Niba ukibona igisubiyemo, kanda \"Twandikire kuri imeyili\" hepfo utubwire itariki n\'amafaranga kugira ngo bikosorwe.';

  @override
  String get faqS1Q4 =>
      'SMS yamamaza cyangwa \"ipaki yarangiye\" yanditswe nk\'ayasohotse.';

  @override
  String get faqS1A4 =>
      'FinWise ikumira amagambo asanzwe yo kwamamaza, ariko ababitanga bahindura imiterere y\'ubutumwa uko igihe kigenda. Niba hari ubucikiye, busibe mu rutonde rw\'ibikorwa — kurura ibumoso, cyangwa ukande ugisibe.';

  @override
  String get faqS2 => 'Ihererekanya hagati ya konti zawe';

  @override
  String get faqS2Q1 =>
      'Nimuye amafaranga kuri Mobile Money nyajyana kuri banki — kuki atari ayinjiye cyangwa ayasohotse?';

  @override
  String get faqS2A1 =>
      'Kwimura amafaranga hagati ya konti zawe (Mobile Money ↔ banki, cyangwa kubika/kubikuza kuri MoCash) si inyungu cyangwa igihombo nyacyo — aracyari ayawe. FinWise ibyandika nk\'\"Ihererekanya\" ridafite ingaruka kugira ngo bitongera ayinjiye cyangwa ayakoreshejwe.';

  @override
  String get faqS2Q2 =>
      'FinWise imenya ite ko ari ihererekanya atari ubwishyu nyabwo?';

  @override
  String get faqS2A2 =>
      'Ahanini ikurikije imiterere: kwimura amafaranga hagati ya konti zawe akenshi bitanga SMS ebyiri — imwe ivuga ko amafaranga yavuye kuri konti, indi ivuga ko amafaranga angana atyo yageze — afite amafaranga amwe, izina rimwe, mu minota mike. FinWise izihuza ubwayo. Ntishingira ku izina riri ku mwirondoro wawe, bityo ikora n\'iyo konti zawe zanditse ku rindi zina.';

  @override
  String get faqS2Q3 => 'Bite ku nguzanyo yo kuri MoCash?';

  @override
  String get faqS2A3 =>
      'Inguzanyo ihindura koko ibyo ufite cyangwa ibyo ufitiye abandi, bityo yandikwa bisanzwe — kwakira inguzanyo ni ayinjiye, kuyishyura ni ayasohotse. Kubika cyangwa kubikuza bisanzwe kuri MoCash ni byo byonyine bifatwa nk\'ihererekanya.';

  @override
  String get faqS2Q4 => 'Amafaranga yishyurwa ku ihererekanya arandikwa?';

  @override
  String get faqS2A4 =>
      'Yego. Ihererekanya ubwaryo nta ngaruka rifite, ariko amafaranga yishyuzwa kuri ryo ni ikiguzi nyacyo, bityo yandikwa ukwayo nk\'ayasohotse make.';

  @override
  String get faqS3 => 'Intego n\'amafaranga wabitse';

  @override
  String get faqS3Q1 =>
      'Iyo mbitse amafaranga y\'intego, abarwa nk\'ayakoreshejwe?';

  @override
  String get faqS3A1 =>
      'Oya. Amafaranga abikiwe intego arabikwa, ntaba yakoreshejwe — aracyagaragara kuri konti yawe. Aba ayasohotse nyayo gusa iyo wemeje ko waguze.';

  @override
  String get faqS3Q2 =>
      'Nemeje ko naguze ariko narasanzwe naranditse ayo mafaranga avuye kuri SMS — azabarwa kabiri?';

  @override
  String get faqS3A2 =>
      'Oya — iyo wemeza ko waguze, ushobora kubihuza n\'igikorwa gisanzwe cyanditswe (urugero icyamenyekanye muri SMS) aho gukora igishya, bityo bikabarwa rimwe gusa.';

  @override
  String get faqS4 => 'Ifaranga na konti';

  @override
  String get faqS4Q1 =>
      'Bigenda bite iyo mpinduye ifaranga maze kwandika ibikorwa?';

  @override
  String get faqS4A1 =>
      'Amafaranga ntahindurwa — igikorwa cyanditswe ari 500 RWF kizagaragara ari 500 mu ifaranga rishya, umubare umwe, izina ritandukanye. FinWise ibikuburira mbere y\'uko bihinduka, kuko idakoresha igiciro cy\'ivunjisha cy\'ako kanya.';

  @override
  String get faqS5 => 'Ibanga n\'amakuru';

  @override
  String get faqS5Q1 => 'FinWise ifata ifoto yanjye?';

  @override
  String get faqS5A1 =>
      'Oya. FinWise yerekana inyuguti ya mbere y\'izina ryawe aho kuba ifoto — nta foto n\'imwe yoherezwa.';

  @override
  String get faqS5Q2 =>
      'Nshobora gukoresha FinWise ntakoresheje kumenya SMS ubwabyo?';

  @override
  String get faqS5A2 =>
      'Yego — si ngombwa. Ushobora kwandika buri gikorwa n\'intoki kandi ntutange uruhushya rwa SMS na rimwe.';

  @override
  String get faqS5Q3 => 'Nsiba nte konti yanjye n\'amakuru yanjye?';

  @override
  String get faqS5A3 =>
      'Igenamiterere → Siba konti. Ibi bisiba burundu ibikorwa byawe, intego, umwirondoro n\'uburyo bwo kwinjira — ntibishobora gusubizwaho, bityo banza wohereze amakuru yawe.';

  @override
  String get faqS5Q4 => 'Nshobora kohereza amakuru yanjye?';

  @override
  String get faqS5A4 =>
      'Yego — Igenamiterere → Kohereza nka CSV cyangwa Kohereza raporo.';

  @override
  String get faqS6 => 'Ifunga rya porogaramu';

  @override
  String get faqS6Q1 => 'Nfungura nte ifunga rya PIN cyangwa igikumwe?';

  @override
  String get faqS6A1 =>
      'Igenamiterere → Umutekano → Ifunga rya porogaramu. Ushobora gukoresha PIN, cyangwa igikumwe/isura bya telefoni yawe aho bishoboka.';

  @override
  String get faqS6Q2 => 'Nibagiwe PIN yanjye.';

  @override
  String get faqS6A2 =>
      'Ku ipaji ifunga, kanda \"Wibagiwe PIN?\" — biragusohora ukongera kwinjira ukoresheje imeyili n\'ijambo ry\'ibanga bya FinWise, hanyuma ugashyiraho PIN nshya.';

  @override
  String get stillNeedHelp => 'Uracyakeneye ubufasha?';

  @override
  String get reachOutDirectly => 'Twandikire tuzagusubiza.';

  @override
  String get legalTermsTitle => 'Amategeko n\'amabwiriza';

  @override
  String get legalTermsIntro =>
      'Iyo ufunguye konti ya FinWise uba wemeye aya mategeko. Yasome witonze.';

  @override
  String get legalTermsS1T => '1. Gukoresha FinWise';

  @override
  String get legalTermsS1C =>
      '• FinWise igufasha gukurikirana amafaranga winjiza, ayo ukoresha n\'intego zawe zo kuzigama.\n• Ugomba kuba ufite imyaka ikwiye yo kugirana amasezerano mu gihugu cyawe.\n• Ni wowe ushinzwe kurinda amakuru yawe yo kwinjira kuri konti.\n• Koresha porogaramu gusa mu gucunga imari yawe bwite mu buryo bwemewe n\'amategeko.';

  @override
  String get legalTermsS2T => '2. Amakuru yawe ni ayawe';

  @override
  String get legalTermsS2C =>
      '• Amakuru y\'imari wandika ni ayawe.\n• Tuyabika kugira ngo tuguhe serivisi kandi tuyahuze ku bikoresho byawe byose.\n• Ushobora kohereza cyangwa gusiba amakuru yawe igihe icyo ari cyo cyose mu Igenamiterere.';

  @override
  String get legalTermsS3T => '3. Kumenya SMS za Mobile Money';

  @override
  String get legalTermsS3C =>
      '• Iki gice kitari ngombwa gisoma ubutumwa bwa Mobile Money kuri telefoni yawe kugira ngo cyandike ibikorwa ubwacyo.\n• Ubutumwa busesengurirwa kuri telefoni yawe gusa. Ibikubiye mu butumwa ntibyoherezwa cyangwa ngo bisangizwe.\n• Ubutumwa bw\'imari bwonyine ni bwo bukoreshwa; SMS bwite zirirengagizwa.\n• Ushobora kubizimya igihe icyo ari cyo cyose mu Igenamiterere.';

  @override
  String get legalTermsS4T => '4. Ukuri n\'ibyemezo by\'imari';

  @override
  String get legalTermsS4C =>
      '• FinWise ni igikoresho cyo gukurikirana, si inama ku by\'imari, ishoramari, imisoro cyangwa amategeko.\n• Kumenya no gushyira mu byiciro ubwabyo bishobora rimwe na rimwe kwibeshya — buri gihe suzuma ibyo wanditse.\n• Ni wowe ukomeza kuba nyirabayazana w\'ibyemezo byawe by\'imari.';

  @override
  String get legalTermsS5T => '5. Kuboneka kwa serivisi';

  @override
  String get legalTermsS5C =>
      '• Duharanira ko FinWise iboneka kandi ikora neza, ariko serivisi itangwa \"uko iri\".\n• Ibice bishobora guhinduka, kandi guhuza amakuru biterwa na interineti yawe.';

  @override
  String get legalTermsS6T => '6. Gusoza konti yawe';

  @override
  String get legalTermsS6C =>
      '• Ushobora kureka gukoresha FinWise no gusiba amakuru yawe igihe icyo ari cyo cyose.\n• Dushobora guhagarika konti zikoresha nabi serivisi cyangwa zirengera aya mategeko.';

  @override
  String get legalTermsS7T => '7. Impinduka kuri aya mategeko';

  @override
  String get legalTermsS7C =>
      'Dushobora kuvugurura aya mategeko uko porogaramu igenda itera imbere. Gukomeza gukoresha FinWise nyuma y\'ivugurura bisobanura ko wemeye amategeko mashya.';

  @override
  String get legalPrivacyTitle => 'Politiki y\'ibanga';

  @override
  String get legalPrivacyIntro =>
      'FinWise igufasha gukurikirana amafaranga yawe. Iyi politiki isobanura neza ibyo dukusanya, ibiguma kuri telefoni yawe, n\'ibyo tutigera dukora.';

  @override
  String get legalPrivacyS1T => '1. Ibiguma kuri telefoni yawe gusa';

  @override
  String get legalPrivacyS1C =>
      'Ibikurikira NTIBIGERA biva kuri telefoni yawe kandi ntibyoherezwa:\n\n• Ibikubiye muri SMS. Ubutumwa bwa Mobile Money n\'ubwa banki busomwa kandi bugasesengurirwa kuri telefoni yawe gusa. Ntitwohereza, ntitubika kandi ntitwohereza ahandi inyandiko z\'ubutumwa.\n• PIN ifunga porogaramu. Ibikwa gusa mu buryo bwahinduwe budashobora gusubizwa inyuma.\n• Amakuru y\'igikumwe / isura. Android ikwemeza ikoresheje ibikoresho byizewe maze ikabwira porogaramu \"yego\" cyangwa \"oya\" gusa. FinWise ntigera yakira, ibona cyangwa ibika amakuru y\'umubiri.';

  @override
  String get legalPrivacyS2T =>
      '2. Kumenya SMS za Mobile Money (bitari ngombwa)';

  @override
  String get legalPrivacyS2C =>
      'Iyo ufunguye kumenya ubwabyo, FinWise ikoresha uruhushya rwa SMS kugira ngo yandike ibikorwa byawe ubwayo.\n\n• Intego: gusoma ubutumwa bw\'imari buturuka kuri Mobile Money no ku mabanki kugira ngo ibikorwa byandikwe utabyanditse n\'intoki.\n• Ubutumwa bw\'imari bwonyine ni bwo bukoreshwa. Ubutumwa bwite burirengagizwa.\n• Amafaranga, icyerekezo, itariki n\'izina ry\'uwo mwakoranye ni byo byonyine bibikwa nk\'igikorwa — ntibibika ubutumwa bwose uko bwakabaye.\n• Isesengura rikorerwa kuri telefoni yawe, nta interineti.\n• Ushobora kubizimya igihe icyo ari cyo cyose mu Igenamiterere, kandi ukambura uruhushya mu igenamiterere rya telefoni.\n\nIri koreshwa ryubahiriza ibyo Google Play yemera ku gucunga amafaranga hakoreshejwe SMS.';

  @override
  String get legalPrivacyS3T => '3. Amakuru dukusanya';

  @override
  String get legalPrivacyS3C =>
      '• Konti: imeyili n\'izina (mu kwinjira no gutuma porogaramu ikubera)\n• Amakuru y\'imari: ibikorwa wongeraho cyangwa bimenyekanye — amafaranga, ibisobanuro, icyiciro, itariki n\'ubwoko bwa konti\n• Intego: amazina, amafaranga y\'intego, amatariki n\'amateka y\'ibyo wabitse\n• Ibyo wahisemo: ifaranga, intego y\'amafaranga winjiza (bitari ngombwa), igenamiterere rya porogaramu\n\nNtidukusanya amafoto. FinWise nta foto yohereza kandi ntisaba kamera cyangwa ububiko bw\'amafoto — ishusho yawe ni inyuguti ya mbere y\'izina ryawe gusa.';

  @override
  String get legalPrivacyS4T => '4. Aho amakuru yawe abikwa';

  @override
  String get legalPrivacyS4C =>
      '• Kuri telefoni yawe: kopi y\'ibikorwa byawe n\'igenamiterere, kugira ngo porogaramu ikore nta interineti kandi ifunguke vuba.\n• Mu bubiko bwo kuri interineti (Firebase, icungwa na Google): amakuru ya konti yawe, ibikorwa n\'intego — kugira ngo amakuru yawe atabura iyo telefoni yatakaye kandi ahuzwe ku bikoresho byawe.\n\nAmakuru yo kuri interineti arinzwe (encrypted) iyo yoherezwa n\'iyo abitswe. Amabwiriza y\'umutekano atuma konti yawe yinjiye yonyine ari yo ishobora gusoma ibyo wanditse.';

  @override
  String get legalPrivacyS5T => '5. Imenyesha n\'ibikorwa bikorerwa inyuma';

  @override
  String get legalPrivacyS5C =>
      '• FinWise yerekana imenyesha iyo igikorwa kimenyekanye.\n• Igihe kumenya ubwabyo bifunguye, imenyesha rihoraho ryerekana ko FinWise irimo gukurikirana ibikorwa. Android ibisaba ku porogaramu yose ikorera inyuma, kandi bituma kumenya byizerwa.\n• Ibikorwa bikorerwa inyuma bikoreshwa gusa mu kumenya ibikorwa. Ntidukurikirana aho uri cyangwa uko ukoresha izindi porogaramu.';

  @override
  String get legalPrivacyS6T => '6. Ibyo tutigera dukora';

  @override
  String get legalPrivacyS6C =>
      '• Ntitwigera tugurisha amakuru yawe bwite.\n• Ntitwigera dusangiza amakuru yawe y\'imari abamamaza cyangwa abacuruza amakuru.\n• Ntitwigera twohereza ibikubiye muri SMS.\n• Ntitwimura amafaranga, ntitwinjira kuri konti yawe ya banki cyangwa ya Mobile Money, kandi ntitugusaba PIN cyangwa amakuru yo kwinjira muri banki.\n• Ntitwerekana kwamamaza.';

  @override
  String get legalPrivacyS7T => '7. Serivisi z\'abandi';

  @override
  String get legalPrivacyS7C =>
      'Dukoresha Firebase (Google) mu kwinjira, mu bubiko bw\'amakuru no mu kubika amadosiye. Politiki y\'ibanga ya Google ni yo ikurikizwa ku buryo ifata ayo makuru: https://policies.google.com/privacy\n\nNta yindi serivisi y\'abandi ihabwa amakuru yawe.';

  @override
  String get legalPrivacyS8T => '8. Uburenganzira bwawe n\'ubugenzuzi';

  @override
  String get legalPrivacyS8C =>
      '• Kureba: reba amakuru yawe yose muri porogaramu\n• Kohereza: kuramo ibikorwa byawe nka CSV cyangwa PDF\n• Gusiba: siba ibyanditswe kimwe kimwe, siba amakuru yose, cyangwa usibe konti yawe burundu\n• Kwisubiraho: zimya kumenya SMS igihe icyo ari cyo cyose\n• Gusohoka: bihagarika guhuza amakuru kuri iyo telefoni';

  @override
  String get legalPrivacyS9T => '9. Igihe amakuru abikwa';

  @override
  String get legalPrivacyS9C =>
      'Amakuru yawe abikwa kugeza uyasibye. Gusiba icyanditswe bigikura kuri telefoni yawe no ku bubiko bwo kuri interineti. Gusiba konti yawe bikuraho burundu amakuru yawe yabitswe.';

  @override
  String get legalPrivacyS10T => '10. Ibanga ry\'abana';

  @override
  String get legalPrivacyS10C =>
      'FinWise ntigenewe abari munsi y\'imyaka 13. Ntitukusanya tubizi amakuru y\'abana.';

  @override
  String get legalPrivacyS11T => '11. Impinduka kuri iyi politiki';

  @override
  String get legalPrivacyS11C =>
      'Iyo iyi politiki ihindutse, itariki iri hepfo ivugururwa. Impinduka zikomeye zigira ingaruka ku buryo amakuru yawe akoreshwa zizamenyeshwa muri porogaramu.';

  @override
  String get legalPrivacyS12T => '12. Kutwandikira';

  @override
  String get legalPrivacyS12C =>
      'Ku kibazo icyo ari cyo cyose kijyanye n\'ibanga cyangwa gusaba ko amakuru yawe asibwa, twandikire unyuze mu Bufasha muri porogaramu.';

  @override
  String legalLastUpdated(String date) {
    return 'Byavuguruwe bwa nyuma: $date';
  }

  @override
  String get legalUpdatedDate => 'Nyakanga 2026';

  @override
  String get legalTranslationNote =>
      'Iyi ni inyandiko yahinduwe mu Kinyarwanda kugira ngo yorohe gusoma. Iyo hari aho itandukaniye n\'iy\'Icyongereza, iy\'Icyongereza ni yo ifite agaciro.';

  @override
  String get biometricReason => 'Fungura FinWise urebe imari yawe';
}
