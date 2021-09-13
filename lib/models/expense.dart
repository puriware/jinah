import 'package:flutter/material.dart';

class Expense {
  final String? id;
  final String? userId;
  final String? trxDate;
  final String? purpose;
  final double amount;
  final String? category;
  final DateTime? created;
  final DateTime? updated;

  Expense({
    @required this.id,
    @required this.userId,
    @required this.trxDate,
    @required this.purpose,
    this.amount = 0.0,
    @required this.category,
    @required this.created,
    @required this.updated,
  });
}
