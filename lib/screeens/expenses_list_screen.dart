import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/expenses_group_list.dart';
import '../../constants.dart';
import '../providers/expenses.dart';

class ExpensesListScreen extends StatelessWidget {
  static const routeName = '/expenses';
  ExpensesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _expensesData = Provider.of<Expenses>(
      context,
    ).thisMonth;

    return Container(
      margin: EdgeInsets.only(left: large, right: large, bottom: large),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(large)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ExpensesGroupList(
          _expensesData,
        ),
      ),
    );
  }
}
