import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class ExportService {
  /// Export transactions to CSV
  static Future<void> exportToCSV(List<Transaction> transactions) async {
    try {
      final StringBuffer csv = StringBuffer();
      
      // CSV Header
      csv.writeln('Date,Type,Category,Description,Amount (RWF)');
      
      // CSV Data
      final dateFormatter = DateFormat('yyyy-MM-dd');
      for (var transaction in transactions) {
        csv.writeln(
          '${dateFormatter.format(transaction.date)},'
          '${transaction.type.name},'
          '${transaction.category.name},'
          '"${transaction.description}",'
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
        subject: 'FinWise Transactions Export',
        text: 'Your FinWise transaction export',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Export transactions to PDF (simplified text format)
  static Future<void> exportToPDF(List<Transaction> transactions) async {
    try {
      final StringBuffer pdf = StringBuffer();
      
      // PDF Header
      pdf.writeln('FINWISE TRANSACTION REPORT');
      pdf.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
      pdf.writeln('=' * 50);
      pdf.writeln('');
      
      // Summary
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      pdf.writeln('SUMMARY');
      pdf.writeln('Total Income: ${NumberFormat('#,###').format(income)} RWF');
      pdf.writeln('Total Expenses: ${NumberFormat('#,###').format(expenses)} RWF');
      pdf.writeln('Balance: ${NumberFormat('#,###').format(income - expenses)} RWF');
      pdf.writeln('');
      pdf.writeln('=' * 50);
      pdf.writeln('');
      
      // Transactions
      pdf.writeln('TRANSACTIONS');
      pdf.writeln('');
      
      final dateFormatter = DateFormat('yyyy-MM-dd');
      final formatter = NumberFormat('#,###');
      
      for (var transaction in transactions) {
        pdf.writeln('Date: ${dateFormatter.format(transaction.date)}');
        pdf.writeln('Type: ${transaction.type.name.toUpperCase()}');
        pdf.writeln('Category: ${transaction.category.name}');
        pdf.writeln('Description: ${transaction.description}');
        pdf.writeln('Amount: ${formatter.format(transaction.amount)} RWF');
        pdf.writeln('-' * 30);
      }
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/finwise_report_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(pdf.toString());
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'FinWise Transaction Report',
        text: 'Your FinWise transaction report',
      );
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }
}
