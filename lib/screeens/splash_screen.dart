import 'package:flutter/material.dart';
import '../constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor, //Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  primaryColor, // Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: large),
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: deviceSize.width * 0.60,
                  child: Image.asset('assets/images/puriware-long-white.png'),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: deviceSize.width * 0.5,
              child: Image.asset('assets/logos/jinah.png'),
            ),
          ),
        ],
      ),
    );
  }
}
