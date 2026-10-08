import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../models/overview_period.dart';
import '../models/transaction.dart';
import '../models/currency.dart';
import 'app_localizations.dart';

/// `context.l10n.navHome` — shorthand for the current language's texts.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isKinyarwanda =>
      Localizations.localeOf(this).languageCode == 'rw';
}

const _rwMonths = [
  'Mutarama', 'Gashyantare', 'Werurwe', 'Mata', 'Gicurasi', 'Kamena',
  'Nyakanga', 'Kanama', 'Nzeri', 'Ukwakira', 'Ugushyingo', 'Ukuboza',
];

/// Full month name in the current language. The date-formatting library has
/// no Kinyarwanda, so its month names are supplied here.
String monthName(BuildContext context, DateTime d) => context.isKinyarwanda
    ? _rwMonths[d.month - 1]
    : DateFormat('MMMM').format(d);

/// "Oct 7, 2026" in English, "7 Ukwakira 2026" in Kinyarwanda.
/// [withYear] false drops the year ("Oct 7" / "7 Ukwakira").
String formatDay(BuildContext context, DateTime d, {bool withYear = true}) {
  if (context.isKinyarwanda) {
    return withYear
        ? '${d.day} ${_rwMonths[d.month - 1]} ${d.year}'
        : '${d.day} ${_rwMonths[d.month - 1]}';
  }
  return DateFormat(withYear ? 'MMM d, y' : 'MMM d').format(d);
}

String accountName(BuildContext context, AccountType a) {
  final l = context.l10n;
  switch (a) {
    case AccountType.cash:
      return l.accountCash;
    case AccountType.bank:
      return l.accountBank;
    case AccountType.mobileMoney:
      return l.accountMobileMoney;
  }
}

/// "This month · October" / "Uku kwezi · Ukwakira", "Last 60 days", etc.
String periodLabel(BuildContext context, OverviewPeriod p) {
  final l = context.l10n;
  final now = DateTime.now();
  switch (p.kind) {
    case OverviewPeriodKind.month:
      final name = monthName(context, p.start);
      if (p.start.year == now.year && p.start.month == now.month) {
        return '${l.periodThisMonth} · $name';
      }
      final prev = DateTime(now.year, now.month - 1);
      if (p.start.year == prev.year && p.start.month == prev.month) {
        return '${l.periodLastMonth} · $name';
      }
      return p.start.year == now.year ? name : '$name ${p.start.year}';
    case OverviewPeriodKind.year:
      return p.start.year == now.year
          ? '${l.periodThisYear} · ${p.start.year}'
          : '${p.start.year}';
    case OverviewPeriodKind.lastDays:
      return l.periodLastDays(p.end.difference(p.start).inDays);
    case OverviewPeriodKind.custom:
      final last = p.end.subtract(const Duration(days: 1));
      final sameYear = p.start.year == last.year && p.start.year == now.year;
      if (context.isKinyarwanda) {
        return '${formatDay(context, p.start, withYear: !sameYear)} – '
            '${formatDay(context, last, withYear: !sameYear)}';
      }
      final fmt = DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy');
      return '${fmt.format(p.start)} – ${fmt.format(last)}';
    case OverviewPeriodKind.allTime:
      return l.periodAllTime;
  }
}

/// How long a goal took to save for: "3 months" / "mezi 3", or '' when
/// nothing was ever reserved.
String savingSpanText(BuildContext context, Goal goal, {DateTime? until}) {
  final reserves = goal.contributions.where((c) => !c.isRelease);
  if (reserves.isEmpty) return '';
  final months =
      ((until ?? DateTime.now()).difference(reserves.first.date).inDays / 30)
          .round();
  if (months <= 0) return context.l10n.spanLessThanMonth;
  return context.l10n.spanMonths(months);
}

/// Income frequency is stored in English ('Monthly', 'Weekly', …) because
/// other code compares against those values; only the display is translated.
String frequencyLabel(BuildContext context, String stored) {
  final l = context.l10n;
  switch (stored) {
    case 'Daily':
      return l.freqDaily;
    case 'Weekly':
      return l.freqWeekly;
    case 'Monthly':
      return l.freqMonthly;
    case 'Yearly':
      return l.freqYearly;
    case 'Irregular':
      return l.freqIrregular;
    default:
      return stored;
  }
}

/// Category names in the current language. `Category.name` itself is the
/// value saved with every transaction, so it is never changed — only shown
/// through this.
String categoryLabel(BuildContext context, Category c) =>
    categoryLabelFor(context.l10n, c);

/// Same as [categoryLabel] for code without a BuildContext (services,
/// notifications).
String categoryLabelFor(AppLocalizations l, Category c) {
  switch (c) {
    case Category.food: return l.catFood;
    case Category.transport: return l.catTransport;
    case Category.entertainment: return l.catEntertainment;
    case Category.utilities: return l.catUtilities;
    case Category.rent: return l.catRent;
    case Category.shopping: return l.catShopping;
    case Category.vacation: return l.catVacation;
    case Category.clothes: return l.catClothes;
    case Category.water: return l.catWater;
    case Category.shoes: return l.catShoes;
    case Category.health: return l.catHealth;
    case Category.education: return l.catEducation;
    case Category.family: return l.catFamily;
    case Category.debt: return l.catDebt;
    case Category.business: return l.catBusiness;
    case Category.giving: return l.catGiving;
    case Category.fees: return l.catFees;
    case Category.personal: return l.catPersonal;
    case Category.medicine: return l.catMedicine;
    case Category.alcohol: return l.catAlcohol;
    case Category.tobacco: return l.catTobacco;
    case Category.income: return l.catIncome;
    case Category.savings: return l.catSavings;
    case Category.other: return l.catOther;
  }
}

String reasonLabel(BuildContext context, SpendingReason r) {
  final l = context.l10n;
  switch (r) {
    case SpendingReason.necessity: return l.reasonNecessity;
    case SpendingReason.business: return l.reasonBusiness;
    case SpendingReason.enjoyment: return l.reasonEnjoyment;
    case SpendingReason.emergency: return l.reasonEmergency;
  }
}

String currencyName(BuildContext context, AppCurrency c) {
  final l = context.l10n;
  switch (c) {
    case AppCurrency.rwf: return l.curRwf;
    case AppCurrency.usd: return l.curUsd;
    case AppCurrency.eur: return l.curEur;
    case AppCurrency.gbp: return l.curGbp;
    case AppCurrency.kes: return l.curKes;
    case AppCurrency.ugx: return l.curUgx;
    case AppCurrency.tzs: return l.curTzs;
    case AppCurrency.ngn: return l.curNgn;
    case AppCurrency.ghs: return l.curGhs;
    case AppCurrency.zar: return l.curZar;
    case AppCurrency.xaf: return l.curXaf;
    case AppCurrency.cad: return l.curCad;
    case AppCurrency.inr: return l.curInr;
  }
}

/// Name under each goal icon ("Laptop", "Emergency fund"…).
String goalIconName(BuildContext context, String key) {
  final l = context.l10n;
  switch (key) {
    case 'savings': return l.giSavings;
    case 'laptop': return l.giLaptop;
    case 'car': return l.giCar;
    case 'house': return l.giHouse;
    case 'land': return l.giLand;
    case 'education': return l.giEducation;
    case 'business': return l.giBusiness;
    case 'travel': return l.giTravel;
    case 'wedding': return l.giWedding;
    case 'family': return l.giFamily;
    case 'health': return l.giHealth;
    case 'emergency': return l.giEmergency;
    case 'phone': return l.giPhone;
    case 'furniture': return l.giFurniture;
    case 'clothes': return l.giClothes;
    case 'gaming': return l.giGaming;
    case 'debt': return l.giDebt;
    case 'gift': return l.giGift;
    default: return l.giOther;
  }
}

const _rwMonthsShort = [
  'Mut', 'Gas', 'Wer', 'Mat', 'Gic', 'Kam',
  'Nya', 'Kan', 'Nze', 'Ukw', 'Ugu', 'Uku',
];

/// Short month name for chart axes: "Oct" / "Ukw".
String monthAbbr(BuildContext context, DateTime d) => context.isKinyarwanda
    ? _rwMonthsShort[d.month - 1]
    : DateFormat('MMM').format(d);

const _rwWeekdays = [
  'Kuwa mbere', 'Kuwa kabiri', 'Kuwa gatatu', 'Kuwa kane',
  'Kuwa gatanu', 'Kuwa gatandatu', 'Ku cyumweru',
];
const _rwWeekdaysShort = ['Mbe', 'Kab', 'Gat', 'Kan', 'Gtn', 'Gtd', 'Cyu'];

/// "Wednesday, October 8, 2026" / "Kuwa gatatu, 8 Ukwakira 2026".
String formatFullDate(BuildContext context, DateTime d) => context.isKinyarwanda
    ? '${_rwWeekdays[d.weekday - 1]}, ${d.day} ${_rwMonths[d.month - 1]} ${d.year}'
    : DateFormat('EEEE, MMMM d, yyyy').format(d);

/// Calendar column headers: "Mon" / "Mbe".
String weekdayShort(BuildContext context, DateTime d) => context.isKinyarwanda
    ? _rwWeekdaysShort[d.weekday - 1]
    : DateFormat('E').format(d);

/// Descriptions FinWise itself writes ("Transfer fee", "Bought: Laptop", a
/// category name when no description was typed) are shown in the current
/// language, even for records saved earlier in the other language. Text that
/// came from an SMS or that the user typed is shown exactly as it is.
String displayDescription(BuildContext context, String description) =>
    displayDescriptionFor(context.l10n, description);

/// [displayDescription] for code without a BuildContext (notifications).
String displayDescriptionFor(AppLocalizations l, String description) {
  final en = lookupAppLocalizations(const Locale('en'));
  final rw = lookupAppLocalizations(const Locale('rw'));

  if (description == en.transferBetweenAccounts ||
      description == rw.transferBetweenAccounts) {
    return l.transferBetweenAccounts;
  }
  if (description == en.transferFee || description == rw.transferFee) {
    return l.transferFee;
  }
  for (final pair in [
    (en.transferConfirmation(''), l.transferConfirmation),
    (rw.transferConfirmation(''), l.transferConfirmation),
    (en.boughtDesc(''), l.boughtDesc),
    (rw.boughtDesc(''), l.boughtDesc),
  ]) {
    if (description.startsWith(pair.$1)) {
      return pair.$2(description.substring(pair.$1.length));
    }
  }
  for (final c in Category.values) {
    if (description == c.name || description == categoryLabelFor(rw, c)) {
      return categoryLabelFor(l, c);
    }
  }
  return description;
}

/// Spending style is saved in English ('Saver', 'Balanced', …); only shown
/// translated.
String spendingStyleLabel(BuildContext context, String stored) {
  final l = context.l10n;
  switch (stored) {
    case 'Saver':
      return l.styleSaver;
    case 'Balanced':
      return l.styleBalanced;
    case 'Spender':
      return l.styleSpender;
    case 'Overspender':
      return l.styleOverspender;
    default:
      return stored;
  }
}

/// Onboarding category choices are saved by their English name; shown in
/// the current language.
String onboardingCategoryLabel(BuildContext context, String stored) {
  if (stored == 'Electricity') return context.l10n.catElectricity;
  for (final c in Category.values) {
    if (c.name == stored) return categoryLabel(context, c);
  }
  return stored;
}
