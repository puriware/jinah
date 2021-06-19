import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expenses_item.dart';
import '../providers/expenses.dart';
import '../widgets/data_item.dart';

class ExpensesListScreen extends StatelessWidget {
  static const routeName = '/expenses';
  const ExpensesListScreen({Key? key}) : super(key: key);

  Future<void> _refreshEexpenses(BuildContext ctx) async {
    await Provider.of<Expenses>(ctx, listen: false).fetchAndSetExpenses();
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
                  child: Consumer<Expenses>(
                    builder: (ctx, expensesData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: GroupedListView<ExpensesItem, String>(
                        elements: expensesData.items,
                        groupBy: (data) => data.trxDate.toString(),
                        groupSeparatorBuilder: (String groupByValue) => Column(
                          children: [
                            Center(
                              child: Text(
                                DateFormat('dd MMMM yyyy').format(
                                  DateTime.parse(groupByValue),
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                            ),
                          ],
                        ),
                        indexedItemBuilder: (ctx, expense, index) => DataItem(
                          expense.id.toString(),
                          expense.purpose.toString(),
                          expense.amount.toString(),
                          index,
                        ),
                        separator: Divider(
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        itemComparator: (exp1, exp2) =>
                            exp1.updated!.compareTo(exp2.updated!),
                        //useStickyGroupSeparators: true, // optional
                        floatingHeader: true, // optional
                        order: GroupedListOrder.DESC,
                      ),
                      // child: ListView.builder(
                      //   itemCount: expensesData.items.length,
                      //   itemBuilder: (_, i) => Column(
                      //     children: [
                      //       DataItem(
                      //         expensesData.items[i].id.toString(),
                      //         expensesData.items[i].purpose.toString(),
                      //         expensesData.items[i].amount.toString(),
                      //         expensesData.items[i].trxDate.toString(),
                      //       ),
                      //       Divider(),
                      //     ],
                      //   ),
                      // ),
                    ),
                  ),
                ),
    );
  }
}
