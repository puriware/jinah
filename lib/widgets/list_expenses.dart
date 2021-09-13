import 'package:flutter/material.dart';
import 'package:puri_expenses/widgets/expenses_item.dart';
import '../models/expense.dart';

class ListExpenses extends StatelessWidget {
  final List<Expense> dataExpenses;
  ListExpenses(this.dataExpenses, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListView.builder(
        itemBuilder: (ctx, idx) {
          var expense = dataExpenses[idx];
          return Column(
            children: [
              ExpensesItem(expense, idx + 1),
              if (idx < dataExpenses.length - 1)
                Divider(
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
            ],
          );
        },
        itemCount: dataExpenses.length,
      ),
    );
  }
}
