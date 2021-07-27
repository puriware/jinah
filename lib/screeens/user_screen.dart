import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth.dart';
import '../../providers/user_active.dart';
import '../../widgets/adaptive_flat_button.dart';
import '../../widgets/message_dialog.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () =>
          Provider.of<UserActive>(context, listen: false).fetchAndSetUser(),
      child: Consumer<UserActive>(
        builder: (ctx, userData, _) => Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: deviceSize.width * 0.5,
                  width: deviceSize.width * 0.5,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
                SizedBox(
                  height: medium,
                ),
                Text(
                  userData.userActive != null
                      ? '${userData.userActive!.firstName.toString()} ${userData.userActive!.lastName.toString()}'
                      : 'User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: medium,
                ),
                Text(
                  userData.userActive != null
                      ? 'Rp ${userData.userActive!.limit.toString()}'
                      : 'Rp 0',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                AdaptiveFlatButton(
                  'About',
                  () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('About Jinah'),
                          content: Text(
                              'Jinah is a simple daily expense recording application.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                return;
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  null,
                  Icon(Icons.info_rounded),
                ),
                SizedBox(
                  height: medium,
                ),
                AdaptiveFlatButton(
                  'Logout',
                  () async {
                    await MessageDialog.showMessageDialog(
                      context,
                      'Logout',
                      'Are you sure you want to logout?',
                      'Logout',
                      () {
                        Navigator.of(context).pushReplacementNamed('/');
                        Provider.of<Auth>(context, listen: false).logOut();
                      },
                    );
                  },
                  Colors.red,
                  Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
