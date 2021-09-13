import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/expenses.dart';
import '../providers/user_active.dart';
import '../widgets/weekly_chart.dart';

class ExpensesSummary extends StatelessWidget {
  const ExpensesSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeUser = Provider.of<UserActive>(context).userActive;
    final limit =
        activeUser != null && activeUser.limit != null ? activeUser.limit : 0.0;
    final beforeTodays = Provider.of<Expenses>(context).expensesBeforeTodays;
    final todayExpenses = Provider.of<Expenses>(context).todaysTotalExpenses;
    final limitLeft = limit != null
        ? limit - (beforeTodays + todayExpenses)
        : beforeTodays + todayExpenses;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 21),
            blurRadius: large,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Today's Expenses",
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(height: medium),
          Text(
            currency.format(todayExpenses),
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(color: primaryColor, height: 1.2),
          ),
          SizedBox(height: medium),
          Text(
            "This Week\'s Chart",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              color: secondaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: medium),
          WeeklyChart(),
          SizedBox(height: medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildInfoTextWithCurrency(
                value: beforeTodays,
                title: "Total this month ",
                color: Colors.orangeAccent,
              ),
              buildInfoTextWithCurrency(
                value: limitLeft,
                title: "Limit Left",
                color: Colors.redAccent,
              ),
            ],
          )
        ],
      ),
    );
  }

  RichText buildInfoTextWithCurrency({
    required String title,
    required double value,
    TextAlign alignment = TextAlign.start,
    required Color color,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${currency.format(value)}\n',
            style: TextStyle(
              fontSize: 20,
              color: color,
            ),
          ),
          TextSpan(
            text: title,
            style: TextStyle(
              color: secondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
