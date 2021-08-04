import 'package:flutter/material.dart';

class AppColors {

  static final Color primaryColor      = Color(0xffcd1c1c);
  static final Color primaryDarkColor  = Color(0xff610a06);
  static final Color accentColor       = Color(0xffeb7575);
  static final Color white             = Colors.white;
  static final Color boxShadow         = Colors.grey.withOpacity(0.5);
  static final Color lightGrey         = Colors.grey[400];
  static final Color lightText         = Colors.grey[300];
  static final Color normalText        = Colors.grey[500];

  static final MaterialColor materialAccentColor = MaterialColor(0xff143039, _materialAccentColorMap);


  static Map<int, Color> _materialAccentColorMap = {
     50:Color.fromRGBO(205,28,28, .1),
    100:Color.fromRGBO(205,28,28, .2),
    200:Color.fromRGBO(205,28,28, .3),
    300:Color.fromRGBO(205,28,28, .4),
    400:Color.fromRGBO(205,28,28, .5),
    500:Color.fromRGBO(205,28,28, .6),
    600:Color.fromRGBO(205,28,28, .7),
    700:Color.fromRGBO(205,28,28, .8),
    800:Color.fromRGBO(205,28,28, .9),
    900:Color.fromRGBO(205,28,28,  1),
  };

}