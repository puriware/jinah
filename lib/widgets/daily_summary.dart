import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../widgets/summary.dart';

class DailySummary extends StatelessWidget {
  const DailySummary({
    Key? key,
    required this.limit,
    required this.beforeTodays,
    required this.todayExpenses,
    required this.limitLeft,
  }) : super(key: key);

  final double? limit;
  final double beforeTodays;
  final double todayExpenses;
  final double limitLeft;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(large),
      ),
      elevation: 5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Summary(
                'Before',
                limit != null
                    ? '${(beforeTodays / limit! * 100).toStringAsFixed(2)}%'
                    : '%',
                currency.format(beforeTodays),
                Colors.orange,
              ),
              Summary(
                'Today',
                limit != null
                    ? '${(todayExpenses / limit! * 100).toStringAsFixed(2)}%'
                    : '%',
                currency.format(todayExpenses),
                Colors.red,
              ),
              Summary(
                'Left',
                limit != null
                    ? '${(limitLeft / limit! * 100).toStringAsFixed(2)}%'
                    : '%',
                currency.format(limitLeft),
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
