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

  /// Promotional / service messages that mention money but describe no
  /// transaction. "Your pack has expired, buy another for 1,000 RWF" would
  /// otherwise be recorded as a 1,000 expense that never happened.
  static const List<String> _promoWords = [
    // English
    'expired', 'expires', 'offer', 'buy now', 'promo', 'promotion',
    'subscribe', 'renew', 'bundle expired', 'win ', 'congratulations',
    'click', 'download', 'sale', 'discount', 'advertis',
    // Invitations to buy/borrow again. A genuine receipt never asks you to
    // start another transaction — these were being recorded as real
    // payments ("To buy another one", "To borrow again").
    'buy another', 'to buy another', 'borrow again', 'to borrow',
    'you can borrow', 'apply for', 'get a loan', 'top up now',
    // Kinyarwanda
    'rangura', 'gura ', 'urangura', 'byarangiye', 'ongera', 'igurishwa',
    'kanda', 'andika', 'serivisi nshya', 'kwaka inguzanyo', 'saba inguzanyo',
    // NOTE: 'dial ' used to be here, but MTN appends a cross-sell footer —
    // "Dial *182*1*3# and send money abroad" — to plenty of REAL transaction
    // confirmations, not just adverts. That one word was silently dropping
    // genuine transfers, so it's gone; the other, more specific promo words
    // still catch actual adverts.
  ];

  /// True when the message is an advert or service notice rather than a
  /// record of money actually moving.
  ///
  /// This is an unconditional veto: unlike the old behaviour, a message
  /// containing any of these words is never recorded, even if it also
  /// happens to contain a long number or a balance. Adverts routinely carry
  /// both, which is exactly how "pack expired, buy another one" ended up in
  /// the transaction list.
  static bool looksPromotional(String body) {
    final lower = body.toLowerCase();
    return _promoWords.any(lower.contains);
  }

  /// Words indicating money moved between the user's OWN accounts (wallet to
  /// bank, bank to wallet) rather than to another person or merchant.
  static const List<String> _transferHints = [
    // English — deliberately only wording that names the user's OWN
    // account/wallet ("your", "own"), or the MoCash product name. Generic
    // phrases like "bank transfer" or "to bank account" were removed: those
    // also match ordinary bill/merchant payments (e.g. "payment of 5,000
    // RWF to bank account 12345 for school fees"), which wrongly turned a
    // real expense into a neutral Transfer.
    'to your bank', 'from your bank', 'to your account', 'from your account',
    'to your wallet', 'from your wallet', 'own account',
    // MTN Rwanda's actual product spelling is "Mokash" — keep both in case
    // wording varies, since "mocash" is the more commonly typed spelling
    // elsewhere but not what the real SMS says.
    'mocash', 'mo cash', 'mokash', 'mo kash',
    // Kinyarwanda — "yawe" means "your", so these are unambiguous about
    // whose account it is. Saving to / withdrawing from a sub-wallet like
    // MoCash is still the user's own money moving between their own
    // accounts.
    'kuri konti yawe', 'konti yawe ya banki', 'muri banki yawe',
    'kubika', 'kubitse', 'gukuramo', 'kubikuza',
  ];

  /// Words meaning a message is actually about a LOAN — borrowing or
  /// repaying — not an ordinary same-account save/withdraw. A loan genuinely
  /// changes what the user has or owes, so even a MoCash loan message (e.g.
  /// "inguzanyo") must still be recorded as income (received) or expense
  /// (repaid), unlike a plain MoCash deposit/withdrawal.
  static const List<String> _loanWords = ['loan', 'inguzanyo'];

  static bool _looksLikeLoan(String body) {
    final lower = body.toLowerCase();
    return _loanWords.any(lower.contains);
  }

  /// Weak hint that a message describes movement between the user's own
  /// accounts, based on wording alone.
  ///
  /// This is only a supplement. The RELIABLE detection happens after parsing,
  /// by pairing two messages that share an amount and counterparty within a
  /// few minutes but point in opposite directions — see
  /// `_classifyAgainstRecent` in sms_listener_service.dart. That approach
  /// needs no configuration, works for company names, and doesn't depend on
  /// the user's profile name matching their Mobile Money registration.
  static bool looksLikeOwnTransfer(String body) {
    final lower = body.toLowerCase();
    return _transferHints.any(lower.contains);
  }

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

    final officialTxId = _extractTransactionId(body);

    // Adverts are vetoed outright — see looksPromotional. This deliberately
    // runs BEFORE any "but it has a reference number" reasoning: promo texts
    // often contain long numbers, and treating those as proof of a real
    // transaction is what let "buy another one" adverts through.
    if (looksPromotional(body)) return null;

    // Money moved between the user's own accounts (including MoCash
    // save/withdraw) is a transfer, not a gain or a loss — see
    // TransactionType.transfer. A LOAN is the exception: borrowing or
    // repaying from MoCash really does change what the user has, so it's
    // recorded as income/expense like any other loan even though the
    // message also mentions "MoCash".
    final isTransfer = looksLikeOwnTransfer(body) && !_looksLikeLoan(body);
    final type =
        isTransfer ? TransactionType.transfer : _extractDirection(body);

    // A reference number is normally REQUIRED for income/expenses, because a
    // false one corrupts the balance and every chart. But some genuine
    // provider messages (again, MTN's "*165*S*" format) never include one at
    // all — only the transaction's own timestamp ("at 2026-08-25
    // 10:11:48"). When that's all we have, use it — combined with the
    // amount — as a synthetic reference. It's pulled straight from the SMS
    // text, so it comes out identical no matter which code path parses this
    // exact message, which is exactly what de-duplication needs.
    var txId = officialTxId;
    if (txId == null) {
      final messageTimestamp = _extractMessageTimestamp(body);
      if (messageTimestamp != null) {
        txId =
            'ts${messageTimestamp.millisecondsSinceEpoch}a${amount.toStringAsFixed(0)}';
      }
    }
    if (txId == null && !isTransfer) return null;

    // Transaction fees genuinely leave the account, so an expense of 1,000
    // with a 20 fee reduces the balance by 1,020. Counting only the headline
    // amount would make the tracked balance drift from the real one.
    // Fees are added to expenses; for incoming money the provider normally
    // states the net amount already, so nothing is added.
    final fee = _extractFee(body) ?? 0;
    // Transfers keep their face value — the money isn't lost, it moved. Any
    // fee on a transfer is handled separately (see [feeAsExpense] below),
    // because the fee IS a genuine loss even though the transfer isn't.
    final total = type == TransactionType.expense ? amount + fee : amount;

    // Prefer the provider's own sentence ("Your payment of 400 RWF to David
    // 1812139 was completed") over a bare "To David" — far easier to
    // recognise in history weeks later. Falls back to the short
    // counterparty form when no clean sentence can be pulled out.
    final counterparty = _extractCounterparty(body);
    var description = _extractSummarySentence(body) ??
        counterparty ??
        switch (type) {
          TransactionType.income => 'Mobile Money received',
          TransactionType.transfer => 'Transfer between accounts',
          TransactionType.expense => 'Mobile Money payment',
        };
    if (type == TransactionType.transfer) {
      description = 'Transfer: $description';
    }
    // If the message states what the money was for, show it — "To John —
    // School fees" is more useful on the history screen than "To John" alone.
    final note = _extractNote(body);
    if (note != null) {
      description = '$description — $note';
    }
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
      txId: txId,
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

    // 2. Fallback: a long digit run, EXCLUDING phone numbers. Messages often
    //    contain the counterparty's number (e.g. 250787461999), and picking
    //    that would give the two halves of one transfer different ids —
    //    defeating de-duplication.
    final runs = RegExp(r'[0-9]{9,}')
        .allMatches(body)
        .map((m) => m.group(0)!)
        .where((d) => !_looksLikePhoneNumber(d))
        .toList();
    if (runs.isNotEmpty) {
      runs.sort((a, b) => b.length.compareTo(a.length));
      return runs.first;
    }

    // 3. Fallback: an embedded provider timestamp, e.g.
    //    "...transferred to X (250789...) at 2026-08-25 10:11:48. Fee: ...".
    //    Some newer MTN message formats have no labelled reference at all —
    //    but they DO state the exact second the transaction happened, which
    //    is provider-generated and precise enough to use as a stable
    //    de-dup key, same role a TxId would normally play.
    final timestamp = RegExp(r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})')
        .firstMatch(body);
    if (timestamp != null) {
      return timestamp.group(1)!.replaceAll(RegExp(r'[:\s]'), '-');
    }

    return null;
  }

  /// Rwandan mobile numbers appear as 2507XXXXXXXX (12 digits) or
  /// 07XXXXXXXX (10 digits). Transaction references don't look like this.
  static bool _looksLikePhoneNumber(String digits) {
    if (digits.length == 12 && digits.startsWith('25')) return true;
    if (digits.length == 10 && digits.startsWith('07')) return true;
    if (digits.length == 9 && digits.startsWith('7')) return true;
    return false;
  }

  /// Pull the provider's own description of what happened out of the SMS,
  /// so history reads "Your payment of 400 RWF to David 1812139 was
  /// completed" instead of just "To David".
  ///
  /// Deliberately keeps only the human-readable clause: the routing prefix
  /// (`TxId:...*S*`, `*165*S*`), the trailing balance/fee/reference
  /// bookkeeping, and any "Dial ..." marketing footer are all stripped,
  /// since none of that helps the user recognise the transaction.
  static String? _extractSummarySentence(String body) {
    var s = body;

    // Routing/reference prefixes providers put before the real sentence.
    s = s.replaceAll(
        RegExp(r'^\s*\*?\d+\*[A-Za-z]\*', caseSensitive: false), '');
    s = s.replaceAll(
        RegExp(r'^\s*TxId\s*:?\s*\d+\s*\*[A-Za-z]\*', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r"^\s*Y'?ello[.,!]?\s*", caseSensitive: false), '');

    // Keep only the first sentence — the rest is balance/fee/marketing.
    final firstSentence = s.split(RegExp(r'(?<=[.!])\s+|\s*\.(?=[A-Z])')).first;
    s = firstSentence;

    // Trailing bookkeeping that adds no meaning for the user.
    s = s.replaceAll(
        RegExp(r'\s+at\s+\d{4}-\d{2}-\d{2}[\sT]\d{2}:\d{2}:\d{2}.*$',
            caseSensitive: false),
        '');
    s = s.replaceAll(
        RegExp(r'\s*(tariki|on)\s+\d{1,4}[/-]\d{1,2}[/-]\d{1,4}.*$',
            caseSensitive: false),
        '');
    s = s.replaceAll(RegExp(r'\s*\*EN#.*$', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'\s*Dial\s+\*.*$', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'\s*Ref\s*:?\s*\d+.*$', caseSensitive: false), '');

    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Strip dangling punctuation left behind by the removals above.
    s = s.replaceAll(RegExp(r'^[.,;:\-\s]+|[.,;:\-\s]+$'), '').trim();

    // Too short to be a real sentence, or so long it would be unreadable in
    // a list row — fall back to the simpler description in both cases.
    if (s.length < 12) return null;
    if (s.length > 110) s = '${s.substring(0, 107)}…';
    return s;
  }

  /// Pull the message's own stated date/time out of the text (e.g. "at
  /// 2026-08-25 10:11:48"). Used as a fallback reference when the provider's
  /// message has no separate transaction id at all.
  static DateTime? _extractMessageTimestamp(String body) {
    final match =
        RegExp(r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})').firstMatch(body);
    if (match == null) return null;
    return DateTime.tryParse(match.group(1)!.replaceFirst(' ', 'T'));
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
      'transferred from',
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
      'transferred to',
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
    // running on into the rest of the sentence. Allows up to 6 words and
    // apostrophes/hyphens so full names (e.g. "RUTEMBEZA Yves Marie",
    // "Jean-Paul") come through as-is instead of being cut short.
    final fromMatch = RegExp(
      r"from\s+([A-Za-z][A-Za-z'\-]*(?:\s[A-Za-z][A-Za-z'\-]*){0,5})",
      caseSensitive: false,
    ).firstMatch(body);
    if (fromMatch != null) {
      return 'From ${fromMatch.group(1)!.trim()}';
    }

    final toMatch = RegExp(
      r"to\s+([A-Za-z][A-Za-z'\-]*(?:\s[A-Za-z][A-Za-z'\-]*){0,5})",
      caseSensitive: false,
    ).firstMatch(body);
    if (toMatch != null) {
      return 'To ${toMatch.group(1)!.trim()}';
    }

    // Kinyarwanda equivalents — "kuva kuri X" / "bivuye kuri X" (from X),
    // "yoherejwe kuri X" / "kohereza kuri X" (to X). Multi-word phrases only
    // (never the bare preposition "kuri" alone), so this doesn't misfire on
    // unrelated wording like "kuri konti yawe" (to your own account).
    final fromKinyaMatch = RegExp(
      r"(?:kuva kuri|bivuye kuri|yavuye kuri)\s+([A-Za-z][A-Za-z'\-]*(?:\s[A-Za-z][A-Za-z'\-]*){0,5})",
      caseSensitive: false,
    ).firstMatch(body);
    if (fromKinyaMatch != null) {
      return 'From ${fromKinyaMatch.group(1)!.trim()}';
    }

    final toKinyaMatch = RegExp(
      r"(?:yoherejwe kuri|kohereza kuri|watanze kuri)\s+([A-Za-z][A-Za-z'\-]*(?:\s[A-Za-z][A-Za-z'\-]*){0,5})",
      caseSensitive: false,
    ).firstMatch(body);
    if (toKinyaMatch != null) {
      return 'To ${toKinyaMatch.group(1)!.trim()}';
    }

    return null;
  }

  /// Some providers/banks include a short free-text reason on the
  /// transaction (e.g. "Narration: School fees", "Reason: Rent"). When
  /// present, surface it so history shows what the money was for, not just
  /// who it was with. Best-effort — if nothing matches, the plain
  /// name-based description is left as-is rather than guessing.
  static String? _extractNote(String body) {
    final match = RegExp(
      r'(?:narration|reason|note|comment|memo)\s*[:#]?\s*([A-Za-z0-9 ,.\-]{3,40})',
      caseSensitive: false,
    ).firstMatch(body);
    final note = match?.group(1)?.trim();
    if (note == null || note.isEmpty) return null;
    return note;
  }
}
