import 'dart:core';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:puri_expenses/widgets/expenses_item.dart';
import '../constants.dart';
import '../models/expense.dart';

class ExpensesGroupList extends StatelessWidget {
  final expensesData;
  ExpensesGroupList(this.expensesData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GroupedListView<Expense, String>(
        elements: expensesData,
        groupBy: (exp) => DateFormat('dd MMM yyyy').format(
          DateTime.parse(exp.trxDate!),
        ),
        floatingHeader: true,
        useStickyGroupSeparators: true,
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
        indexedItemBuilder: (ctx, expense, idx) =>
            ExpensesItem(expense, expensesData.length - idx),
      ),
    );
  }
}
