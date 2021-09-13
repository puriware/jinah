import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../constants.dart';
import '../widgets/expenses_pie_chart.dart';
import '../widgets/expenses_summary.dart';
import '../widgets/user_profile.dart';

class ExpensesSummaryScreen extends StatelessWidget {
  const ExpensesSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: large),
      child: SingleChildScrollView(
          child: Column(
        children: [
          UserProfile(),
          SizedBox(height: medium),
          ExpensesSummary(),
          SizedBox(height: large),
          ExpensesPieChart(),
          SizedBox(height: large),
        ],
      )),
    );
  }
}
