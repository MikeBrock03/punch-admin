import 'dart:math';

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/app_navigator.dart';
import '../../views/welcome/welcome.dart';
import 'fragments/success_fragment.dart';
import 'fragments/reg_code_fragment.dart';

class Verify extends StatefulWidget {
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  var _regCodePage, _successPage;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  static PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppNavigator.pushReplace(
            context: context, page: Welcome(verified: false));
        return true;
      },
      child: Scaffold(
        key: _globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.dark,
          title: Text(
              AppLocalizations.of(context).translate('registration_code'),
              style: TextStyle(fontSize: 17)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => AppNavigator.pushReplace(
                context: context, page: Welcome(verified: false)),
          ),
        ),
        body: buildPageView(),
      ),
    );
  }

  Widget buildPageView() {
    return Stack(
      children: [
        PageView.builder(
          itemBuilder: (context, index) {
            if (index == 0) return this.regCodeInit();
            if (index == 1) return this.successInit();
            return null;
          },
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          itemCount: 2,
          onPageChanged: (index) {
            //pageChanged(index);
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        ),

        // check if the keyboard is appear then hide the page indicator
        /*MediaQuery.of(context).viewInsets.bottom == 0 ? Positioned(
            bottom: 10.0,
            left: 0.0,
            right: 0.0,
            child: new Container(
              padding: const EdgeInsets.all(20.0),
              child: new Center(
                child: new DotsIndicator(
                  controller: pageController,
                  itemCount: 2,
                  color: AppColors.primaryColor,
                  onPageSelected: (int page) {
                    pageController.animateToPage(
                      page,
                      duration: _kDuration,
                      curve: _kCurve,
                    );
                  },
                ),
              ),
            )
        ) : Container()*/
      ],
    );
  }

  Widget regCodeInit() {
    if (this._regCodePage == null)
      this._regCodePage = RegCodeFragment(
          globalScaffoldKey: _globalScaffoldKey,
          onFinish: () {
            pageController.animateToPage(1,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          });
    return this._regCodePage;
  }

  Widget successInit() {
    if (this._successPage == null)
      this._successPage =
          SuccessFragment(globalScaffoldKey: _globalScaffoldKey);
    return this._successPage;
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;

  static const double _kDotSize = 12.0;
  static const double _kDotSpacing = 25.0;
  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(0.0,
          1.0 - ((controller.page ?? controller.initialPage) - index).abs()),
    );

    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: Color.fromRGBO(
              color.red, color.green, color.blue, max(selectedness, 0.3)),
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize,
            height: _kDotSize,
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
