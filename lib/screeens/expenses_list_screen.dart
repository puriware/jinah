import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/providers/categories.dart';
import 'package:puri_expenses/widgets/message_dialog.dart';
import 'package:puri_expenses/widgets/new_expenses.dart';
import '../../constants.dart';
import '../../providers/user_active.dart';
import '../../widgets/daily_summary.dart';
import '../models/expenses_item.dart';
import '../providers/expenses.dart';

class ExpensesListScreen extends StatelessWidget {
  final currency = NumberFormat("#,##0.00", "en_US");
  static const routeName = '/expenses';
  ExpensesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List<ExpensesItem> _todays = Provider.of<Expenses>(
    //   context,
    // ).todays;
    final _expensesData = Provider.of<Expenses>(
      context,
    ).thisMonth;

    final activeUser = Provider.of<UserActive>(context).userActive;
    final limit =
        activeUser != null && activeUser.limit != null ? activeUser.limit : 0.0;
    final beforeTodays = Provider.of<Expenses>(context).expensesBeforeTodays;
    final todayExpenses = Provider.of<Expenses>(context).todayExpenses;
    final limitLeft = limit != null
        ? limit - (beforeTodays + todayExpenses)
        : beforeTodays + todayExpenses;

    return Container(
      margin: EdgeInsets.all(medium),
      child: Column(
        children: [
          DailySummary(
            limit: limit,
            beforeTodays: beforeTodays,
            currency: currency,
            todayExpenses: todayExpenses,
            limitLeft: limitLeft,
          ),
          Expanded(
            child: Card(
              child: //ListExpenses(_todays),
                  GroupedListView<ExpensesItem, String>(
                elements: _expensesData,
                groupBy: (exp) => exp.trxDate!,
                //separator: Divider(),
                order: GroupedListOrder.DESC,
                groupSeparatorBuilder: (String groupValue) => Center(
                  child: Column(
                    children: [
                      Divider(),
                      Text(
                        groupValue,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),
                indexedItemBuilder: (ctx, expense, idx) => ListTile(
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
                          (_expensesData.length - idx).toString(),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
