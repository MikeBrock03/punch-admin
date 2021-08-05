import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/firestore_service.dart';
import '../../view_models/user_view_model.dart';
import '../../views/verify/verify.dart';
import '../../models/user_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../views/welcome/welcome.dart';
import '../../views/login/login.dart';
import '../../helpers/app_navigator.dart';
import '../../config/app_config.dart';
import '../../helpers/message.dart' as mess;
import '../../constants/app_colors.dart';
import '../../helpers/app_text_field.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../helpers/progress_button.dart';
import '../../helpers/app_localizations.dart';

class Register extends StatefulWidget {
  final dynamic verified;
  Register({this.verified});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _buttonAnimationController;
  ScrollController scrollController = ScrollController();

  String firstName, lastName, email, password, passwordRepeat;
  bool firstNameSt = true,
      lastNameSt = true,
      emailSt = true,
      passwordSt = true,
      passwordRepeatSt = true,
      submitSt = true;

  @override
  void initState() {
    super.initState();

    _buttonAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: WillPopScope(
        onWillPop: () async {
          AppNavigator.pushReplace(
              context: context, page: Welcome(verified: widget.verified));
          return true;
        },
        child: Scaffold(
          key: _globalScaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            brightness: Brightness.dark,
            title: Text(AppLocalizations.of(context).translate('register'),
                style: TextStyle(fontSize: 17)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => AppNavigator.pushReplace(
                  context: context, page: Welcome(verified: widget.verified)),
            ),
          ),
          body: registerBody(),
        ),
      ),
    );
  }

  Widget registerBody() {
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: Form(
          key: _formKey,
          child: FadeInUp(
            from: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 40),
                  Text(AppLocalizations.of(context).translate('register_title'),
                      style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  SizedBox(height: 30),
                  AppTextField(
                    isEnable: firstNameSt,
                    labelText:
                        AppLocalizations.of(context).translate('first_name'),
                    textCapitalization: TextCapitalization.sentences,
                    inputAction: TextInputAction.next,
                    onValidate: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('first_name_empty_validate');
                      }

                      if (value.length < 2) {
                        return AppLocalizations.of(context)
                            .translate('first_name_len_validate');
                      }

                      return null;
                    },
                    onChanged: (value) {
                      firstName = value;
                    },
                  ),
                  AppTextField(
                    isEnable: lastNameSt,
                    labelText:
                        AppLocalizations.of(context).translate('last_name'),
                    inputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    onValidate: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('last_name_empty_validate');
                      }

                      if (value.length < 2) {
                        return AppLocalizations.of(context)
                            .translate('last_name_len_validate');
                      }

                      return null;
                    },
                    onChanged: (value) {
                      lastName = value;
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  AppTextField(
                    isEnable: emailSt,
                    labelText: AppLocalizations.of(context).translate('email'),
                    textInputFormatter: [
                      FilteringTextInputFormatter.deny(RegExp('[ ]'))
                    ],
                    inputAction: TextInputAction.next,
                    textInputType: TextInputType.emailAddress,
                    onValidate: (value) {
                      Pattern pattern =
                          '[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}';

                      if (value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('email_empty_validate');
                      }

                      if (!RegExp(pattern).hasMatch(value)) {
                        return AppLocalizations.of(context)
                            .translate('email_validate');
                      }

                      return null;
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  AppTextField(
                    isEnable: passwordSt,
                    labelText:
                        AppLocalizations.of(context).translate('password'),
                    inputAction: TextInputAction.next,
                    isPassword: true,
                    onValidate: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('password_empty_validate');
                      }

                      if (value.length < 3) {
                        return AppLocalizations.of(context)
                            .translate('password_len_validate');
                      }

                      return null;
                    },
                    onChanged: (value) {
                      password = value;
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  AppTextField(
                    isEnable: passwordRepeatSt,
                    labelText: AppLocalizations.of(context)
                        .translate('password_repeat'),
                    inputAction: TextInputAction.done,
                    isPassword: true,
                    onValidate: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('password_repeat_empty_validate');
                      }

                      if (value.length < 3) {
                        return AppLocalizations.of(context)
                            .translate('password_repeat_len_validate');
                      }

                      if (value != password) {
                        return AppLocalizations.of(context)
                            .translate('password_repeat_validate');
                      }

                      return null;
                    },
                    onFieldSubmitted: (value) {
                      passwordRepeat = value;
                      submitForm();
                    },
                    onChanged: (value) {
                      passwordRepeat = value;
                    },
                  ),
                  SizedBox(height: 18),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 65,
                    height: 50,
                    child: ProgressButton(
                      animationController: _buttonAnimationController,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: AppColors.primaryColor,
                      progressIndicatorSize: 15,
                      strokeWidth: 2,
                      child: Text(
                        AppLocalizations.of(context).translate('register'),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: (AnimationController controller) {
                        if (submitSt) {
                          submitForm();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 60),
                  Text(AppLocalizations.of(context).translate('login_instead'),
                      style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  SizedBox(height: 10),
                  SizedBox(
                      height: 40,
                      width: 150,
                      child: TextButton(
                        onPressed: submitSt
                            ? () async {
                                await Future.delayed(
                                    Duration(milliseconds: 200));
                                AppNavigator.pushReplace(
                                    context: context,
                                    page: Login(verified: widget.verified));
                              }
                            : null,
                        child: Text(
                            AppLocalizations.of(context).translate('login_now'),
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal)),
                      )),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final String websiteUrl = 'https://punchdevelopers.com';

                        if (await canLaunch(websiteUrl)) {
                          await launch(websiteUrl);
                        } else {
                          mess.Message.show(_globalScaffoldKey,
                              'Could not launch the browser app');
                        }
                      } catch (error) {
                        print(error);
                      }

                      //await canLaunch('https://punchdevelopers.com') ? await launch(_url) : throw 'Could not launch $_url';
                    },
                    child: Column(
                      children: [
                        Text('TEST 3. Free month trial. Subscribe at ',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500])),
                        SizedBox(height: 10),
                        Text('punchdevelopers.com',
                            style: TextStyle(
                                fontSize: 14, color: Colors.blue[600])),
                      ],
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitForm() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      _buttonAnimationController.forward();

      setState(() {
        firstNameSt = false;
        lastNameSt = false;
        emailSt = false;
        passwordSt = false;
        passwordRepeatSt = false;
        submitSt = false;
      });

      dynamic result;

      try {
        result = await Provider.of<FirebaseAuthService>(context, listen: false)
            .register(email: email.trim(), password: password.trim());

        if (result is UserModel) {
          createProfile(result);

          _buttonAnimationController.reverse();
          mess.Message.show(_globalScaffoldKey, result.toString());
        }
      } catch (error) {
        if (!AppConfig.isPublished) {
          print('$error');
        }

        setState(() {
          firstNameSt = true;
          lastNameSt = true;
          emailSt = true;
          passwordSt = true;
          passwordRepeatSt = true;
          submitSt = true;
        });

        _buttonAnimationController.reverse();
        mess.Message.show(_globalScaffoldKey, error);
      }
    }
  }

  void createProfile(UserModel model) async {
    try {
      String regCode = model.uID.toUpperCase().substring(0, 6);

      UserModel userModel = UserModel(
          uID: model.uID,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          email: email.trim(),
          tel: '',
          mobile: '',
          address: '',
          platform: Platform.operatingSystem,
          registererID: '',
          createdAt: Timestamp.now(),
          imageURL: '',
          roleID: AppConfig.adminUserRole.toDouble(),
          tags: [
            firstName.trim().toLowerCase(),
            lastName.trim().toLowerCase(),
            '${firstName.trim().toLowerCase()} ${lastName.trim().toLowerCase()}',
            email.trim().toLowerCase(),
            regCode
          ],
          regCode: regCode,
          status: true,
          verified: false,
          hasPassword: AppConfig.adminUserRole == 10 ? true : false);

      await Provider.of<FirestoreService>(context, listen: false)
          .createProfile(userModel: userModel);
      Provider.of<UserViewModel>(context, listen: false)
          .setUserModel(userModel);
      await Provider.of<UserViewModel>(context, listen: false).sendEmail(
          message:
              'Welcome to the Punch family! Your Punch registration code is: $regCode',
          email: userModel.email);
      await Provider.of<UserViewModel>(context, listen: false).sendEmail(
          message:
              'Howdy partner! Congrats on the new admin user! $firstName $lastName , $email',
          email: 'punchdevelopers@gmail.com');

      AppNavigator.pushReplace(context: context, page: Verify());
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('$error');
      }

      setState(() {
        firstNameSt = true;
        lastNameSt = true;
        emailSt = true;
        passwordSt = true;
        passwordRepeatSt = true;
        submitSt = true;
      });

      _buttonAnimationController.reverse();
      mess.Message.show(_globalScaffoldKey, error);
    }
  }
}
