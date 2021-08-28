import 'package:provider/provider.dart';
import '../../constants.dart';
import '../models/category_item.dart';
import '../providers/categories.dart';

import './adaptive_flat_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewCategory extends StatefulWidget {
  final String? categoryId;
  NewCategory({this.categoryId});
  static const routeName = '/categories/new';
  @override
  _NewCategoryState createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _editedcategoryItem = CategoryItem(
    id: null,
    userId: null,
    name: '',
    description: '',
    created: DateTime.now(),
    updated: DateTime.now(),
  );
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? categoryId = widget.categoryId;
      if (categoryId != null) {
        _editedcategoryItem = Provider.of<Categories>(context, listen: false)
            .findById(categoryId);
        _nameController.text = _editedcategoryItem.name.toString();
        _descriptionController.text =
            _editedcategoryItem.description.toString();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty && _descriptionController.text.isEmpty) {
      return;
    }
    final enteredName = _nameController.text;
    final enteredDescription = _descriptionController.text;

    setState(() {
      _isLoading = true;
    });
    if (_editedcategoryItem.id != null) {
      _editedcategoryItem = CategoryItem(
        id: _editedcategoryItem.id,
        userId: _editedcategoryItem.userId,
        name: enteredName,
        description: enteredDescription,
        created: _editedcategoryItem.created,
        updated: DateTime.now(),
      );
      await Provider.of<Categories>(context, listen: false)
          .updateCategoryItem(_editedcategoryItem);
    } else {
      _editedcategoryItem = CategoryItem(
        id: null,
        userId: null,
        name: enteredName,
        description: enteredDescription,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      try {
        await Provider.of<Categories>(context, listen: false)
            .addCategoryItem(_editedcategoryItem);
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
                      'New Category',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: large,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: large,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields_rounded),
                    ),
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    onSubmitted: (_) => _submitData(),
                  ),
                  SizedBox(
                    height: large,
                  ),
                  AdaptiveFlatButton('Save Category', () => _submitData(), null,
                      Icon(Icons.save)),
                ],
              ),
            ),
          );
  }
}
