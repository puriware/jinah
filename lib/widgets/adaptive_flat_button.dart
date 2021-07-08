import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants.dart';

class AdaptiveFlatButton extends StatelessWidget {
  final String text;
  final Color? color;
  final Icon? icon;
  final Function handler;

  AdaptiveFlatButton(this.text, this.handler, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      child: Platform.isIOS
          ? CupertinoButton(
              onPressed: () {
                handler();
              },
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : icon != null
              ? ElevatedButton.icon(
                  onPressed: () => handler(),
                  icon: icon!,
                  label: Text(text),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        color != null ? color : primaryColor),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    handler();
                  },
                  child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        color != null ? color : primaryColor),
                  ),
                ),
    );
  }
}
