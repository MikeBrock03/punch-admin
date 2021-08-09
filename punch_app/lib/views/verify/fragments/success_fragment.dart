import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:punch_app/constants/app_colors.dart';
import 'package:punch_app/helpers/app_localizations.dart';
import 'package:punch_app/helpers/app_navigator.dart';
import 'package:punch_app/views/home/home.dart';

class SuccessFragment extends StatelessWidget {
  final GlobalKey<ScaffoldState> globalScaffoldKey;
  SuccessFragment({this.globalScaffoldKey});

  @override
  Widget build(BuildContext context) {
    return successFragmentBody(context);
  }

  Widget successFragmentBody(BuildContext context) {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FadeInRight(
            from: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hooray!',
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.grey[600],
                      )),
                  SizedBox(height: 20),
                  Text(AppLocalizations.of(context).translate('success_setup'),
                      style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                  SizedBox(height: 20),
                  Text(
                      'You can now add employers and interns, all within an image-driven interface.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                  SizedBox(height: 40),
                  Text(
                      '(ps...the best part is, their account is created and they receive their invitation the moment you add them)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      )),
                  SizedBox(height: 70),
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 150,
                  ),
                  SizedBox(
                    width: 210,
                    height: 55,
                    child: OutlinedButton(
                        onPressed: () async {
                          await Future.delayed(Duration(milliseconds: 200));
                          AppNavigator.pushReplace(
                              context: context, page: Home());
                        },
                        child: Text(
                            AppLocalizations.of(context).translate('continue'),
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.normal)),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1, color: AppColors.primaryColor),
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                    new BorderRadius.circular(30.0)))),
                  ),
                ],
              ),
            )));
  }
}
