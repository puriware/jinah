import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expenses.dart';
import '../widgets/new_expenses.dart';

class DataItem extends StatelessWidget {
  final currency = NumberFormat("#,##0.00", "en_US");
  final String id;
  final String purpose;
  final double amount;
  final int index;
  DataItem(
    this.id,
    this.purpose,
    this.amount,
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(
        'Rp ${currency.format(amount)}',
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: Text(purpose),
      leading: CircleAvatar(
        // Theme.of(context).accentColor,
        radius: 30,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: FittedBox(
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded),
              color: Theme.of(context).accentColor,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return GestureDetector(
                      onTap: () {},
                      child: NewExpenses(
                        expensesId: id,
                      ),
                      behavior: HitTestBehavior.opaque,
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_rounded),
              color: Theme.of(context).errorColor,
              onPressed: () async {
                try {
                  await Provider.of<Expenses>(context, listen: false)
                      .deleteExpensesItem(id);
                } catch (error) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete data expenses!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
