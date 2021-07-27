import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/expenses_item.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

class Expenses with ChangeNotifier {
  // final uuid = Uuid();
  List<ExpensesItem> _items = [];

  final String? authToken;
  final String? userId;

  Expenses(this._items, {this.authToken, this.userId});

  List<ExpensesItem> get items {
    return [..._items];
  }

  List<ExpensesItem> get todays {
    final result = _items
        .where(
          (item) =>
              item.trxDate.toString() ==
              DateFormat('yyyy-MM-dd').format(
                DateTime.now(),
              ),
        )
        .toList();
    if (result.length > 0) {
      return result;
    } else {
      return [];
    }
  }

  double get expensesBeforeTodays {
    var result = thisMonth
        .where(
          (item) =>
              int.parse(
                DateFormat('D').format(
                  DateTime.parse(
                    item.trxDate.toString(),
                  ),
                ),
              ) <
              int.parse(
                DateFormat('D').format(
                  DateTime.now(),
                ),
              ),
        )
        .toList();
    var total = 0.0;
    result.forEach((exp) {
      total += exp.amount!;
    });
    return total;
  }

  double get todayExpenses {
    var result = todays
        .where(
          (item) =>
              int.parse(
                DateFormat('D').format(
                  DateTime.parse(
                    item.trxDate.toString(),
                  ),
                ),
              ) ==
              int.parse(
                DateFormat('D').format(
                  DateTime.now(),
                ),
              ),
        )
        .toList();
    var total = 0.0;
    result.forEach((exp) {
      total += exp.amount!;
    });
    return total;
  }

  List<ExpensesItem> get thisMonth {
    return _items
        .where(
          (item) =>
              DateTime.parse(item.trxDate.toString()).month ==
              DateTime.now().month,
        )
        .toList();
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
          final List<ExpensesItem> loadedExpenses = [];
          extractedData.forEach((expensesID, expensesData) {
            loadedExpenses.add(
              ExpensesItem(
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

  Future<void> addExpensesItem(ExpensesItem expensesItem) async {
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
            'trxDate': expensesItem.trxDate,
            'purpose': expensesItem.purpose,
            'amount': expensesItem.amount,
            'category': expensesItem.category,
            'created': expensesItem.created != null
                ? expensesItem.created!.toIso8601String()
                : DateTime.now().toIso8601String(),
            'updated': expensesItem.updated != null
                ? expensesItem.updated!.toIso8601String()
                : DateTime.now().toIso8601String(),
          },
        ),
      );
      final res = jsonDecode(response.body);
      final newExpensesItem = ExpensesItem(
        id: res['name'],
        userId: expensesItem.userId,
        trxDate: expensesItem.trxDate,
        purpose: expensesItem.purpose,
        amount: expensesItem.amount,
        category: expensesItem.category,
        created: expensesItem.created != null
            ? expensesItem.created!
            : DateTime.now(),
        updated: expensesItem.updated != null
            ? expensesItem.updated!
            : DateTime.now(),
      );
      _items.add(newExpensesItem);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateExpensesItem(ExpensesItem newExpensesItem) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final prodIndex =
        _items.indexWhere((prod) => prod.id == newExpensesItem.id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        apiDB,
        '/expenses/${newExpensesItem.id}.json',
        {'auth': authToken},
      );
      try {
        await http.patch(
          url,
          body: jsonEncode(
            {
              'trxDate': newExpensesItem.trxDate,
              'purpose': newExpensesItem.purpose,
              'amount': newExpensesItem.amount,
              'category': newExpensesItem.category,
              'updated': DateTime.now().toIso8601String(),
            },
          ),
        );
        _items[prodIndex] = newExpensesItem;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteExpensesItem(String id) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/expenses/$id.json',
      {'auth': authToken},
    );
    final existingExpensesItemIndex =
        _items.indexWhere((prod) => prod.id == id);
    var existingExpensesItem = _items[existingExpensesItemIndex];
    _items.removeAt(existingExpensesItemIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(
        existingExpensesItemIndex,
        existingExpensesItem,
      );
      notifyListeners();
      throw HttpException('Could not delete ExpensesItem.');
    }
    //existingExpensesItem = null;
  }

  ExpensesItem findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
