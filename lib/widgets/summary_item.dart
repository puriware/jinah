import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';

import '../models/expense.dart';
import '../../providers/categories.dart';

class SummaryItem extends StatelessWidget {
  final currency = NumberFormat("#,##0.00", "en_US");
  final DateTime date;
  final double total;
  final List<Expense> expenses;
  SummaryItem(this.date, this.total, this.expenses, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var num = 1;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: FittedBox(
                child: Text(
                  DateFormat('dd').format(this.date),
                ),
              ),
            ),
            title: Text(DateFormat('EEEE').format(this.date)),
            subtitle: Text(
              DateFormat('MMMM yyyy').format(this.date),
            ),
            trailing: Text('Rp ${this.currency.format(this.total)}'),
          ),
          Divider(),
          ListView(
            children: [
              ...expenses
                  .map(
                    (expense) => ListTile(
                      title: Text(
                        Provider.of<Categories>(context, listen: false)
                            .categoryName(
                          expense.category.toString(),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: large,
                        ),
                      ),
                      subtitle: Text(expense.purpose.toString()),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 30,
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: FittedBox(
                            child: Text(
                              (num).toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      trailing: Text(
                        'Rp ${currency.format(expense.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: large,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
          // ListView.builder(
          //   itemBuilder: (ctx, idx) {
          //     var expense = expenses[idx];
          //     return ListTile(
          //       title: Text(
          //         Provider.of<Categories>(context, listen: false)
          //             .categoryName(
          //           expense.category.toString(),
          //         ),
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: large,
          //         ),
          //       ),
          //       subtitle: Text(expense.purpose.toString()),
          //       leading: CircleAvatar(
          //         // Theme.of(context).accentColor,
          //         radius: 30,
          //         child: Padding(
          //           padding: EdgeInsets.all(2),
          //           child: FittedBox(
          //             child: Text(
          //               (idx + 1).toString(),
          //               style: TextStyle(color: Colors.white),
          //             ),
          //           ),
          //         ),
          //       ),
          //       trailing: Text(
          //         'Rp ${currency.format(expense.amount!)}',
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: large,
          //           color: Colors.red,
          //         ),
          //       ),
          //     );
          //   },
          //   itemCount: expenses.length,
          // ),
        ],
      ),
    );
  }
}
