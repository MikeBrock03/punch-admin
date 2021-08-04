import 'package:flutter/material.dart';

class Message {
  static void show(GlobalKey<ScaffoldState> globalScaffoldKey, String message){
    globalScaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.grey[900].withAlpha(960),
      elevation: 0.0,
      content: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, fontFamily: 'Iransans')),
    ));
  }
}