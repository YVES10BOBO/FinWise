import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/sms_transaction_parser.dart';

/// Debug tool: paste a real (or sample) Mobile Money SMS and see exactly
/// what the parser extracts, without needing to wait for a live message.
/// Use this to tune the regex patterns in sms_transaction_parser.dart
/// against your own carrier's real wording.
class SmsParserTestScreen extends StatefulWidget {
  const SmsParserTestScreen({super.key});

  @override
  State<SmsParserTestScreen> createState() => _SmsParserTestScreenState();
}

class _SmsParserTestScreenState extends State<SmsParserTestScreen> {
  final _senderController = TextEditingController(text: 'M-Money');
  final _bodyController = TextEditingController();
  ParsedSmsTransaction? _result;
  bool _tried = false;

  @override
  void dispose() {
    _senderController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _runParser() {
    setState(() {
      _tried = true;
      _result = SmsTransactionParser.parse(
        _senderController.text,
        _bodyController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test SMS Parser')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Paste a real Mobile Money SMS below (amounts are fine to '
              'leave as-is, this never leaves your phone) and see what '
              'FinWise would detect from it.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender / short code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'SMS body',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _runParser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Parse'),
            ),
            const SizedBox(height: 24),
            if (_tried) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final result = _result;
    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Not recognized as a Mobile Money transaction. If this is a real '
          'MoMo message, the wording likely differs from the patterns in '
          'sms_transaction_parser.dart — share this text so the regex can '
          'be tuned to match.',
          style: TextStyle(color: AppTheme.expenseColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.incomeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${result.type.name}'),
          Text('Amount: ${result.amount}'),
          Text('Description: ${result.description}'),
          Text('Account: ${result.account.name}'),
        ],
      ),
    );
  }
}
