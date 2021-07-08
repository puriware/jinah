import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/user_active.dart';
import '../../widgets/daily_summary.dart';
import '../../widgets/list_expenses.dart';
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
          DailySummary(
              limit: limit,
              beforeTodays: beforeTodays,
              currency: currency,
              todayExpenses: todayExpenses,
              limitLeft: limitLeft),
          Expanded(
            child: Card(
              child: ListExpenses(_todays),
            ),
          ),
        ],
      ),
    );
  }
}
