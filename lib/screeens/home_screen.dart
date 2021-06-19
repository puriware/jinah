import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../screeens/expenses_history_screen.dart';
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
      'page': ExpensesHistoryScreen(),
      'title': Text('Expenses History'),
    },
  ];
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: _pages[_selectedPageIndex]['title'],
        actions: [
          IconButton(
            tooltip: 'Search Expenses',
            onPressed: () {},
            icon: Icon(
              defaultTargetPlatform == TargetPlatform.iOS
                  ? CupertinoIcons.search
                  : Icons.search,
            ),
          ),
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
        ],
      ),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
