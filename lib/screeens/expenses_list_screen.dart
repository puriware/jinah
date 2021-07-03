import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/constants.dart';
import 'package:puri_expenses/providers/categories.dart';
import 'package:puri_expenses/providers/user_active.dart';
import 'package:puri_expenses/screeens/edit_user_screen.dart';
import 'package:puri_expenses/widgets/message_dialog.dart';
import 'package:puri_expenses/widgets/new_expenses.dart';
import 'package:puri_expenses/widgets/summary.dart';
import '../models/expenses_item.dart';
import '../providers/expenses.dart';

class ExpensesListScreen extends StatelessWidget {
  final currency = NumberFormat("#,##0.00", "en_US");
  static const routeName = '/expenses';
  ExpensesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ExpensesItem> _todays = Provider.of<Expenses>(
      context,
    ).todays;

    final limit = Provider.of<UserActive>(context).userActive!.limit;
    final beforeTodays = Provider.of<Expenses>(context).expensesBeforeTodays;
    final todayExpenses = Provider.of<Expenses>(context).todayExpenses;
    final limitLeft = limit != null
        ? limit - (beforeTodays + todayExpenses)
        : beforeTodays + todayExpenses;

    return Container(
      margin: EdgeInsets.all(medium),
      child: Column(
        children: [
          Card(
            elevation: 5,
            child: Column(
              children: [
                SizedBox(
                  height: medium,
                ),
                Text(
                  DateFormat('EEEE - dd MMMM yyyy').format(
                    DateTime.now(),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                Divider(
                  indent: large,
                  endIndent: large,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Summary(
                      'Before',
                      limit != null
                          ? '${(beforeTodays / limit * 100).toStringAsFixed(2)}%'
                          : '%',
                      'Rp ${currency.format(beforeTodays)}',
                      Colors.orange,
                    ),
                    Summary(
                      'Today',
                      limit != null
                          ? '${(todayExpenses / limit * 100).toStringAsFixed(2)}%'
                          : '%',
                      'Rp ${currency.format(todayExpenses)}',
                      Colors.red,
                    ),
                    Summary(
                      'Left',
                      limit != null
                          ? '${(limitLeft / limit * 100).toStringAsFixed(2)}%'
                          : '%',
                      'Rp ${currency.format(limitLeft)}',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  itemBuilder: (ctx, idx) {
                    var expense = _todays[idx];
                    return Column(
                      children: [
                        ListTile(
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
                                  await Provider.of<Expenses>(context,
                                          listen: false)
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
