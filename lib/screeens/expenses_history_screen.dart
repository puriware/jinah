import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import "package:collection/collection.dart";
import '../constants.dart';
import '../models/expense.dart';
import '../providers/expenses.dart';
import '../widgets/history_item.dart';

class ExpensesHistoryScreen extends StatelessWidget {
  const ExpensesHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(medium),
      child: Consumer<Expenses>(
        builder: (ctx, expensesData, child) {
          var newMap = groupBy(
            expensesData.items,
            (Expense obj) => DateFormat('yyyyMM').format(
              DateTime.parse(
                obj.trxDate.toString(),
              ),
            ),
          );
          var mapKey = newMap.keys;
          mapKey = mapKey.sorted((a, b) => a.compareTo(b));
          return mapKey.length > 0
              ? ListView.builder(
                  itemCount: mapKey.length,
                  itemBuilder: (ctx, i) {
                    final key = mapKey.elementAt(mapKey.length - (i + 1));
                    return HistoryItem(newMap[key]!);
                  },
                )
              : Center(
                  child: Text('You don\'t have an expenses yet'),
                );
        },
      ),
    );
  }
}
