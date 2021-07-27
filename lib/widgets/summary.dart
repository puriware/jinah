import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  final String title;
  final String focusText;
  final String subTitle;
  final Color color;

  Summary(this.title, this.focusText, this.subTitle, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              focusText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: color,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            FittedBox(
              child: Text(
                subTitle,
                style: TextStyle(
                  color: Colors.grey,
                ),
                //textAlign: TextAlign.center,
              ),
            ),
          ]),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     color,
        //     color.withOpacity(0.6),
        //   ],
        // ),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
