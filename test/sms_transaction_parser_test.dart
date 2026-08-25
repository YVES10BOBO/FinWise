import 'package:flutter_test/flutter_test.dart';
import 'package:finewise/models/transaction.dart';
import 'package:finewise/services/sms_transaction_parser.dart';

/// Regression tests for SMS parsing, built from REAL messages seen on a
/// Rwandan MTN line. Every case here corresponds to a bug that actually
/// shipped at some point — a promo recorded as a payment, a real payment
/// thrown away as promo, a Mokash transfer counted as an expense.
///
/// When a provider changes wording, add the new message here FIRST, watch
/// the test fail, then fix the parser. That's much cheaper than discovering
/// it from a wrong balance on a phone.
void main() {
  const sender = 'M-Money';

  group('real payments are recorded as expenses', () {
    test('MTN send-money format with no transaction id', () {
      // No "Financial Transaction Id" anywhere — only the embedded
      // timestamp. Must still be recorded, and the fee added on top.
      final parsed = SmsTransactionParser.parse(
        sender,
        '*165*S*200 RWF transferred to Marie Chantal MUKANDENGEYINGOMA '
        '(250789196718) at 2026-08-25 10:11:48 .Fee: 20RWF.Balance: '
        '4692RWF.Dial *182*1*3# and send money abroad *EN#',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.expense);
      expect(parsed.amount, 220); // 200 + 20 fee
      expect(parsed.fee, 20);
      expect(parsed.txId, isNotNull); // synthetic, from the timestamp
      expect(parsed.description, contains('Marie Chantal'));
      // Bookkeeping/marketing must not leak into the description.
      expect(parsed.description, isNot(contains('Balance')));
      expect(parsed.description, isNot(contains('Dial')));
      expect(parsed.description, isNot(contains('*EN#')));
    });

    test('payment with a TxId prefix keeps the provider sentence', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        'TxId:30101164199*S*Your payment of 400 RWF to David 1812139 was '
        'completed at 2026-08-25 10:29:20.  Balance: 4,292 RWF. Fee 0 '
        'RWF.*EN#',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.expense);
      expect(parsed.amount, 400);
      expect(parsed.txId, '30101164199');
      expect(parsed.description, contains('David'));
      expect(parsed.description, contains('payment'));
    });

    test('a masked phone number is never mistaken for a transaction id', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        '*165*S*2000 RWF transferred to Yves RUTEMBEZA (250787461999) at '
        '2026-08-24 18:26:52 .Fee: 0RWF.Balance: 0RWF.*EN#',
      );

      expect(parsed, isNotNull);
      expect(parsed!.txId, isNot(contains('250787461999')));
    });
  });

  group('promotional messages are ignored', () {
    test('pack-expired advert is not recorded', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        'Your 500Frw pack expired yesterday. Dial *255# to Buy another one. '
        'To stop this message, please dial *389#.',
      );

      expect(parsed, isNull);
    });

    test('a real transaction is NOT discarded just for a marketing footer',
        () {
      // The "Dial *182..." footer alone must not veto a genuine payment.
      final parsed = SmsTransactionParser.parse(
        sender,
        '*165*S*500 RWF transferred to Jean Bosco (250788123456) at '
        '2026-08-25 09:00:00 .Fee: 0RWF.Balance: 1000RWF.Dial *182*1*3# and '
        'send money abroad *EN#',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.expense);
    });
  });

  group('own-account movement is a neutral transfer', () {
    test('Kinyarwanda Mokash message (note the k spelling)', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        "Y'ello. Umaze kohereza RWF 4900 kuva kuri konti Mokash tariki "
        '19/08/2026 saa 2:18 PM. Mokash ifiteho amafaranga RWF 43. '
        'Ref 29971903286',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.transfer);
      expect(parsed.amount, 4900);
    });

    test('explicit "your account" wording', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        'You have transferred 5000 RWF to your bank account. '
        'Financial Transaction Id: 12345678901. Balance: 200 RWF.',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.transfer);
    });

    test('a Mokash LOAN is still income, not a transfer', () {
      // Borrowing genuinely changes what the user has, so the blanket
      // "Mokash means transfer" rule must not swallow it.
      final parsed = SmsTransactionParser.parse(
        sender,
        "Y'ello. Wahawe inguzanyo ya RWF 10000 kuri konti yawe ya Mokash. "
        'Ref 29971903999',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, isNot(TransactionType.transfer));
    });
  });

  group('incoming money', () {
    test('English received message is income', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        'You have received 3000 RWF from Alice UWASE (250788000111). '
        'Financial Transaction Id: 98765432101. Your new balance: 8000 RWF.',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.income);
      expect(parsed.amount, 3000);
      expect(parsed.description, contains('Alice'));
    });

    test('Kinyarwanda received message is income, not the expense default',
        () {
      final parsed = SmsTransactionParser.parse(
        sender,
        "Y'ello. Wakiriye amafaranga RWF 1500 kuva kuri Alice UWASE. "
        'Ref 29971904111',
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, TransactionType.income);
      expect(parsed.amount, 1500);
    });
  });

  group('non-financial messages', () {
    test('a personal SMS is ignored', () {
      final parsed = SmsTransactionParser.parse(
        '+250788000000',
        'Hey, are we still meeting at 5?',
      );

      expect(parsed, isNull);
    });

    test('a financial-looking message with no amount is ignored', () {
      final parsed = SmsTransactionParser.parse(
        sender,
        'Your transaction could not be completed. Please try again.',
      );

      expect(parsed, isNull);
    });
  });

  group('de-duplication identity', () {
    test('the same message always yields the same id', () {
      const body =
          '*165*S*200 RWF transferred to Marie Chantal MUKANDENGEYINGOMA '
          '(250789196718) at 2026-08-25 10:11:48 .Fee: 20RWF.Balance: '
          '4692RWF.*EN#';

      final first = SmsTransactionParser.parse(sender, body);
      final second = SmsTransactionParser.parse(sender, body);

      expect(first!.txId, second!.txId);
    });

    test('different transactions yield different ids', () {
      final a = SmsTransactionParser.parse(
        sender,
        '*165*S*200 RWF transferred to Marie (250789196718) at '
        '2026-08-25 10:11:48 .Fee: 0RWF.Balance: 100RWF.*EN#',
      );
      final b = SmsTransactionParser.parse(
        sender,
        '*165*S*300 RWF transferred to Marie (250789196718) at '
        '2026-08-25 11:11:48 .Fee: 0RWF.Balance: 100RWF.*EN#',
      );

      expect(a!.txId, isNot(b!.txId));
    });
  });
}
