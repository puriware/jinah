import 'package:flutter/material.dart';
import 'package:puri_expenses/models/category_item.dart';

class ExpensesItem {
  final String? id;
  final String? userId;
  final String? trxDate;
  final String? purpose;
  final double? amount;
  final String? category;
  final DateTime? created;
  final DateTime? updated;

  ExpensesItem({
    @required this.id,
    @required this.userId,
    @required this.trxDate,
    @required this.purpose,
    @required this.amount,
    @required this.category,
    @required this.created,
    @required this.updated,
  });
}
