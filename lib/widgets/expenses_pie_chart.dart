import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../constants.dart';
import '../models/expense.dart';
import '../providers/categories.dart';
import '../providers/expenses.dart';
import '../widgets/indicator.dart';

class ExpensesPieChart extends StatefulWidget {
  const ExpensesPieChart({Key? key}) : super(key: key);

  @override
  _ExpensesPieChartState createState() => _ExpensesPieChartState();
}

class _ExpensesPieChartState extends State<ExpensesPieChart> {
  int touchedIndex = -1;
  var today = DateTime.now();
  final _colors = [
    Color(0xFF4357ad),
    Color(0xFF48a9a6),
    Color(0xFFe4dfda),
    Color(0xFFd4b483),
    Color(0xFFc1666b),
    Color(0xFFfb3640),
    Color(0xFF605f5e),
    Color(0xFF247ba0),
    Color(0xFFe2e2e2),
    Color(0xFF083d77),
    Color(0xFFf4d35e),
    Color(0xFFee964b),
    Color(0xFFf95738),
  ];
  List<double> _totalExpenses = [];
  List<double> _percentageExpenses = [];
  List<String> _expenseCategory = [];
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final data = Provider.of<Expenses>(context, listen: false).thisMonth;
      if (data.isNotEmpty) {
        final mapData = groupBy(data, (Expense expense) => expense.category);
        final mapKey = mapData.keys;
        final catName = mapKey
            .map(
              (key) => Provider.of<Categories>(context, listen: false)
                  .findById(key!)
                  .name
                  .toString(),
            )
            .toList();
        if (catName.isNotEmpty) _expenseCategory = catName;
        for (int i = 0; i < mapKey.length; i++) {
          final tempAmount = mapData[mapKey.elementAt(i)]!.map((e) => e.amount);
          final total = tempAmount.reduce((value, element) => value + element);
          _totalExpenses.add(total);
        }
        final total =
            _totalExpenses.reduce((value, element) => value + element);
        _percentageExpenses =
            _totalExpenses.map((value) => value / total * 100).toList();
      }
      _isInit = false;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : AspectRatio(
            aspectRatio: (9 - _expenseCategory.length) / 7,
            child: Container(
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
                    "Categories of the Week",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    height: medium,
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _percentageExpenses.isNotEmpty
                          ? PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                    touchCallback: (pieTouchResponse) {
                                  setState(() {
                                    final desiredTouch = pieTouchResponse
                                            .touchInput is! PointerExitEvent &&
                                        pieTouchResponse.touchInput
                                            is! PointerUpEvent;
                                    if (desiredTouch &&
                                        pieTouchResponse.touchedSection !=
                                            null) {
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    } else {
                                      touchedIndex = -1;
                                    }
                                  });
                                }),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: showingSections(),
                              ),
                            )
                          : Container(),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      _expenseCategory.length,
                      (index) => Indicator(
                        color: _colors[index],
                        text: _expenseCategory[index],
                        isSquare: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 28,
                  ),
                ],
              ),
            ),
          );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(_expenseCategory.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: _colors[i],
        value: _totalExpenses[i].toDouble(),
        title: '${_percentageExpenses[i].toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }
}
