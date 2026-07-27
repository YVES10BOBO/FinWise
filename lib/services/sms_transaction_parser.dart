import '../models/transaction.dart';

/// Result of attempting to parse a Mobile Money SMS into a transaction.
class ParsedSmsTransaction {
  final TransactionType type;
  final double amount;
  final String description;
  final AccountType account;
  final DateTime detectedAt;
  final String rawSnippet; // short, non-sensitive preview for the review UI

  /// The provider's own unique transaction reference pulled from the SMS
  /// (e.g. "FT Id: 29391685510" / "TxId:29389172099"). Used as the stable
  /// identity for de-duplication, so the same real SMS is never recorded
  /// twice regardless of which code path saw it. Null if none was found.
  final String? txId;

  /// The full message body. Kept so categorization can scan the whole text
  /// (merchant/biller names like "Cash Power", "airtime", "tuition"), not
  /// just the short counterparty description.
  final String messageBody;

  /// Provider fee charged on this transaction, when the SMS states one.
  /// For expenses it is already INCLUDED in [amount], because the fee really
  /// does leave the account. Kept separately so it can be shown to the user.
  final double? fee;

  ParsedSmsTransaction({
    required this.type,
    required this.amount,
    required this.description,
    required this.account,
    required this.detectedAt,
    required this.rawSnippet,
    required this.messageBody,
    this.txId,
    this.fee,
  });
}

/// Parses incoming SMS text into a draft transaction — completely offline,
/// no network calls, no data leaves the device.
///
/// IMPORTANT — this is a starting point, not a finished product:
/// MTN Mobile Money and Airtel Money message wording varies by country,
/// language, and over time as providers tweak their templates. The
/// patterns below cover the common English-language RWF formats seen in
/// Rwanda as of this writing, but they WILL need tuning against real
/// messages on the developer's own phone. Use the "Test SMS Parser" tool
/// in Settings to paste a real (redacted) message and see exactly what
/// this parser extracts, then adjust the regex below to match.
class SmsTransactionParser {
  /// Only process messages that plausibly come from a Mobile Money service.
  /// This keeps the app from ever reading or acting on personal SMS —
  /// required both for good behavior and for Play Store's Spyware policy,
  /// which prohibits exfiltrating/using non-financial SMS content.
  /// Currency tokens the parser recognises in message text. Covers every
  /// currency the app supports plus the local spellings providers actually
  /// use (e.g. "Frw" in Rwanda, "Ksh" in Kenya, "USh" in Uganda).
  static const List<String> currencyTokens = [
    'RWF', 'FRW',
    'KES', 'KSH', 'KSHS',
    'UGX', 'USH',
    'TZS', 'TSH',
    'NGN',
    'GHS', 'GHC',
    'ZAR',
    'XAF', 'FCFA', 'CFA',
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'INR',
  ];

  static bool looksLikeMomoMessage(String sender, String body) {
    final normalizedSender = sender.toLowerCase();
    final normalizedBody = body.toLowerCase();

    // Mobile Money / bank senders across the markets the app supports.
    final trustedSenderHints = [
      // Rwanda
      'mtn', 'momo', 'm-money', 'airtel', 'bk', 'bank of kigali', 'equity',
      // Kenya
      'm-pesa', 'mpesa', 'safaricom',
      // Uganda / Tanzania
      'tigo', 'vodacom', 'halopesa', 'azampesa',
      // Nigeria / Ghana
      'opay', 'palmpay', 'kuda', 'mtn momo', 'telecel',
      // Generic
      'mobile money', 'wallet', 'bank',
    ];
    final senderLooksTrusted =
        trustedSenderHints.any((hint) => normalizedSender.contains(hint));

    // Or: the body mentions any supported currency AND reads like a
    // transaction notification.
    final mentionsCurrency = currencyTokens
        .any((c) => normalizedBody.contains(c.toLowerCase()));

    const financialWords = [
      // English
      'balance', 'transaction', 'txid', 'tx id', 'received', 'payment',
      'paid', 'sent', 'withdraw', 'deposit', 'completed', 'confirmed',
      // Kinyarwanda
      'umutungo', // balance / assets
      'asigaye', // remaining
      'ubu ufite', // you now have
      'wakiriye', 'wishyuye', 'wohereje', 'watanze', 'wahawe',
      'amafaranga', // money
      'ikiguzi', // cost / fee
      'serivisi', // service (fee)
    ];

    final bodyLooksFinancial =
        mentionsCurrency && financialWords.any(normalizedBody.contains);

    return senderLooksTrusted || bodyLooksFinancial;
  }

  /// Attempt to parse a transaction out of the message. Returns null if it
  /// doesn't look like a recognizable Mobile Money transaction SMS.
  static ParsedSmsTransaction? parse(
    String sender,
    String body, {
    DateTime? receivedAt,
  }) {
    if (!looksLikeMomoMessage(sender, body)) return null;

    final amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    final type = _extractDirection(body);

    // Transaction fees genuinely leave the account, so an expense of 1,000
    // with a 20 fee reduces the balance by 1,020. Counting only the headline
    // amount would make the tracked balance drift from the real one.
    // Fees are added to expenses; for incoming money the provider normally
    // states the net amount already, so nothing is added.
    final fee = _extractFee(body) ?? 0;
    final total = type == TransactionType.expense ? amount + fee : amount;

    final counterparty = _extractCounterparty(body);
    var description = counterparty ??
        (type == TransactionType.income
            ? 'Mobile Money received'
            : 'Mobile Money payment');
    // Make the fee visible so the figure is never a mystery.
    if (fee > 0 && type == TransactionType.expense) {
      description = '$description (incl. ${_trimAmount(fee)} fee)';
    }

    // Preview only the first ~80 chars for the confirmation UI — enough
    // context for the user to recognize it, without dumping the whole SMS.
    final snippet = body.length > 80 ? '${body.substring(0, 80)}…' : body;

    return ParsedSmsTransaction(
      type: type,
      amount: total,
      description: description,
      account: AccountType.mobileMoney,
      detectedAt: receivedAt ?? DateTime.now(),
      rawSnippet: snippet,
      messageBody: body,
      txId: _extractTransactionId(body),
      fee: fee > 0 ? fee : null,
    );
  }

  /// Pull a transaction fee out of the message.
  ///
  /// Providers word this several ways:
  ///   "Fee 0 RWF" · "with access fee 9 RWF" · "charge: 20 RWF"
  ///   "Transaction cost, Ksh 23.00" (M-Pesa)
  static double? _extractFee(String body) {
    final tokens = [...currencyTokens]
      ..sort((a, b) => b.length.compareTo(a.length));
    final codes = tokens.join('|');

    const feeWords = r'access\s+fee|transaction\s+cost|fee|charge|cost'
        r'|commission|ikiguzi|serivisi';
    const number = r'([\d,]+(?:\.\d{1,2})?)';

    final patterns = [
      // "fee 9 RWF" / "charge 20 RWF" / "transaction cost Ksh 23.00"
      // plus Kinyarwanda: "ikiguzi 20 RWF", "amafaranga ya serivisi 20"
      RegExp(
        '(?:$feeWords)[:\\s]*(?:of\\s+|cya\\s+|ya\\s+)?(?:$codes)?\\s?$number',
        caseSensitive: false,
      ),
      // "fee of RWF 20" — currency before the number
      RegExp(
        '(?:fee|charge|cost|ikiguzi)[:\\s]*(?:of\\s+)?$number\\s?(?:$codes)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final raw = match.group(1)?.replaceAll(',', '');
        final value = double.tryParse(raw ?? '');
        // A "fee" larger than most transactions is a mis-parse — ignore it.
        if (value != null && value > 0 && value < 1000000) return value;
      }
    }
    return null;
  }

  /// 20 → "20", 23.5 → "23.5" (no trailing ".0")
  static String _trimAmount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  /// Pull the provider's unique transaction reference out of the SMS. MoMo
  /// messages always include one, under labels like "TxId", "FT Id",
  /// "Financial transaction id", etc. This is the most reliable de-dup key.
  static String? _extractTransactionId(String body) {
    // 1. Labelled id (most reliable).
    final labelled = RegExp(
      r'(?:financial\s+transaction\s+id|transaction\s+id|tx\s?id|ft\s?id|txid|ref(?:erence)?)\s*[:#]?\s*([0-9]{6,})',
      caseSensitive: false,
    ).firstMatch(body);
    if (labelled != null) return labelled.group(1);

    // 2. Fallback: the longest run of 9+ digits. Transaction ids are long,
    //    while amounts/balances are short and phone numbers are masked, so
    //    the longest digit run is almost always the transaction reference.
    final runs = RegExp(r'[0-9]{9,}')
        .allMatches(body)
        .map((m) => m.group(0)!)
        .toList();
    if (runs.isNotEmpty) {
      runs.sort((a, b) => b.length.compareTo(a.length));
      return runs.first;
    }
    return null;
  }

  static double? _extractAmount(String body) {
    // Build one alternation from every supported currency token, longest
    // first so "KSHS" wins over "KSH". Matches both orders and an optional
    // symbol form: "12,500 RWF", "KSh 1,200", "Frw12500", "$45.99".
    final tokens = [...currencyTokens]
      ..sort((a, b) => b.length.compareTo(a.length));
    final codes = tokens.join('|');

    final patterns = [
      RegExp(r'(?:' + codes + r')\s?([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
      RegExp(r'([\d,]+(?:\.\d{1,2})?)\s?(?:' + codes + r')',
          caseSensitive: false),
      // Symbol-prefixed amounts for currencies written with a sign.
      RegExp(r'[\$£€₦₹]\s?([\d,]+(?:\.\d{1,2})?)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final raw = match.group(1)?.replaceAll(',', '');
        final value = double.tryParse(raw ?? '');
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  static TransactionType _extractDirection(String body) {
    final lower = body.toLowerCase();
    // Wording varies by provider, country AND language, so the lists stay
    // broad. Kinyarwanda terms are included because MTN/Airtel Rwanda send
    // messages in the subscriber's chosen language — without these, a
    // Kinyarwanda "money received" message would fall through to the default
    // and be recorded as an expense.
    const incomingHints = [
      // English
      'you have received',
      'received from',
      'you received',
      'deposit',
      'credited',
      'has been credited',
      'added to your',
      // Kinyarwanda
      'wakiriye', // you have received
      'wahawe', // you were given
      'woherejwe', // was sent to you
      'yakiriwe', // was received
      'winjijwe', // was deposited
    ];
    const outgoingHints = [
      // English
      'you have paid',
      'payment of',
      'sent to',
      'you have sent',
      'withdraw',
      'debited',
      'purchase of',
      'transfer of',
      'you have used', // MoMoAdvance / overdraft usage messages
      'paid to',
      'bought',
      // Kinyarwanda
      'wishyuye', // you have paid
      'wohereje', // you have sent
      'watanze', // you gave / paid out
      'wakuye', // you withdrew
      'wagurishije', // you bought
    ];

    if (incomingHints.any((h) => lower.contains(h))) {
      return TransactionType.income;
    }
    if (outgoingHints.any((h) => lower.contains(h))) {
      return TransactionType.expense;
    }
    // Default to expense — MoMo notifications are more often payments,
    // and it's safer for the user to review/correct a wrongly-flagged
    // expense than to have an income silently inflate their balance.
    return TransactionType.expense;
  }

  static String? _extractCounterparty(String body) {
    // Best-effort: capture a name after "from"/"to" — stops at the first
    // non-letter character (period, digit, parenthesis), so it grabs just
    // "MoMoAdvance" out of "from MoMoAdvance. Your available..." instead of
    // running on into the rest of the sentence.
    final fromMatch = RegExp(
      r'from\s+([A-Za-z]+(?:\s[A-Za-z]+){0,3})',
      caseSensitive: false,
    ).firstMatch(body);
    if (fromMatch != null) {
      return 'From ${fromMatch.group(1)!.trim()}';
    }

    final toMatch = RegExp(
      r'to\s+([A-Za-z]+(?:\s[A-Za-z]+){0,3})',
      caseSensitive: false,
    ).firstMatch(body);
    if (toMatch != null) {
      return 'To ${toMatch.group(1)!.trim()}';
    }

    return null;
  }
}
