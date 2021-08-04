import '../constants/app_colors.dart';
import '../helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation<double> scaleAnimation;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.linearToEaseOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          width: 320,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    height: 100,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(right: 10, left: 20),
                            width: double.infinity,
                            height: 100,
                            color: Colors.white,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('${AppLocalizations.of(context).translate('please_wait')}...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[600]), textScaleFactor: 1.0),
                                  SizedBox(width: 15),
                                  Image.asset('assets/images/app_icon.png', width: 80)
                                ],
                              ),
                            )
                        ),
                        Positioned(bottom: 0, left: 0, right: 0, child: SizedBox(width: double.infinity, height: 2, child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor))))
                      ],
                    ),
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}