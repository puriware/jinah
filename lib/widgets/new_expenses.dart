import 'package:provider/provider.dart';
import '../models/expenses_item.dart';
import '../providers/expenses.dart';

import './adaptive_flat_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExpenses extends StatefulWidget {
  String? expensesId;
  NewExpenses({this.expensesId});
  static const routeName = '/new-expenses';
  @override
  _NewExpensesState createState() => _NewExpensesState();
}

class _NewExpensesState extends State<NewExpenses> {
  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  var _editedExpensesItem = ExpensesItem(
    id: null,
    trxDate: null,
    purpose: '',
    amount: 0.0,
    userId: '',
    created: DateTime.now(),
    updated: DateTime.now(),
  );
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
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
      }
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
    if (enteredPurpose.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (_editedExpensesItem.id != null) {
      _editedExpensesItem = ExpensesItem(
        id: _editedExpensesItem.id,
        trxDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        purpose: enteredPurpose,
        amount: enteredAmount,
        userId: _editedExpensesItem.userId,
        created: _editedExpensesItem.created,
        updated: DateTime.now(),
      );
      await Provider.of<Expenses>(context, listen: false)
          .updateExpensesItem(_editedExpensesItem);
    } else {
      _editedExpensesItem = ExpensesItem(
        id: null,
        trxDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        purpose: enteredPurpose,
        amount: enteredAmount,
        userId: '',
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

  void _presentDatePicker() {
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : SingleChildScrollView(
            child: Card(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.only(
                    left: 10,
                    top: 10,
                    right: 10,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      controller: _purposeController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _submitData(),
                    ),
                    Container(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No Date Choosen!'
                                  : DateFormat('dd MMMM yyyy')
                                      .format(_selectedDate!),
                            ),
                          ),
                          AdaptiveFlatButton('Choose Date', _presentDatePicker),
                        ],
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Save Expenses',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _submitData,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
