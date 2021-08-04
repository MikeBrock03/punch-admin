
import 'package:animate_do/animate_do.dart';
import '../../constants/app_colors.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/app_navigator.dart';
import '../../helpers/header.dart';
import '../../views/splash/splash.dart';
import 'package:flutter/material.dart';
import '../../helpers/fading_edge_scrollview.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';

class ErrorPage extends StatefulWidget {

  final String title;
  final String description;

  ErrorPage({ @required this.title, @required this.description });

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {

    return FocusWatcher(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: errorBody(context),
      ),
    );
  }

  Widget errorBody(BuildContext context){
    return Container(
      child: Column(
        children: <Widget>[

          Header(),

          Expanded(
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                controller: ScrollController(),
                child: FadeInUp(
                  from: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 50),
                        Text(widget.title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                        SizedBox(height: 20),
                        Text(widget.description, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                        SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 130,
                              height: 45,
                              child: RaisedButton(
                                color: AppColors.primaryColor,
                                elevation: 0.0,
                                onPressed: () {
                                  AppNavigator.pushReplace(context: context, page: Splash());
                                },
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                                child: Text(AppLocalizations.of(context).translate('retry'), style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                              ),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 130,
                              height: 45,
                              child: RaisedButton(
                                color: AppColors.primaryColor,
                                elevation: 0.0,
                                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                                child: Text(AppLocalizations.of(context).translate('exit'), style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),

                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}