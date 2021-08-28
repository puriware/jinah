import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/constants.dart';
import 'package:puri_expenses/models/expenses_item.dart';
import 'package:puri_expenses/providers/categories.dart';
import 'package:puri_expenses/providers/expenses.dart';
import 'package:puri_expenses/widgets/message_dialog.dart';
import 'package:puri_expenses/widgets/new_expenses.dart';

class ExpensesGroupList extends StatelessWidget {
  final expensesData;
  ExpensesGroupList(this.expensesData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedListView<ExpensesItem, String>(
      elements: expensesData,
      groupBy: (exp) => DateFormat('dd MMMM yyyy').format(
        DateTime.parse(exp.trxDate!),
      ),
      separator: Divider(
        indent: large,
        endIndent: large,
      ),
      order: GroupedListOrder.DESC,
      groupSeparatorBuilder: (String groupValue) => //Center(
          Container(
        height: 50,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              border: Border.all(
                color: Theme.of(context).accentColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$groupValue',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      indexedItemBuilder: (ctx, expense, idx) => ListTile(
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
                (expensesData.length - idx).toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        trailing: Text(
          currency.format(expense.amount!),
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
    );
  }
}
