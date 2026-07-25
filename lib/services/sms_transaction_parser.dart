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

  ParsedSmsTransaction({
    required this.type,
    required this.amount,
    required this.description,
    required this.account,
    required this.detectedAt,
    required this.rawSnippet,
    required this.messageBody,
    this.txId,
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
  static bool looksLikeMomoMessage(String sender, String body) {
    final normalizedSender = sender.toLowerCase();
    final normalizedBody = body.toLowerCase();

    final trustedSenderHints = [
      'mtn',
      'momo',
      'm-money',
      'airtel',
      'mobile money',
      'bk',
      'bank of kigali',
    ];
    final senderLooksTrusted =
        trustedSenderHints.any((hint) => normalizedSender.contains(hint));

    final bodyLooksFinancial = (normalizedBody.contains('rwf') ||
            normalizedBody.contains('frw')) &&
        (normalizedBody.contains('balance') ||
            normalizedBody.contains('transaction') ||
            normalizedBody.contains('txid') ||
            normalizedBody.contains('tx id') ||
            normalizedBody.contains('received') ||
            normalizedBody.contains('payment') ||
            normalizedBody.contains('paid') ||
            normalizedBody.contains('completed'));

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
    final description = _extractCounterparty(body) ??
        (type == TransactionType.income
            ? 'Mobile Money received'
            : 'Mobile Money payment');

    // Preview only the first ~80 chars for the confirmation UI — enough
    // context for the user to recognize it, without dumping the whole SMS.
    final snippet = body.length > 80 ? '${body.substring(0, 80)}…' : body;

    return ParsedSmsTransaction(
      type: type,
      amount: amount,
      description: description,
      account: AccountType.mobileMoney,
      detectedAt: receivedAt ?? DateTime.now(),
      rawSnippet: snippet,
      messageBody: body,
      txId: _extractTransactionId(body),
    );
  }

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
    // Matches "12,500 RWF", "RWF 12,500", "Frw12500", "12500.00 FRW", etc.
    final patterns = [
      RegExp(r'(?:RWF|FRW|Frw)\s?([\d,]+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'([\d,]+(?:\.\d+)?)\s?(?:RWF|FRW|Frw)', caseSensitive: false),
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
    const incomingHints = [
      'you have received',
      'received from',
      'deposit',
      'credited',
      'has been credited',
    ];
    const outgoingHints = [
      'you have paid',
      'payment of',
      'sent to',
      'withdraw',
      'debited',
      'purchase of',
      'transfer of',
      'you have used', // e.g. MoMoAdvance/overdraft usage messages
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
