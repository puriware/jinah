import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/user.dart';
import '../../providers/user_active.dart';
import '../../widgets/adaptive_flat_button.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({Key? key}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _limitController = TextEditingController();
  User? _activeUser;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit == true) {
      _activeUser = Provider.of<UserActive>(context).userActive;
      if (_activeUser != null) {
        _firstNameController.text = _activeUser!.firstName.toString();
        _lastNameController.text = _activeUser!.lastName.toString();
        _limitController.text = _activeUser!.limit!.toStringAsFixed(2);
      }
    }
    _isInit = false;
  }

  Future<void> _submitData() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _limitController.text.isEmpty) {
      return;
    }

    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final enteredAmount = double.parse(_limitController.text);
    if (enteredAmount <= 0) {
      return;
    }
    if (_activeUser != null && _activeUser!.id != null) {
      _activeUser = User(
        id: _activeUser!.id,
        userId: _activeUser!.userId,
        firstName: firstName,
        lastName: lastName,
        limit: enteredAmount,
        avatar: '',
        created: _activeUser!.created,
        updated: DateTime.now(),
      );
      await Provider.of<UserActive>(context, listen: false)
          .updateUserData(_activeUser!);
    } else {
      _activeUser = User(
        id: null,
        userId: null,
        firstName: firstName,
        lastName: lastName,
        limit: enteredAmount,
        avatar: '',
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      try {
        await Provider.of<UserActive>(context, listen: false)
            .addUserData(_activeUser!);
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(large),
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
            CircleAvatar(
              child: Icon(Icons.person),
            ),
            SizedBox(
              height: large,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    controller: _firstNameController,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(
                  width: medium,
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    controller: _lastNameController,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: large,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Limit per Month',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.price_change_rounded),
              ),
              controller: _limitController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitData(),
            ),
            SizedBox(
              height: large,
            ),
            AdaptiveFlatButton(
              'Save',
              () => _submitData(),
              null,
              Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }
}
