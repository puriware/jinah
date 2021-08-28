import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/category_item.dart';
import '../../providers/categories.dart';
import '../models/expenses_item.dart';
import '../providers/expenses.dart';

import './adaptive_flat_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExpenses extends StatefulWidget {
  final String? expensesId;
  NewExpenses({this.expensesId});
  static const routeName = '/new-expenses';
  @override
  _NewExpensesState createState() => _NewExpensesState();
}

class _NewExpensesState extends State<NewExpenses> {
  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String _categoryValue = '';
  List<DropdownMenuItem<String>> _categoryItems = [];
  List<CategoryItem> _dataCategory = [];
  DateTime _selectedDate = DateTime.now();

  var _editedExpensesItem = ExpensesItem(
    id: null,
    userId: null,
    trxDate: null,
    purpose: '',
    amount: 0.0,
    category: '',
    created: DateTime.now(),
    updated: DateTime.now(),
  );
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _dataCategory = Provider.of<Categories>(context, listen: false).items;
      _categoryItems = _dataCategory
          .map((e) => DropdownMenuItem(
                child: Text(e.name!),
                value: e.id,
              ))
          .toList();
      _categoryValue = _dataCategory[0].id.toString();
      final String? expensesId = widget.expensesId;
      if (expensesId != null) {
        _editedExpensesItem =
            Provider.of<Expenses>(context, listen: false).findById(expensesId);
        _purposeController.text = _editedExpensesItem.purpose.toString();
        _amountController.text = _editedExpensesItem.amount.toString();
        setState(() {
          _selectedDate =
              DateTime.parse(_editedExpensesItem.trxDate.toString());
        });
        _categoryValue = _editedExpensesItem.category.toString();
      }
      _dateController.text = DateFormat('dd MMMM yyyy').format(_selectedDate);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _submitData() async {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredPurpose = _purposeController.text;
    final enteredAmount = double.parse(_amountController.text);
    if (enteredPurpose.isEmpty || enteredAmount <= 0) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (_editedExpensesItem.id != null) {
      _editedExpensesItem = ExpensesItem(
        id: _editedExpensesItem.id,
        userId: _editedExpensesItem.userId,
        trxDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        purpose: enteredPurpose,
        amount: enteredAmount,
        category: _categoryValue,
        created: _editedExpensesItem.created,
        updated: DateTime.now(),
      );
      await Provider.of<Expenses>(context, listen: false)
          .updateExpensesItem(_editedExpensesItem);
    } else {
      _editedExpensesItem = ExpensesItem(
        id: null,
        userId: null,
        trxDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        purpose: enteredPurpose,
        amount: enteredAmount,
        category: _categoryValue,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      try {
        await Provider.of<Expenses>(context, listen: false)
            .addExpensesItem(_editedExpensesItem);
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
      }
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _editedExpensesItem.trxDate != null &&
              _editedExpensesItem.trxDate!.isNotEmpty
          ? DateTime.parse(_editedExpensesItem.trxDate.toString())
          : DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd MMMM yyyy').format(_selectedDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                  //color: kBackgroundColorDarker,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(148.0, 0.0, 148.0, 8.0),
                    child: Container(
                      height: 8.0,
                      width: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: large,
                  ),
                  Center(
                    child: Text(
                      'New Transaction',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: large,
                  ),
                  DropdownButtonFormField<String>(
                    value: _categoryValue,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    icon: Icon(Icons.arrow_drop_down_circle_rounded),
                    items: _categoryItems,
                    onChanged: (value) {
                      _categoryValue = value!;
                    },
                  ),
                  SizedBox(
                    height: large,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    controller: _purposeController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: large,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.price_change_rounded),
                    ),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _submitData(),
                  ),
                  SizedBox(
                    height: large,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Transaction Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range_rounded),
                    ),
                    controller: _dateController,
                    onTap: _showDatePicker,
                    onFieldSubmitted: (_) => _submitData(),
                  ),
                  SizedBox(
                    height: large,
                  ),
                  AdaptiveFlatButton('Save Expenses', () => _submitData(), null,
                      Icon(Icons.save)),
                ],
              ),
            ),
          );
  }
}
