import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/categories.dart';
import '../../providers/user_active.dart';
import '../../screeens/category_screen.dart';
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
  MaterialColor generateMaterialColor(Color color) {
    return MaterialColor(color.value, {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: shadeColor(color, 0.1),
      700: shadeColor(color, 0.2),
      800: shadeColor(color, 0.3),
      900: shadeColor(color, 0.4),
    });
  }

  int tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  Color tintColor(Color color, double factor) => Color.fromRGBO(
      tintValue(color.red, factor),
      tintValue(color.green, factor),
      tintValue(color.blue, factor),
      1);

  int shadeValue(int value, double factor) =>
      max(0, min(value - (value * factor).round(), 255));

  Color shadeColor(Color color, double factor) => Color.fromRGBO(
      shadeValue(color.red, factor),
      shadeValue(color.green, factor),
      shadeValue(color.blue, factor),
      1);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
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
        ChangeNotifierProxyProvider<Auth, Categories>(
          create: (_) => Categories([]),
          update: (ctx, auth, previousExpenses) => Categories(
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
            fontFamily: 'Lato',
            primarySwatch: generateMaterialColor(primaryColor),
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
            CategoryScreen.routeName: (ctx) => CategoryScreen(),
          },
        ),
      ),
    );
  }
}
