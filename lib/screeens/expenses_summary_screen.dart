import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:puri_expenses/widgets/pie_chart_sample_2.dart';

class ExpensesSummaryScreen extends StatelessWidget {
  const ExpensesSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PieChartSample2(),
    );
  }
}
