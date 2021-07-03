import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:provider/provider.dart';
import 'package:puri_expenses/widgets/summary_item.dart';
import '../../models/expenses_item.dart';
import '../../providers/expenses.dart';

class ExpensesThisMonthScreen extends StatefulWidget {
  const ExpensesThisMonthScreen({Key? key}) : super(key: key);

  @override
  _ExpensesThisMonthScreenState createState() =>
      _ExpensesThisMonthScreenState();
}

class _ExpensesThisMonthScreenState extends State<ExpensesThisMonthScreen> {
  List<ExpensesItem> _expensesData = [];
  Map<String, List<ExpensesItem>> _dailyData = {};
  List<String> _keys = [];

  Future<void> _refreshEexpenses(BuildContext ctx) async {
    _expensesData = Provider.of<Expenses>(ctx, listen: false).thisMoth;
    if (_expensesData.isNotEmpty) {
      _dailyData = groupBy(
        _expensesData,
        (ExpensesItem obj) => obj.trxDate!,
      );
      _keys = _dailyData.keys.toList();
    }
  }

  double _sumWeight(List<ExpensesItem> list) {
    double result = 0;
    for (int i = 0; i < list.length; i++) {
      result += list[i].amount!;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _refreshEexpenses(context),
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshEexpenses(context),
                  child: ListView.builder(
                    itemBuilder: (ctx, idx) {
                      final date = _keys.elementAt(idx);
                      final total = _sumWeight(_dailyData[date]!);
                      return SummaryItem(date, total, _dailyData[date]!);
                    },
                    itemCount: _keys.length,
                  ),
                ),
    );
  }
}
