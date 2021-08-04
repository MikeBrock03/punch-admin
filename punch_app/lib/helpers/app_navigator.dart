
import 'dart:io';
import 'package:flutter/material.dart';
import 'custom_page_route.dart';

class AppNavigator{

  static void push({ @required BuildContext context, @required Widget page }){
    if (Platform.isAndroid) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }else{
      //Navigator.push(context, PageTransition(type: PageTransitionType.downToUpWithFade, child: page));
      Navigator.push(context, _createRoute(page: page));
    }
  }

  static void pushReplace({ @required BuildContext context, @required Widget page }){
    if (Platform.isAndroid) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
    }else{
      //Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.downToUpWithFade, child: page));
      Navigator.pushReplacement(context, _createRoute(page: page));
    }
  }

  static Route _createRoute({@required Widget page}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

}