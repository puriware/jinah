import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/constants.dart';
import 'package:puri_expenses/providers/auth.dart';
import 'package:puri_expenses/providers/user_active.dart';
import 'package:puri_expenses/widgets/adaptive_flat_button.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return FutureBuilder(
      future: Provider.of<UserActive>(context, listen: false).fetchAndSetUser(),
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => Provider.of<UserActive>(context, listen: false)
                  .fetchAndSetUser(),
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
                            fontSize: 32,
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
                          () {},
                          null,
                          null,
                        ),
                        SizedBox(
                          height: medium,
                        ),
                        AdaptiveFlatButton(
                          'Logout',
                          () {
                            Navigator.of(context).pushReplacementNamed('/');
                            Provider.of<Auth>(context, listen: false).logOut();
                          },
                          Colors.red,
                          Icon(Icons.logout),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
