import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/models/user.dart';
import 'package:puri_expenses/providers/user_active.dart';
import '../constants.dart';
import '../providers/auth.dart';
import '../providers/expenses.dart';
import '../screeens/auth_screen.dart';
import '../screeens/home_screen.dart';
import '../screeens/splash_screen.dart';
import '../widgets/new_expenses.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, UserActive>(
          create: (_) => UserActive(null),
          update: (ctx, auth, previousUserData) => UserActive(
            previousUserData == null ? null : previousUserData.userActive,
            authToken: auth.token,
            userId: auth.userId,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Expenses>(
          create: (_) => Expenses([]),
          update: (ctx, auth, previousExpenses) => Expenses(
            previousExpenses == null ? [] : previousExpenses.items,
            authToken: auth.token,
            userId: auth.userId,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appTitle,
          theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.amberAccent,
            appBarTheme: AppBarTheme.of(context).copyWith(
              centerTitle: true,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.green,
              ),
            ),
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            NewExpenses.routeName: (ctx) => NewExpenses(),
          },
        ),
      ),
    );
  }
}
