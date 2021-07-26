import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/categories.dart';
import '../../providers/expenses.dart';
import '../../providers/user_active.dart';
import '../../screeens/category_screen.dart';
import '../../screeens/edit_user_screen.dart';
import '../../screeens/expenses_this_month_screen.dart';
import '../../screeens/expenses_summary_screen.dart';
import '../../screeens/user_screen.dart';
import '../screeens/expenses_list_screen.dart';
import '../widgets/new_expenses.dart';

enum OptionMenus {
  Categories,
  EditProfile,
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit == true) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<UserActive>(
        context,
        listen: false,
      ).fetchAndSetUser();
      await Provider.of<Categories>(
        context,
        listen: false,
      ).fetchAndSetCategories();
      await Provider.of<Expenses>(
        context,
        listen: false,
      ).fetchAndSetExpenses();
      setState(() {
        _isLoading = false;
      });

      _isInit = false;
    }
  }

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
      isScrollControlled: true,
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
      isScrollControlled: true,
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
              PopupMenuButton(
                onSelected: (OptionMenus selectedValue) {
                  if (selectedValue == OptionMenus.Categories) {
                    Navigator.of(context).pushNamed(CategoryScreen.routeName);
                  } else if (selectedValue == OptionMenus.EditProfile) {
                    _startEditUserData(context);
                  }
                },
                icon: Icon(
                  Icons.more_vert,
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text('Edit Profile'),
                    value: OptionMenus.EditProfile,
                  ),
                  PopupMenuItem(
                    child: Text('Show Categories'),
                    value: OptionMenus.Categories,
                  ),
                ],
              )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
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
