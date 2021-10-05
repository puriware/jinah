import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_active.dart';
import '../constants.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserActive>(context, listen: false).userActive!;
    return Card(
      color: primaryColor,
      elevation: medium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(large),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: userData.avatar == null
              ? Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                )
              : ClipOval(
                  child: Image.network(
                    userData.avatar!,
                    fit: BoxFit.fill,
                  ),
                ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          '${userData.firstName.toString()} ${userData.lastName.toString()}',
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.white),
        ),
        subtitle: Text(
          currency.format(userData.limit),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        // trailing: Text(
        //   currency.format(limitLeft),
        //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        // ),
      ),
    );
  }
}
