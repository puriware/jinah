import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/expense.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

class Expenses with ChangeNotifier {
  // final uuid = Uuid();
  List<Expense> _items = [];

  final String? authToken;
  final String? userId;

  Expenses(this._items, {this.authToken, this.userId});

  List<Expense> get items {
    return [..._items];
  }

  List<Expense> get todays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = _items
        .where(
          (item) => DateTime.parse(item.trxDate!).isAtSameMomentAs(today),
        )
        .toList();
    if (result.length > 0) {
      return result;
    } else {
      return [];
    }
  }

  double get expensesBeforeTodays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var result = thisMonth
        .where(
          (item) => DateTime.parse(item.trxDate!).isBefore(today),
        )
        .toList();
    var total = 0.0;
    result.forEach((exp) {
      total += exp.amount;
    });
    return total;
  }

  List<Expense> get thisMonth {
    return _items
        .where(
          (item) =>
              DateTime.parse(item.trxDate.toString()).month ==
              DateTime.now().month,
        )
        .toList();
  }

  List<Expense> get thisWeekExpenses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday;
    final startWeek = today.add(
      Duration(
        days: -weekday,
      ),
    );

    return [
      ..._items
          .where(
            (exp) =>
                exp.trxDate != null &&
                DateTime.parse(exp.trxDate!).isAfter(startWeek),
          )
          .toList()
    ];
  }

  List<Expense> get prevWeekExpenses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday;
    final startWeek = today.add(Duration(days: -(7 + weekday)));
    final endWeek = today.add(Duration(days: -weekday));
    return [
      ..._items
          .where(
            (vst) =>
                vst.trxDate != null &&
                DateTime.parse(vst.trxDate!).isAfter(startWeek) &&
                DateTime.parse(vst.trxDate!).isBefore(endWeek),
          )
          .toList()
    ];
  }

  double get thisWeekTotalExpenses {
    final amountList = thisWeekExpenses.map((e) => e.amount);
    var total = amountList.reduce((value, element) => value + element);
    return total;
  }

  double get thisMonthTotalExpenses {
    final amountList = thisMonth.map((e) => e.amount);
    var total = amountList.reduce((value, element) => value + element);
    return total;
  }

  double get prevWeekTotalExpenses {
    final amountList = prevWeekExpenses.map((e) => e.amount);
    var total = amountList.reduce((value, element) => value + element);
    return total;
  }

  double get todaysTotalExpenses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = _items
        .where(
          (exp) => exp.trxDate != null && DateTime.parse(exp.trxDate!) == today,
        )
        .toList();
    var total = 0.0;
    if (result.isNotEmpty) {
      final amountList = result.map((e) => e.amount);
      total = amountList.reduce((value, element) => value + element);
    }
    return total;
  }

  Future<void> fetchAndSetExpenses() async {
    try {
      await dotenv.load(fileName: ".env");
      final apiDB = dotenv.env['FIREBASE_DB'].toString();
      if (authToken != null) {
        var url = Uri.https(
          apiDB,
          '/expenses.json',
          {
            'auth': authToken,
            'orderBy': '"userId"',
            'equalTo': '"$userId"',
          },
        );
        final response = await http.get(url);
        if (response.body.isNotEmpty) {
          final extractedData =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (extractedData.isEmpty) {
            return null;
          }
          final List<Expense> loadedExpenses = [];
          extractedData.forEach((expensesID, expensesData) {
            loadedExpenses.add(
              Expense(
                id: expensesID,
                userId: expensesData['userId'],
                trxDate: expensesData['trxDate'],
                purpose: expensesData['purpose'],
                amount: expensesData['amount'],
                category: expensesData['category'],
                created: DateTime.parse(expensesData['created'].toString()),
                updated: DateTime.parse(expensesData['updated'].toString()),
              ),
            );
          });
          _items = loadedExpenses;
          notifyListeners();
        }
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> addExpense(Expense expense) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/expenses.json',
      {'auth': authToken},
    );
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'userId': userId,
            'trxDate': expense.trxDate,
            'purpose': expense.purpose,
            'amount': expense.amount,
            'category': expense.category,
            'created': expense.created != null
                ? expense.created!.toIso8601String()
                : DateTime.now().toIso8601String(),
            'updated': expense.updated != null
                ? expense.updated!.toIso8601String()
                : DateTime.now().toIso8601String(),
          },
        ),
      );
      final res = jsonDecode(response.body);
      final newExpense = Expense(
        id: res['name'],
        userId: expense.userId,
        trxDate: expense.trxDate,
        purpose: expense.purpose,
        amount: expense.amount,
        category: expense.category,
        created: expense.created != null ? expense.created! : DateTime.now(),
        updated: expense.updated != null ? expense.updated! : DateTime.now(),
      );
      _items.add(newExpense);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateExpense(Expense newExpense) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final prodIndex = _items.indexWhere((prod) => prod.id == newExpense.id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        apiDB,
        '/expenses/${newExpense.id}.json',
        {'auth': authToken},
      );
      try {
        await http.patch(
          url,
          body: jsonEncode(
            {
              'trxDate': newExpense.trxDate,
              'purpose': newExpense.purpose,
              'amount': newExpense.amount,
              'category': newExpense.category,
              'updated': DateTime.now().toIso8601String(),
            },
          ),
        );
        _items[prodIndex] = newExpense;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteExpense(String id) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/expenses/$id.json',
      {'auth': authToken},
    );
    final existingExpenseIndex = _items.indexWhere((prod) => prod.id == id);
    var existingExpense = _items[existingExpenseIndex];
    _items.removeAt(existingExpenseIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(
        existingExpenseIndex,
        existingExpense,
      );
      notifyListeners();
      throw HttpException('Could not delete Expense.');
    }
    //existingExpense = null;
  }

  Expense findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
