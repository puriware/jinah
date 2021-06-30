import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:puri_expenses/models/expenses_item.dart';
import 'package:puri_expenses/widgets/data_item.dart';

class SummaryItem extends StatefulWidget {
  final currency = NumberFormat("#,##0.00", "en_US");
  final String date;
  final double total;
  final List<ExpensesItem> expenses;
  SummaryItem(this.date, this.total, this.expenses, {Key? key})
      : super(key: key);

  @override
  _SummaryItemState createState() => _SummaryItemState();
}

class _SummaryItemState extends State<SummaryItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        left: 10,
        top: 10,
        right: 10,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Rp ${widget.currency.format(widget.total)}'),
            subtitle: Text(
              widget.date,
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              height: min(widget.expenses.length * 20 + 20.0, 100),
              child: ListView.builder(
                itemBuilder: (ctx, idx) {
                  var expense = widget.expenses[idx];
                  return Column(
                    children: [
                      DataItem(
                        expense.id.toString(),
                        expense.purpose.toString(),
                        expense.amount!,
                        idx,
                      ),
                      if (idx < widget.expenses.length - 1)
                        Divider(
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                    ],
                  );
                },
                itemCount: widget.expenses.length,
              ),
            )
        ],
      ),
    );
  }
}
