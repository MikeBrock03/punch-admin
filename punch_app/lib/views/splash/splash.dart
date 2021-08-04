
import 'package:animate_do/animate_do.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/companies_view_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../helpers/app_localizations.dart';
import '../../views/error/error.dart';
import '../../helpers/helper.dart';
import '../../views/verify/verify.dart';
import '../../services/firestore_service.dart';
import '../../view_models/user_view_model.dart';
import '../../views/home/home.dart';
import '../../helpers/app_navigator.dart';
import '../../models/user_model.dart';
import '../../views/welcome/welcome.dart';
import '../../constants/app_colors.dart';
import '../../config/app_config.dart';
import '../../database/storage.dart';

class Splash extends StatefulWidget {

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  final splashImage = Image.asset('assets/images/app_icon.png');
  final Storage storage = new Storage();

  @override
  void didChangeDependencies() {
    precacheImage(splashImage.image, context);
    checkLogin(context);
    super.didChangeDependencies();
  }

  void checkLogin(BuildContext context) async{
    if(await Helper.isNetAvailable()) {
      try {
        await Future.delayed(Duration(milliseconds: 3000));

        var verifiedSt = await storage.getBool('verified');
        final user = context.read<UserModel>();

        if (user == null) {
          AppNavigator.pushReplace(context: context, page: Welcome(verified: verifiedSt));
        } else {
          if (user.uID != null) {
            // set user data
            dynamic result = await Provider.of<FirestoreService>(context, listen: false).getUserData(uID: user.uID);
            if (result is UserModel) {
              if (result.status) {

                if(result.roleID == AppConfig.adminUserRole.toDouble()){
                  Provider.of<UserViewModel>(context, listen: false).setUserModel(result);
                  if (result.verified) {
                    await Provider.of<CompaniesViewModel>(context, listen: false).fetchData(uID: Provider.of<UserViewModel>(context, listen: false).uID);
                    AppNavigator.pushReplace(context: context, page: Home());
                  } else {
                    AppNavigator.pushReplace(context: context, page: Verify());
                  }
                }else{
                  performLogout();
                }
              } else {
                // error page
                AppNavigator.pushReplace(context: context, page: Welcome(verified: null));
              }
            } else {
              // error page
              AppNavigator.pushReplace(context: context, page: Welcome(verified: null));
            }
          }
        }
      } catch (error) {
        if (!AppConfig.isPublished) {
          print('Error: $error');
        }

        Future.delayed(Duration(seconds: 3), (){
          AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context).translate('connection_error_title'), description: AppLocalizations.of(context).translate('receive_error_description')));
        });
      }
    }else{
      Future.delayed(Duration(seconds: 3), (){
        AppNavigator.pushReplace(context: context, page: ErrorPage(title: AppLocalizations.of(context).translate('connection_error_title'), description: AppLocalizations.of(context).translate('connection_error_description')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
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

          Center(
            child: FadeInDown(
              from: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Container(
                    width: 130,
                    height: 130,
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
                  SizedBox(height: 30.0),
                  Text(AppConfig.appName, style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.normal)),
                  SizedBox(height: 30.0),

                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            child: FadeInUp(
              from: 10,
              child: SizedBox(
                  child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryColor)
                  ),
                  height: 20.0,
                  width: 20.0
              ),
            ),
          ),
        ],
      ),
    );
  }

  void performLogout() async{
    try{
      await Provider.of<FirebaseAuthService>(context, listen: false).signOut();
      await storage.clearAll();
      Provider.of<UserViewModel>(context, listen: false).setUserModel(null);
      AppNavigator.pushReplace(context: context, page: Welcome());
    }catch(error) {
      if (!AppConfig.isPublished) {
        print('Error: $error');
      }
    }
  }
}