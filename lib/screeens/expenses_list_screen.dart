import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expenses_item.dart';
import '../providers/expenses.dart';
import '../widgets/data_item.dart';

class ExpensesListScreen extends StatelessWidget {
  static const routeName = '/expenses';
  const ExpensesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ExpensesItem> _todays = Provider.of<Expenses>(
      context,
    ).todays;

    return ListView.builder(
      itemBuilder: (ctx, idx) {
        var expense = _todays[idx];
        return Column(
          children: [
            DataItem(
              expense.id.toString(),
              expense.purpose.toString(),
              expense.amount!,
              idx,
            ),
            if (idx < _todays.length - 1)
              Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
          ],
        );
      },
      itemCount: _todays.length,
    );
  }
}
