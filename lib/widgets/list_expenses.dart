import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/expenses_item.dart';
import '../../providers/categories.dart';
import '../../providers/expenses.dart';
import '../../widgets/message_dialog.dart';
import '../../widgets/new_expenses.dart';

class ListExpenses extends StatelessWidget {
  final currency = NumberFormat("#,##0.00", "en_US");
  final List<ExpensesItem> dataExpenses;
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
              ListTile(
                title: Text(
                  Provider.of<Categories>(context, listen: false).categoryName(
                    expense.category.toString(),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: large,
                  ),
                ),
                subtitle: Text(expense.purpose.toString()),
                leading: CircleAvatar(
                  // Theme.of(context).accentColor,
                  radius: 30,
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: FittedBox(
                      child: Text(
                        (idx + 1).toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                trailing: Text(
                  'Rp ${currency.format(expense.amount!)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: large,
                    color: Colors.red,
                  ),
                ),
                onLongPress: () {
                  MessageDialog.showMessageDialog(
                    context,
                    'Delete Expenses',
                    'Are you sure to delete Expenses data?',
                    'Delete',
                    () async {
                      try {
                        await Provider.of<Expenses>(context, listen: false)
                            .deleteExpensesItem(expense.id!);
                      } catch (error) {
                        MessageDialog.showPopUpMessage(
                          context,
                          'Delete Expenses',
                          'Failed to delete data expenses!',
                        );
                      }
                    },
                  );
                },
                onTap: () {
                  MessageDialog.showMessageDialog(
                    context,
                    'Edit Expenses',
                    'Are you sure to edit Expenses data?',
                    'Yes',
                    () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        context: ctx,
                        builder: (_) {
                          return GestureDetector(
                            onTap: () {},
                            child: NewExpenses(
                              expensesId: expense.id,
                            ),
                            behavior: HitTestBehavior.opaque,
                          );
                        },
                      );
                    },
                  );
                },
              ),
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
