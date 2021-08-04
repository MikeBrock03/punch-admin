import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:punch_app/config/app_config.dart';
import 'package:punch_app/helpers/no_glow_scroll_behavior.dart';
import 'package:punch_app/views/contact_info/contact_info.dart';
import '../../views/intern_view_select/intern_view_select.dart';
import '../../helpers/loading_dialog.dart';
import '../../view_models/companies_view_model.dart';
import '../../helpers/message.dart';
import '../../services/firestore_service.dart';
import '../../helpers/app_navigator.dart';
import '../../views/company_form/company_form.dart';
import '../../helpers/question_dialog.dart';
import '../../constants/app_colors.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../view_models/interns_view_model.dart';
import '../../helpers/app_localizations.dart';
import '../../models/user_model.dart';

class CompanyDetail extends StatefulWidget {

  final UserModel company;

  CompanyDetail({ this.company });

  @override
  _CompanyDetailState createState() => _CompanyDetailState();
}

class _CompanyDetailState extends State<CompanyDetail> {

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  bool loadingSt = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async{

    try{

      Provider.of<InternsViewModel>(context, listen: false).internList.clear();
      dynamic result = await Provider.of<InternsViewModel>(context, listen: false).fetchData(uID: widget.company.uID);
      setState(() { loadingSt = false; });

      if(result is bool && result){
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();

      }else{
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
        Message.show(_globalScaffoldKey, result);
      }

    }catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      _refreshController.loadComplete();
      _refreshController.refreshCompleted();
      Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('receive_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalScaffoldKey,
      appBar: AppBar(
        title: Text('${widget.company.companyName} Interns', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        brightness: Brightness.dark,
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).translate('delete'),
            icon: Icon(Icons.delete_outline),
            onPressed: () => delete(),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              tooltip: AppLocalizations.of(context).translate('edit'),
              icon: Icon(Icons.edit_outlined),
              onPressed: () => AppNavigator.push(context: context, page: CompanyForm(userModel: widget.company, onFinish:() => setState(() {}))),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: companyDetailBody(),
    );
  }

  void delete(){
    Future.delayed(Duration(milliseconds: 250), (){
      showDialog(
        context: context,
        builder: (BuildContext dialogContext){
          return QuestionDialog(
            globalKey: _globalScaffoldKey,
            title: AppLocalizations.of(dialogContext).translate('delete_company_alert'),
            onYes: (){
              performDelete();
            },
          );
        },
      );
    });
  }

  void performDelete() async{
    Future.delayed(Duration(milliseconds: 800), (){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext cntx){
          return LoadingDialog();
        },
      );
    });

    dynamic result = await Provider.of<FirestoreService>(context, listen: false).deleteUser(uID: widget.company.uID);
    if(result is bool && result){
      Provider.of<CompaniesViewModel>(context, listen: false).removeFromList(model: widget.company);
      await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
      await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('delete_company_success'));});
      await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
    }else{
      await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
      await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('delete_company_fail'));});
    }
  }

  Widget companyDetailBody(){
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: SmartRefresher(
        enablePullUp: false,
        enablePullDown: true,
        controller: _refreshController,
        header: MaterialClassicHeader(distance: 36, color: AppColors.primaryColor),
        onRefresh: () => getData(),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              Row(
                children: [

                  Hero(
                    tag: widget.company.uID,
                    child: GestureDetector(
                      onTap: (){
                        AppNavigator.push(context: context, page: ContactInfo(userModel: widget.company, isIntern: false));
                      },
                      child: Container(
                          width: 95,
                          height: 95,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: widget.company.logoURL != null && widget.company.logoURL != '' ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              placeholder:(context, url) => Container(color: Colors.grey[200]),
                              imageUrl: widget.company.logoURL,
                              width: 95,
                              height: 95,
                              fit: BoxFit.cover,
                            ),
                          ) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(widget.company.companyName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
                      ),
                    ),
                  ),

                  SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Company: ${widget.company.companyName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        SizedBox(height: 15),
                        Text('Employer: ${widget.company.firstName} ${widget.company.lastName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        SizedBox(height: 15),
                        Text('Email: ${widget.company.email}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  )
                ],
              ),

              SizedBox(height: 20),
              Divider(),
              Expanded(
                child: loadingSt == true ? FadeInUp(from: 8, child: loading()) : Provider.of<InternsViewModel>(context, listen: false).internList.isEmpty ? FadeInUp(from: 8, child: notFoundView()) : FadeInUp(from: 8,
                  child: Container(
                      child: FadingEdgeScrollView.fromListView(
                          child: ListView(
                            controller: ScrollController(),
                            physics: BouncingScrollPhysics(),
                            children: [

                              Column(
                                children: [

                                  SizedBox(height: 10),

                                  GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(12),
                                    itemCount: Provider.of<InternsViewModel>(context, listen: false).internList.length,
                                    scrollDirection: Axis.vertical,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20),
                                    itemBuilder: (BuildContext context, int index) {

                                      var intern = Provider.of<InternsViewModel>(context, listen: false).internList[index];

                                      return Hero(
                                        tag: intern.uID,
                                        child: GestureDetector(
                                          onTap: (){
                                            AppNavigator.push(context: context, page: InternViewSelect(intern: intern, onDelete: (){
                                             setState(() {});
                                            }));
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(600),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: intern.imageURL != null && intern.imageURL != '' ? ClipRRect(
                                                borderRadius: BorderRadius.circular(600),
                                                child: CachedNetworkImage(
                                                  placeholder:(context, url) => Container(color: Colors.grey[200]),
                                                  imageUrl: intern.imageURL,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(intern.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                      )
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget notFoundView(){
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(FontAwesomeIcons.users, size: 60, color: Colors.grey[300]),
            SizedBox(height: 15),
            Text(AppLocalizations.of(context).translate('there_is_nothing_to_show'), style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            SizedBox(height: 70)
          ],
        )
    );
  }

  Widget loading(){
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryColor)
                ),
                height: 20.0,
                width: 20.0
            ),
            SizedBox(height: 15),
            Text(AppLocalizations.of(context).translate('loading'), style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            SizedBox(height: 70)
          ],
        )
    );
  }
}