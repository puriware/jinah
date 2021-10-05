import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/constants.dart';
import 'package:puri_expenses/models/expense.dart';
import 'package:puri_expenses/providers/categories.dart';
import 'package:puri_expenses/providers/expenses.dart';
import 'package:puri_expenses/widgets/message_dialog.dart';
import 'package:puri_expenses/widgets/new_expenses.dart';

class ExpensesItem extends StatefulWidget {
  final Expense expense;
  final int number;
  ExpensesItem(this.expense, this.number, {Key? key}) : super(key: key);

  @override
  _ExpensesItemState createState() => _ExpensesItemState();
}

class _ExpensesItemState extends State<ExpensesItem> {
  final currency = NumberFormat("#,##0.00", "en_US");
  var _isLoading = false;

  void _updateExpenses(Expense data) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Expenses>(context, listen: false).updateExpense(data);
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(
            'Something went wrong. ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Okay'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteExpenses(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Expenses>(context, listen: false).deleteExpense(id);
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(
            'Something went wrong. ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Okay'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListTile(
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 30,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: FittedBox(
                  child: Text(
                    widget.number.toString(),
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
                color: expense.amount > 0
                    ? Colors.red
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            onLongPress: () {
              MessageDialog.showMessageDialog(
                context,
                'Delete Expenses',
                'Are you sure to delete Expenses data?',
                'Delete',
                () {
                  _deleteExpenses(expense.id.toString());
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
                    context: context,
                    builder: (_) {
                      return GestureDetector(
                        onTap: () {},
                        child: NewExpenses(
                          _updateExpenses,
                          expensesId: expense.id,
                        ),
                        behavior: HitTestBehavior.opaque,
                      );
                    },
                  );
                },
              );
            },
          );
  }
}
