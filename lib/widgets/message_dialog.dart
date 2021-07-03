import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageDialog {
  static Future<void> showPopUpMessage(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                return;
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMessageDialog(
    BuildContext context,
    String title,
    String content,
    String action,
    Function callBack, {
    Object? args,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(action),
              onPressed: () {
                Navigator.of(context).pop();
                if (args != null)
                  callBack(args);
                else
                  callBack();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
