import 'package:animate_do/animate_do.dart';
import 'package:clippy_flutter/arc.dart';
import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 2 + 50,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Column(
              children: <Widget>[
                Container(
                  color: AppColors.primaryColor,
                  height: 80,
                ),
                Arc(
                  arcType: ArcType.CONVEX,
                  edge: Edge.BOTTOM,
                  height: 30.0,
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 100,
            child: FadeInDown(
              from: 30,
              child: Container(
                width: MediaQuery.of(context).size.width / 3 - 30,
                child: Image.asset('assets/images/app_icon.png'),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 1), // changes position of shadow
                      )
                    ]
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
