import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../widgets/summary.dart';

class DailySummary extends StatelessWidget {
  const DailySummary({
    Key? key,
    required this.limit,
    required this.beforeTodays,
    required this.currency,
    required this.todayExpenses,
    required this.limitLeft,
  }) : super(key: key);

  final double? limit;
  final double beforeTodays;
  final NumberFormat currency;
  final double todayExpenses;
  final double limitLeft;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          SizedBox(
            height: medium,
          ),
          Text(
            DateFormat('EEEE - dd MMMM yyyy').format(
              DateTime.now(),
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          Divider(
            indent: large,
            endIndent: large,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Summary(
                'Before',
                limit != null
                    ? '${(beforeTodays / limit! * 100).toStringAsFixed(2)}%'
                    : '%',
                'Rp ${currency.format(beforeTodays)}',
                Colors.orange,
              ),
              Summary(
                'Today',
                limit != null
                    ? '${(todayExpenses / limit! * 100).toStringAsFixed(2)}%'
                    : '%',
                'Rp ${currency.format(todayExpenses)}',
                Colors.red,
              ),
              Summary(
                'Left',
                limit != null
                    ? '${(limitLeft / limit! * 100).toStringAsFixed(2)}%'
                    : '%',
                'Rp ${currency.format(limitLeft)}',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
