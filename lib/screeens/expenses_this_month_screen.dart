import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/categories.dart';
import '../../models/expenses_item.dart';
import '../../providers/expenses.dart';

class ExpensesThisMonthScreen extends StatefulWidget {
  const ExpensesThisMonthScreen({Key? key}) : super(key: key);

  @override
  _ExpensesThisMonthScreenState createState() =>
      _ExpensesThisMonthScreenState();
}

class _ExpensesThisMonthScreenState extends State<ExpensesThisMonthScreen> {
  // List<ExpensesItem> _expensesData = [];
  // Map<String, List<ExpensesItem>> _dailyData = {};
  // List<String> _keys = [];
  final currency = NumberFormat("#,##0.00", "en_US");

  // Future<void> _refreshEexpenses(BuildContext ctx) async {
  //   _expensesData = Provider.of<Expenses>(ctx, listen: false).thisMonth;
  //   if (_expensesData.isNotEmpty) {
  //     _dailyData = groupBy(
  //       _expensesData,
  //       (ExpensesItem obj) => obj.trxDate!,
  //     );
  //     _keys = _dailyData.keys.toList();
  //   }
  // }

  // double _sumWeight(List<ExpensesItem> list) {
  //   double result = 0;
  //   for (int i = 0; i < list.length; i++) {
  //     result += list[i].amount!;
  //   }
  //   return result;
  // }

  @override
  Widget build(BuildContext context) {
    final _expensesData =
        Provider.of<Expenses>(context, listen: false).thisMonth;
    return GroupedListView<ExpensesItem, String>(
      elements: _expensesData,
      groupBy: (exp) => exp.trxDate!,
      //separator: Divider(),
      order: GroupedListOrder.DESC,
      groupSeparatorBuilder: (String groupValue) => Center(
        child: Column(
          children: [
            Divider(),
            Text(
              groupValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Divider(),
          ],
        ),
      ),
      indexedItemBuilder: (ctx, expense, idx) => ListTile(
        title: Text(
          Provider.of<Categories>(context, listen: false).categoryName(
            expense.category.toString(),
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: large,
          ),
        ),
        subtitle: Text(expense.purpose.toString()),
        leading: CircleAvatar(
          // Theme.of(context).accentColor,
          radius: 30,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: FittedBox(
              child: Text(
                (_expensesData.length - idx).toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        trailing: Text(
          'Rp ${currency.format(expense.amount!)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: large,
            color: Colors.red,
          ),
        ),
      ),
    );
    // return FutureBuilder(
    //   future: _refreshEexpenses(context),
    //   builder: (ctx, snapshot) =>
    //       snapshot.connectionState == ConnectionState.waiting
    //           ? Center(
    //               child: CircularProgressIndicator(),
    //             )
    //           : RefreshIndicator(
    //               onRefresh: () => _refreshEexpenses(context),
    //               child: GroupedListView<ExpensesItem, String>(
    //                 elements: _expensesData,
    //                 groupBy: (exp) => exp.trxDate!,
    //                 //separator: Divider(),
    //                 order: GroupedListOrder.DESC,
    //                 groupSeparatorBuilder: (String groupValue) => Center(
    //                   child: Column(
    //                     children: [
    //                       Divider(),
    //                       Text(
    //                         groupValue,
    //                         style: TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 18,
    //                         ),
    //                       ),
    //                       Divider(),
    //                     ],
    //                   ),
    //                 ),
    //                 indexedItemBuilder: (ctx, expense, idx) => ListTile(
    //                   title: Text(
    //                     Provider.of<Categories>(context, listen: false)
    //                         .categoryName(
    //                       expense.category.toString(),
    //                     ),
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: large,
    //                     ),
    //                   ),
    //                   subtitle: Text(expense.purpose.toString()),
    //                   leading: CircleAvatar(
    //                     // Theme.of(context).accentColor,
    //                     radius: 30,
    //                     child: Padding(
    //                       padding: EdgeInsets.all(2),
    //                       child: FittedBox(
    //                         child: Text(
    //                           (_expensesData.length - idx).toString(),
    //                           style: TextStyle(color: Colors.white),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   trailing: Text(
    //                     'Rp ${currency.format(expense.amount!)}',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: large,
    //                       color: Colors.red,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               // child: ListView.builder(
    //               //   itemBuilder: (ctx, idx) {
    //               //     final date = _keys.elementAt(idx);
    //               //     final total = _sumWeight(_dailyData[date]!);
    //               //     return SummaryItem(
    //               //         DateTime.parse(date), total, _dailyData[date]!);
    //               //   },
    //               //   itemCount: _keys.length,
    //               // ),
    //             ),
    // );
  }
}
