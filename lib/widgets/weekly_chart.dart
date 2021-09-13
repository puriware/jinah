import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expenses.dart';
import '../constants.dart';

class WeeklyChart extends StatelessWidget {
  final now = DateTime.now();
  //List<Expense> thisWeekExpenses = [];

  @override
  Widget build(BuildContext context) {
    final thisWeekExpenses = Provider.of<Expenses>(context).thisWeekExpenses;
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          barGroups: getBarGroups(thisWeekExpenses),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: false,
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: getWeek,
              getTextStyles: getStyles,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle getStyles(double n) {
    return TextStyle(
      color: Color(0xFF7589A2),
      fontSize: 10,
      fontWeight: FontWeight.w200,
    );
  }

  getBarGroups(List<Expense> data) {
    List<double> barChartDatas =
        data.isNotEmpty ? getTotalByDay(data) : [0, 0, 0, 0, 0, 0, 0];
    List<BarChartGroupData> barChartGroups = [];
    final weekday = DateTime.now().weekday;
    barChartDatas.asMap().forEach(
          (i, value) => barChartGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  y: value,
                  colors: i == weekday - 1 ? [primaryColor] : [secondaryColor],
                  width: 24,
                )
              ],
            ),
          ),
        );
    return barChartGroups;
  }

  List<double> getTotalByDay(List<Expense> data) {
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    final weekday = today.weekday;
    List<double> result = [];

    for (int i = (weekday - 1); i >= 0; i--) {
      final date = today.add(Duration(days: -i));
      final dateExpense = [
        ...data
            .where(
              (element) =>
                  DateTime.parse(element.trxDate!).isAtSameMomentAs(date),
            )
            .toList()
      ];
      var totalExpenses = 0.0;
      if (dateExpense.isNotEmpty) {
        totalExpenses = dateExpense
            .map((e) => e.amount)
            .toList()
            .reduce((value, element) => value + element);
      }
      result.add(totalExpenses);
    }
    for (int j = weekday; j <= 7; j++) {
      result.add(0);
    }
    return result;
  }

  String getWeek(double value) {
    switch (value.toInt()) {
      case 0:
        return 'MON';
      case 1:
        return 'TUE';
      case 2:
        return 'WED';
      case 3:
        return 'THU';
      case 4:
        return 'FRI';
      case 5:
        return 'SAT';
      case 6:
        return 'SUN';
      default:
        return '';
    }
  }
}
