import 'package:flutter/material.dart';
import 'package:punch_app/constants/app_colors.dart';
import 'package:punch_app/helpers/app_localizations.dart';
import 'package:punch_app/helpers/app_navigator.dart';
import 'package:punch_app/views/home/home.dart';
import 'package:punch_app/views/register/register.dart';

class SuccessFragment extends StatelessWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  SuccessFragment({ this.globalScaffoldKey });

  @override
  Widget build(BuildContext context) {
    return successFragmentBody(context);
  }

  Widget successFragmentBody(BuildContext context){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      child: Column(
        children: [
          Text(AppLocalizations.of(context).translate('success_setup'), style: TextStyle(fontSize: 25, color: Colors.grey[500]), textAlign: TextAlign.center,),
          SizedBox(height: 70),
          Text(AppLocalizations.of(context).translate('app_title').toUpperCase() + '!', style: TextStyle(fontSize: 50, color: Colors.grey[700]), textAlign: TextAlign.center,),
          SizedBox(height: 70),
          Image.asset('assets/images/app_icon.png', width: 150),
          SizedBox(height: 40),
          SizedBox(
            width: 210,
            height: 55,
            child: OutlinedButton(
                onPressed: () async{
                  await Future.delayed(Duration(milliseconds: 200));
                  AppNavigator.pushReplace(context: context, page: Home());
                },
                child: Text(AppLocalizations.of(context).translate('continue'), style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.normal)),
                style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 1, color: AppColors.primaryColor),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                )
            ),
          ),
        ],
      ),
    );
  }
}