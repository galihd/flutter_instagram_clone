import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomIndicator {
  const CustomIndicator({Key? key, this.indicatorText = 'loading'});
  final String indicatorText;

  static show(BuildContext context, String indicatorText) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        content: SizedBox.square(
          dimension: 150,
          child: Wrap(
            direction: Axis.vertical,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 8,
            children: [
              const CupertinoActivityIndicator(),
              Text(style: const TextStyle(fontSize: 15), indicatorText)
            ],
          ),
        ),
      ),
    );
  }
}
