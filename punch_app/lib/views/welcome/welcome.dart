import 'package:animate_do/animate_do.dart';
import 'package:clippy_flutter/diagonal.dart';
import 'package:flutter/material.dart';
import '../../views/verify/verify.dart';
import '../../views/login/login.dart';
import '../../views/register/register.dart';
import '../../config/app_config.dart';
import '../../helpers/app_navigator.dart';
import '../../constants/app_colors.dart';
import '../../helpers/app_localizations.dart';

class Welcome extends StatelessWidget {

  final dynamic verified;
  Welcome({ this.verified });

  final _globalScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalScaffoldKey,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: welcomeBody(context),
    );
  }

  Widget welcomeBody(BuildContext context){

    return Stack(
      children: [
        Positioned(
          top: 0,
          child: Diagonal(
            clipHeight: 150.0,
            axis: Axis.horizontal,
            position: DiagonalPosition.BOTTOM_LEFT,

            child: Container(
              color: AppColors.primaryColor,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.85,
            ),
          ),
        ),

        FadeInDown(
          from: 10,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Center(child: Text(greeting(context), style: TextStyle(fontSize: 25, color: Colors.white),)),
                SizedBox(height: MediaQuery.of(context).size.height / 10),
                Center(child: Text(AppLocalizations.of(context).translate('welcome_to'), style: TextStyle(fontSize: 18, color: Colors.white))),
                SizedBox(height: 10),
                Center(child: Text(AppConfig.appName, style: TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              Container(
                width: 130,
                height: 130,
                //padding: EdgeInsets.all(2),
                child: Image.asset('assets/images/app_icon.png'),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 15,
                        offset: Offset(0, 1), // changes position of shadow
                      )
                    ]
                ),
              ),
              SizedBox(height: 80.0),
            ],
          ),
        ),

        Positioned(
          bottom: 70,
          right: 0,
          left: 0,
          child: FadeInUp(
            from: 10,
            child: Column(
              children: [

                SizedBox(
                  width: 210,
                  height: 55,
                  child: OutlinedButton(
                      onPressed: () async{
                        await Future.delayed(Duration(milliseconds: 200));
                        AppNavigator.pushReplace(context: context, page: Login(verified: verified));
                      },
                      child: Text(AppLocalizations.of(context).translate('login'), style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.normal)),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 1, color: AppColors.primaryColor),
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      )
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 210,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () async{
                      await Future.delayed(Duration(milliseconds: 200));
                      AppNavigator.pushReplace(context: context, page: Register(verified: verified));
                    },
                    child: Text(AppLocalizations.of(context).translate('register'), style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.normal)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1, color: AppColors.primaryColor),
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                    )
                  ),
                ),
                verified != null && verified == false ? Column(
                  children: [
                    SizedBox(height: 20),
                    SizedBox(
                      width: 210,
                      height: 55,
                      child: OutlinedButton(
                          onPressed: () async{
                            await Future.delayed(Duration(milliseconds: 200));
                            AppNavigator.pushReplace(context: context, page: Verify());
                          },
                          child: Text(AppLocalizations.of(context).translate('enter_reg_code'), style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.normal)),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 1, color: AppColors.primaryColor),
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                          )
                      ),
                    ),
                  ],
                ) : Container()
              ],
            ),
          )
        )
      ],
    );
  }

  String greeting(BuildContext context) {
    var hour = DateTime.now().hour;

    if (hour <= 12) {
      return AppLocalizations.of(context).translate('good_morning');
    } else if ((hour > 12) && (hour <= 16)) {
      return AppLocalizations.of(context).translate('good_afternoon');
    } else if ((hour > 16) && (hour < 20)) {
      return AppLocalizations.of(context).translate('good_evening');
    } else {
      return AppLocalizations.of(context).translate('good_night');
    }
  }
}