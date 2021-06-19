import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expenses.dart';
import '../widgets/new_expenses.dart';

class DataItem extends StatelessWidget {
  final String id;
  final String purpose;
  final String amount;
  final int index;
  const DataItem(
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
      title: Text(purpose),
      subtitle: Text(amount),
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
