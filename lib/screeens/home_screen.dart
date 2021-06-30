import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:puri_expenses/screeens/edit_user_screen.dart';
import 'package:puri_expenses/screeens/expense_this_month_screen.dart';
import 'package:puri_expenses/screeens/expenses_summary.dart';
import 'package:puri_expenses/screeens/user_screen.dart';
import '../screeens/expenses_list_screen.dart';
import '../widgets/new_expenses.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, Widget>> _pages = [
    {
      'page': ExpensesListScreen(),
      'title': Text('Expenses List'),
    },
    {
      'page': ExpensesSummaryScreen(),
      'title': Text('Expenses Summary'),
    },
    {
      'page': UserScreen(),
      'title': Text('Account'),
    },
  ];
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _startEditUserData(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: EditUserScreen(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewExpenses(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _selectedPageIndex == 0 ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: _pages[_selectedPageIndex]['title'],
          bottom: _selectedPageIndex == 0
              ? TabBar(
                  tabs: [
                    Tab(
                      text: 'Today',
                    ),
                    Tab(
                      text: 'This Month',
                    ),
                  ],
                )
              : null,
          actions: [
            // IconButton(
            //   tooltip: 'Search Expenses',
            //   onPressed: () {},
            //   icon: Icon(
            //     defaultTargetPlatform == TargetPlatform.iOS
            //         ? CupertinoIcons.search
            //         : Icons.search,
            //   ),
            // ),
            if (_selectedPageIndex == 0)
              IconButton(
                tooltip: 'Add new Expenses',
                onPressed: () {
                  _startAddNewTransaction(context);
                },
                icon: Icon(
                  defaultTargetPlatform == TargetPlatform.iOS
                      ? CupertinoIcons.add
                      : Icons.add_rounded,
                ),
              ),
            if (_selectedPageIndex == 2)
              IconButton(
                tooltip: 'Edit user data',
                onPressed: () {
                  _startEditUserData(context);
                },
                icon: Icon(
                  defaultTargetPlatform == TargetPlatform.iOS
                      ? CupertinoIcons.pencil
                      : Icons.edit,
                ),
              ),
          ],
        ),
        body: TabBarView(
          children: [
            _pages[_selectedPageIndex]['page']!,
            if (_selectedPageIndex == 0) ExpensesThisMonthScreen()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
