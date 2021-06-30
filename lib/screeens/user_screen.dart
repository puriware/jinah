import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/constants.dart';
import 'package:puri_expenses/providers/user_active.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  Future<void> _refreshUserData(BuildContext ctx) async {
    await Provider.of<UserActive>(ctx, listen: false).fetchAndSetUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _refreshUserData(context),
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshUserData(context),
                  child: Consumer<UserActive>(
                    builder: (ctx, userData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              child: Icon(
                                Icons.person,
                              ),
                            ),
                            SizedBox(
                              height: medium,
                            ),
                            Text(
                              userData.userActive != null
                                  ? '${userData.userActive!.firstName.toString()} ${userData.userActive!.lastName.toString()}'
                                  : 'User',
                              style: Theme.of(context).textTheme.headline6,
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
