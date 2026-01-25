import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _loadTransactions();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  // Load transactions from local storage
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString('transactions');
      
      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions = decoded.map((json) => Transaction.fromJson(json)).toList();
        // Sort by date (newest first)
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save transactions to local storage
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString('transactions', transactionsJson);
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _saveTransactions();
    notifyListeners();
  }

  void updateTransaction(Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _saveTransactions();
      notifyListeners();
    }
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveTransactions();
    notifyListeners();
  }

  List<Transaction> getRecentTransactions(int count) {
    return _transactions.take(count).toList();
  }

  List<Transaction> getTransactionsByCategory(dynamic category) {
    return _transactions.where((t) {
      return t.category.name == category.name;
    }).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;
    
    final lowerQuery = query.toLowerCase();
    return _transactions.where((t) {
      return t.description.toLowerCase().contains(lowerQuery) ||
          t.category.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
