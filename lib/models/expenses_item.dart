import 'package:flutter/material.dart';

class ExpensesItem {
  final String? id;
  final String? trxDate;
  final String? purpose;
  final double? amount;
  final String? userId;
  final DateTime? created;
  final DateTime? updated;

  ExpensesItem({
    @required this.id,
    @required this.trxDate,
    @required this.purpose,
    @required this.amount,
    @required this.userId,
    @required this.created,
    @required this.updated,
  });
}
