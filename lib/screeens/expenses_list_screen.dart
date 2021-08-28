import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/widgets/expenses_group_list.dart';
import '../../constants.dart';
import '../../providers/user_active.dart';
import '../../widgets/daily_summary.dart';
import '../providers/expenses.dart';

class ExpensesListScreen extends StatelessWidget {
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

    return Stack(
      children: [
        Container(
          color: primaryColor,
        ),
        Container(
          margin: EdgeInsets.only(top: 55),
          padding: EdgeInsets.only(top: 55),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(large),
              topRight: Radius.circular(large),
            ),
          ),
          child: ExpensesGroupList(
            _expensesData,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: large),
          height: 110,
          child: DailySummary(
            limit: limit,
            beforeTodays: beforeTodays,
            todayExpenses: todayExpenses,
            limitLeft: limitLeft,
          ),
        ),
      ],
    );
  }
}
