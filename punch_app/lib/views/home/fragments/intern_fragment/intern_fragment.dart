import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'components/intern_list.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../view_models/user_view_model.dart';
import '../../../../helpers/app_localizations.dart';

class InternFragment extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalScaffoldKey;
  InternFragment({this.globalScaffoldKey});

  @override
  _InternFragmentState createState() => _InternFragmentState();
}

class _InternFragmentState extends State<InternFragment>
    with AutomaticKeepAliveClientMixin<InternFragment> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: internFragmentBody(),
    );
  }

  Widget internFragmentBody() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          SizedBox(height: 40),
          Center(
              child: Text(
                  AppLocalizations.of(context).translate('interns_title'),
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.grey[700],
                      fontFamily: 'MyriadPro'))),
          SizedBox(height: 30),
          Expanded(child: internList())
        ],
      ),
    );
  }

  Widget internList() {
    return StreamProvider<List<UserModel>>.value(
      value: FirestoreService().getRealTimeInterns(
          uID: Provider.of<UserViewModel>(context, listen: false).uID),
      initialData: null,
      child: InternList(),
    );
  }

  Widget notFoundView() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FaIcon(FontAwesomeIcons.building, size: 60, color: Colors.grey[300]),
        SizedBox(height: 15),
        Text(AppLocalizations.of(context).translate('there_is_nothing_to_show'),
            style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        SizedBox(height: 70)
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
