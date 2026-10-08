import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../models/currency.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';

class ExportService {
  /// Income / Expense / Transfer in the export's language.
  static String _typeLabel(AppLocalizations l, TransactionType t) {
    switch (t) {
      case TransactionType.income:
        return l.income;
      case TransactionType.expense:
        return l.expense;
      case TransactionType.transfer:
        return l.transfer;
    }
  }

  /// Export transactions to CSV
  static Future<void> exportToCSV(
    List<Transaction> transactions, {
    AppCurrency currency = AppCurrency.rwf,
    required AppLocalizations l,
  }) async {
    try {
      final StringBuffer csv = StringBuffer();

      // CSV Header
      csv.writeln(l.csvHeader(currency.code));
      
      // CSV Data
      final dateFormatter = DateFormat('yyyy-MM-dd');
      for (var transaction in transactions) {
        csv.writeln(
          '${dateFormatter.format(transaction.date)},'
          '${_typeLabel(l, transaction.type)},'
          '${categoryLabelFor(l, transaction.category)},'
          '"${displayDescriptionFor(l, transaction.description)}",'
          '${transaction.amount.toStringAsFixed(2)}',
        );
      }
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/finwise_transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv.toString());
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l.exportSubject,
        text: l.exportText,
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Export transactions to PDF (simplified text format)
  static Future<void> exportToPDF(
    List<Transaction> transactions, {
    AppCurrency currency = AppCurrency.rwf,
    required AppLocalizations l,
  }) async {
    try {
      final StringBuffer pdf = StringBuffer();
      final currencySuffix = currency.symbol;

      // PDF Header
      pdf.writeln(l.reportTitle);
      pdf.writeln(l.reportGenerated(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())));
      pdf.writeln('=' * 50);
      pdf.writeln('');

      // Summary
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      pdf.writeln(l.reportSummary);
      pdf.writeln(l.reportTotalIncome('${NumberFormat('#,###').format(income)} $currencySuffix'));
      pdf.writeln(l.reportTotalExpenses('${NumberFormat('#,###').format(expenses)} $currencySuffix'));
      pdf.writeln(l.reportBalance('${NumberFormat('#,###').format(income - expenses)} $currencySuffix'));
      pdf.writeln('');
      pdf.writeln('=' * 50);
      pdf.writeln('');

      // Transactions
      pdf.writeln(l.reportTransactions);
      pdf.writeln('');

      final dateFormatter = DateFormat('yyyy-MM-dd');
      final formatter = NumberFormat('#,###');

      for (var transaction in transactions) {
        pdf.writeln(l.reportDate(dateFormatter.format(transaction.date)));
        pdf.writeln(l.reportType(_typeLabel(l, transaction.type).toUpperCase()));
        pdf.writeln(l.reportCategory(categoryLabelFor(l, transaction.category)));
        pdf.writeln(l.reportDescription(displayDescriptionFor(l, transaction.description)));
        pdf.writeln(l.reportAmount('${formatter.format(transaction.amount)} $currencySuffix'));
        pdf.writeln('-' * 30);
      }
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/finwise_report_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(pdf.toString());
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l.reportSubject,
        text: l.reportText,
      );
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }
}
