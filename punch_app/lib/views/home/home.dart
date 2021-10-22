import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:punch_app/helpers/export_dialog.dart';
import 'package:punch_app/helpers/loading_dialog.dart';
import 'package:punch_app/view_models/export_view_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../view_models/companies_view_model.dart';
import '../../view_models/interns_view_model.dart';
import '../../views/intern_form/intern_form.dart';
import '../../views/company_form/company_form.dart';
import '../../view_models/user_view_model.dart';
import '../../helpers/message.dart';
import '../../database/storage.dart';
import '../../constants/app_colors.dart';
import '../../helpers/question_dialog.dart';
import '../../views/home/fragments/company_fragment/company_fragment.dart';
import '../../views/home/fragments/intern_fragment/intern_fragment.dart';
import '../../views/welcome/welcome.dart';
import '../../config/app_config.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/app_navigator.dart';
import '../../services/firebase_auth_service.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Storage storage = new Storage();
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  int bottomSelectedIndex = 0;
  var _internPage, _companyPage;
  int backPress = 0;

  final keyOne = GlobalKey();

  String allWeeklyfilePath, allMonthlyfilePath, allYearlyfilePath;

  void getLocalFiles() async {
    final Directory directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR iOS
    final path = directory.path;
    allWeeklyfilePath = '$path/all-weekly.csv';
    allMonthlyfilePath = '$path/all-monthly.csv';
    allYearlyfilePath = '$path/all-yearly.csv';

    bool allWeeklyfilePathExists = await File(allWeeklyfilePath).exists();
    if(!allWeeklyfilePathExists){File(allWeeklyfilePath).create();}

    bool allMonthlyfilePathExists = await File(allMonthlyfilePath).exists();
    if(!allMonthlyfilePathExists){File(allMonthlyfilePath).create();}

    bool allYearlyfilePathExists = await File(allYearlyfilePath).exists();
    if(!allYearlyfilePathExists){File(allYearlyfilePath).create();}

  }

  @override
  void initState() {
    super.initState();
    getLocalFiles();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase([
        keyOne,
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    backPress = 0;

    return WillPopScope(
      onWillPop: () async {
        if (bottomSelectedIndex == 0) {
          if (backPress == 0) {
            globalScaffoldKey.currentState.hideCurrentSnackBar();
            Message.show(globalScaffoldKey,
                AppLocalizations.of(context).translate('exit_message'));
            backPress++;
          } else {
            return true;
          }
        } else {
          bottomTapped(0);
        }

        return false;
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: new Image.asset(
            'assets/images/punch_logo_titlebar.png',
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          centerTitle: true,
          brightness: Brightness.dark,
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              tooltip: 'Export',
              icon: Icon(Icons.ios_share),
              onPressed: () => export(),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                tooltip: AppLocalizations.of(context).translate('logout'),
                icon: Icon(Icons.logout),
                onPressed: () => logout(),
              ),
            ),
          ],
        ),
        body: buildPageView(),
        bottomNavigationBar: bottomNavBar(),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          child: Icon(
            Icons.add,
            size: 25,
          ),
          onPressed: () {
            switch (bottomSelectedIndex) {
              case 0:
                AppNavigator.push(context: context, page: InternForm());
                break;
              case 1:
                AppNavigator.push(context: context, page: CompanyForm());
                break;
            }
          },
        ),
      ),
    );
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  static PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  Widget buildPageView() {
    return PageView.builder(
      itemBuilder: (context, index) {
        if (index == 0) return this.internInit();
        if (index == 1) return this.companyInit();
        return null;
      },
      physics: BouncingScrollPhysics(),
      controller: pageController,
      itemCount: 2,
      onPageChanged: (index) {
        pageChanged(index);
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  Widget bottomNavBar() {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200], width: 1))),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 1,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          bottomTapped(index);
        },
        items: [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.users, size: 22),
              title: Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: Text(AppLocalizations.of(context).translate('interns'),
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.normal)))),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.building, size: 22),
              title: Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: Text(
                      AppLocalizations.of(context).translate('companies'),
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.normal)))),
        ],
      ),
    );
  }

  Widget internInit() {
    if (this._internPage == null)
      this._internPage = InternFragment(globalScaffoldKey: globalScaffoldKey);
    return this._internPage;
  }

  Widget companyInit() {
    if (this._companyPage == null)
      this._companyPage = CompanyFragment(globalScaffoldKey: globalScaffoldKey);
    return this._companyPage;
  }

  void export(){
    Future.delayed(Duration(milliseconds: 250), (){
      showDialog(
        context: context,
        builder: (BuildContext dialogContext){
          return ExportDialog(
            globalKey: globalScaffoldKey,
            onWeekly: () => weeklyReport(),
            onMonthly: () => monthlyReport(),
            onYearly: () => yearlyReport(),
          );
        },
      );
    });
  }

  void weeklyReport() async{
    try {

      await Future.delayed(Duration(milliseconds: 500));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return LoadingDialog();
        },
      );

      dynamic result = await Provider.of<ExportViewModel>(context, listen: false).fetchAllCompaniesWeeklyData(
          uID: Provider.of<UserViewModel>(context, listen: false).uID,
          localFile: File(allWeeklyfilePath)
      );

      Navigator.of(context).pop();

      if (result is bool && result) {
        Share.shareFiles([allWeeklyfilePath]);
      } else {
        Message.show(globalScaffoldKey, 'Unable to create the CSV file, please try again later');
      }
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('Error: $error');
      }
    }
  }

  void monthlyReport() async{
    try {

      await Future.delayed(Duration(milliseconds: 500));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return LoadingDialog();
        },
      );

      dynamic result = await Provider.of<ExportViewModel>(context, listen: false).fetchAllCompaniesMonthlyData(
          uID: Provider.of<UserViewModel>(context, listen: false).uID,
          localFile: File(allMonthlyfilePath)
      );

      Navigator.of(context).pop();

      if (result is bool && result) {
        Share.shareFiles([allMonthlyfilePath]);
      } else {
        Message.show(globalScaffoldKey, 'Unable to create the CSV file, please try again later');
      }
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('Error: $error');
      }
    }
  }

  void yearlyReport() async{
    try {

      await Future.delayed(Duration(milliseconds: 500));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return LoadingDialog();
        },
      );

      dynamic result = await Provider.of<ExportViewModel>(context, listen: false).fetchAllCompaniesYearlyData(
          uID: Provider.of<UserViewModel>(context, listen: false).uID,
          localFile: File(allYearlyfilePath)
      );

      Navigator.of(context).pop();

      if (result is bool && result) {
        Share.shareFiles([allYearlyfilePath]);
      } else {
        Message.show(globalScaffoldKey, 'Unable to create the CSV file, please try again later');
      }
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('Error: $error');
      }
    }
  }

  void logout() {
    Future.delayed(Duration(milliseconds: 250), () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return QuestionDialog(
            globalKey: globalScaffoldKey,
            title: AppLocalizations.of(dialogContext)
                .translate('exit_from_account_description'),
            onYes: () async {
              performLogout();
            },
          );
        },
      );
    });
  }

  void performLogout() async {
    await Future.delayed(Duration(milliseconds: 450));
    try {
      await Provider.of<FirebaseAuthService>(context, listen: false).signOut();
      await storage.clearAll();
      Provider.of<UserViewModel>(context, listen: false).setUserModel(null);
      Provider.of<CompaniesViewModel>(context, listen: false)
          .companyList
          .clear();
      Provider.of<InternsViewModel>(context, listen: false).internList.clear();
      AppNavigator.pushReplace(context: context, page: Welcome());
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('Error: $error');
      }
    }
  }
}
