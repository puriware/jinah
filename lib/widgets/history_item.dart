import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../models/expense.dart';
import '../widgets/expenses_group_list.dart';
import '../constants.dart';

class HistoryItem extends StatefulWidget {
  final List<Expense> expenses;
  const HistoryItem(this.expenses, {Key? key}) : super(key: key);

  @override
  _HistoryItemState createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  List<Expense> _expensesData = [];
  var _expanded = false;

  @override
  void initState() {
    super.initState();
    _expensesData = widget.expenses;
  }

  double totalExpenses() {
    var total = 0.0;
    _expensesData.forEach((element) {
      total += element.amount;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(large),
      ),
      margin: EdgeInsets.only(
        left: 10,
        top: 10,
        right: 10,
      ),
      elevation: medium,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(
                _expensesData.length.toString(),
              ),
            ),
            title: Text(
              DateFormat('MMMM yyyy').format(
                DateTime.parse(
                  _expensesData[0].trxDate!,
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Total ${currency.format(
              totalExpenses(),
            )}'),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded) ...[
            Divider(
              thickness: 1,
              indent: large,
              endIndent: large,
            ),
            Container(
              height: min(_expensesData.length * 100 + 20.0, 302),
              child: ExpensesGroupList(_expensesData),
            )
          ]
        ],
      ),
    );
  }
}
