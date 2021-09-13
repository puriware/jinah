import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/models/expense.dart';
import '../constants.dart';
import '../models/user.dart';
import '../screeens/expenses_history_screen.dart';
import '../widgets/message_dialog.dart';
import '../../providers/categories.dart';
import '../../providers/expenses.dart';
import '../../providers/user_active.dart';
import '../../screeens/category_screen.dart';
import '../../screeens/edit_user_screen.dart';
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
  User? _activeUser;
  PageController _pageController = PageController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit == true) {
      setState(() {
        _isLoading = true;
      });
      try {
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
        _activeUser = Provider.of<UserActive>(
          context,
          listen: false,
        ).userActive;
      } catch (error) {
        if (mounted) {
          MessageDialog.showPopUpMessage(
            context,
            "Error",
            error.toString(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, Widget>> _pages = [
    {
      'page': ExpensesSummaryScreen(),
      'title': Text('Jinah Summary'),
    },
    {
      'page': ExpensesListScreen(),
      'title': Text('Expenses List'),
    },
    {
      'page': ExpensesHistoryScreen(),
      'title': Text('Expenses History'),
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

  void _startEditUserData(BuildContext ctx) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(large),
          topRight: Radius.circular(large),
        ),
      ),
      builder: (_) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(large),
            topRight: Radius.circular(large),
          ),
          child: GestureDetector(
            onTap: () {},
            child: EditUserScreen(),
            behavior: HitTestBehavior.opaque,
          ),
        );
      },
    );
  }

  void _startAddNewTransaction(BuildContext ctx) async {
    if (_activeUser == null || _activeUser!.limit == null) {
      await MessageDialog.showPopUpMessage(
        context,
        'Expenses Limit',
        'The spending limit data has not been set. Please set a spending limit in advance.',
      );
      _startEditUserData(ctx);
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(large),
          topRight: Radius.circular(large),
        ),
      ),
      context: ctx,
      builder: (_) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(large),
            topRight: Radius.circular(large),
          ),
          child: GestureDetector(
            onTap: () {},
            child: NewExpenses(_saveExpenses),
            behavior: HitTestBehavior.opaque,
          ),
        );
      },
    );
  }

  Future _saveExpenses(Expense data) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Expenses>(context, listen: false).addExpense(data);
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(
            'Something went wrong. ${error.toString()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Okay'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _selectedPageIndex == 0 ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: _pages[_selectedPageIndex]['title'],
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
            if (_selectedPageIndex == 1) ...[
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
              PopupMenuButton(
                onSelected: (OptionMenus selectedValue) {
                  if (selectedValue == OptionMenus.Categories) {
                    Navigator.of(context).pushNamed(CategoryScreen.routeName);
                  }
                },
                icon: Icon(
                  Icons.more_vert,
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text('Categories'),
                    value: OptionMenus.Categories,
                  ),
                ],
              ),
            ],
            if (_selectedPageIndex == 3)
              IconButton(
                tooltip: 'Manage Account',
                onPressed: () {
                  _startEditUserData(context);
                },
                icon: Icon(
                  defaultTargetPlatform == TargetPlatform.iOS
                      ? CupertinoIcons.settings
                      : Icons.manage_accounts_rounded,
                ),
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : PageView(
                controller: _pageController,
                onPageChanged: _selectPage,
                children: _pages.map((page) => page['page'] as Widget).toList(),
              ),
        bottomNavigationBar: BottomNavyBar(
          onItemSelected: (index) {
            _selectPage(index);
            _pageController.jumpToPage(index);
          },
          selectedIndex: _selectedPageIndex,
          items: [
            BottomNavyBarItem(
              icon: Icon(Icons.home_rounded),
              title: Text('Home'),
              activeColor: primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.list_rounded),
              title: Text('Timeline'),
              activeColor: primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.history_rounded),
              title: Text('History'),
              activeColor: primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.person_outline_rounded),
              title: Text('Account'),
              activeColor: primaryColor,
              inactiveColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
