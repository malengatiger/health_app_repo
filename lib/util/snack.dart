import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

///Utility class to provide snackbars
class AppSnackBar {
  static showSnackBar(
      {required GlobalKey<ScaffoldState> scaffoldKey,
        required String message,
        required Color textColor,
        required Color backgroundColor}) {
    if (scaffoldKey.currentState == null) {
      print('AppSnackbar.showSnackbar --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState!.removeCurrentSnackBar();
    scaffoldKey.currentState!.showSnackBar(new SnackBar(
      content: _getText(message, textColor),
      duration: new Duration(seconds: 15),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackBarWithProgressIndicator(
      {required GlobalKey<ScaffoldState> scaffoldKey,
        required String message,
        required Color textColor,
        required Color backgroundColor}) {
    if (scaffoldKey.currentState == null) {
      return;
    }
    scaffoldKey.currentState!.removeCurrentSnackBar();
    scaffoldKey.currentState!.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: new Container(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            ),
          ),
          _getText(message, textColor),
        ],
      ),
      duration: new Duration(minutes: 5),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackBarWithAction(
      {required GlobalKey<ScaffoldState> scaffoldKey,
        required String message,
        required Color textColor,
        required Color backgroundColor,
        String? actionLabel,
        SnackBarListener? listener,
        IconData? icon,
        int? durationMinutes,
        int? action}) {
    if (scaffoldKey.currentState == null) {
      print(
          'AppSnackbar.showSnackbarWithAction --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState!.removeCurrentSnackBar();
    scaffoldKey.currentState!.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0),
            child: new Container(
              height: 40.0,
              width: 40.0,
              child: Icon(icon),
            ),
          ),
          _getText(message, textColor),
        ],
      ),
      duration:
      new Duration(minutes: durationMinutes == null ? 10 : durationMinutes),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: actionLabel!,
        onPressed: () {
          listener!.onActionPressed(action);
        },
      ),
    ));
  }

  static Widget _getText(
      String message,
      Color textColor,
      ) {
    return Text(
      message,
      overflow: TextOverflow.clip,
      style: new TextStyle(color: textColor),
    );
  }

  static showErrorSnackBar(
      {required GlobalKey<ScaffoldState> scaffoldKey,
        required String? message,
        String? actionLabel, Color? color}) {
    if (scaffoldKey == null || scaffoldKey.currentState == null) {
      print('AppSnackbar.showErrorSnackbar --- currentState is NULL, quit ..');
      return;
    } else {
      scaffoldKey.currentState!.removeCurrentSnackBar();
    }

    var snackBar = new SnackBar(
      content: _getText(message!, Colors.white),
      duration: new Duration(seconds: 20),
      backgroundColor: color == null? Theme.of(scaffoldKey.currentContext!).primaryColor : color,
      action: SnackBarAction(
        label: actionLabel == null? '': actionLabel,
        onPressed: () {
        },
      ),
    );

    scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  static const Error = 0, Action = 1;
}

abstract class SnackBarListener {
  onActionPressed(int? action);
}
