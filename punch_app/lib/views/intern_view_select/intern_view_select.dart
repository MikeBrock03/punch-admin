import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch_app/views/contact_info/contact_info.dart';
import '../../views/clocks_detail/clocks_detail.dart';
import '../../constants/app_colors.dart';
import '../../helpers/app_navigator.dart';
import '../../helpers/message.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/loading_dialog.dart';
import '../../helpers/question_dialog.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../view_models/interns_view_model.dart';
import '../../views/intern_form/intern_form.dart';

class InternViewSelect extends StatefulWidget {

  UserModel intern;
  Function() onDelete;
  InternViewSelect({ this.intern, this.onDelete });

  @override
  _InternViewSelectState createState() => _InternViewSelectState();
}

class _InternViewSelectState extends State<InternViewSelect> {

  final _globalScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalScaffoldKey,
      appBar: AppBar(
        title: Text('${widget.intern.firstName} ${widget.intern.lastName}', style: TextStyle(fontSize: 18)),
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
              onPressed: () => AppNavigator.push(context: context, page: InternForm(userModel: widget.intern, onFinish:() => setState(() {}))),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: internViewSelectBody(),
    );
  }

  void delete(){
    Future.delayed(Duration(milliseconds: 250), (){
      showDialog(
        context: context,
        builder: (BuildContext dialogContext){
          return QuestionDialog(
            globalKey: _globalScaffoldKey,
            title: AppLocalizations.of(dialogContext).translate('delete_intern_alert'),
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

    dynamic result = await Provider.of<FirestoreService>(context, listen: false).deleteUser(uID: widget.intern.uID);
    if(result is bool && result){
      Provider.of<InternsViewModel>(context, listen: false).removeFromList(model: widget.intern);
      widget.onDelete();
      await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
      await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('delete_intern_success'));});
      await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
    }else{
      await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
      await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('delete_intern_fail'));});
    }
  }

  Widget internViewSelectBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Hero(
            tag: widget.intern.uID,
            child: Container(
                width: 130,
                height: 130,
                margin: EdgeInsets.only(top: 50),
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
                child: widget.intern.imageURL != null && widget.intern.imageURL != '' ? ClipRRect(
                  borderRadius: BorderRadius.circular(600),
                  child: CachedNetworkImage(
                    placeholder:(context, url) => Container(color: Colors.grey[200]),
                    imageUrl: widget.intern.imageURL,
                    width: 130,
                    height: 130,
                    fit: BoxFit.fitHeight,
                  ),
                ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(color: Colors.grey[200], child: Center(child: Text(widget.intern.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none)))))
            ),
          ),
        ),

        SizedBox(height: 20),
        Text('${widget.intern.firstName} ${widget.intern.lastName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        SizedBox(height: 30),
        Text(AppLocalizations.of(context).translate('what_to_view'), style: TextStyle(fontSize: 18, color: Colors.grey[500])),
        SizedBox(height: 90),
        SizedBox(
          width: 210,
          height: 55,
          child: OutlinedButton(
              onPressed: () async{
                await Future.delayed(Duration(milliseconds: 200));
                AppNavigator.push(context: context, page: ClocksDetail(intern: widget.intern));
              },
              child: Text(AppLocalizations.of(context).translate('clock_in_out'), style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.normal)),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1, color: AppColors.primaryColor),
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
              )
          ),
        ),

        SizedBox(height: 20),
        Text(AppLocalizations.of(context).translate('or'), style: TextStyle(fontSize: 18, color: Colors.grey[500])),
        SizedBox(height: 20),

        SizedBox(
          width: 210,
          height: 55,
          child: OutlinedButton(
              onPressed: () async{
                await Future.delayed(Duration(milliseconds: 200));
                AppNavigator.push(context: context, page: ContactInfo(userModel: widget.intern, isIntern: true));
              },
              child: Text(AppLocalizations.of(context).translate('contact_info'), style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.normal)),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1, color: AppColors.primaryColor),
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
              )
          ),
        ),

        SizedBox(height: 20)
      ],
    );
  }

}
