import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../helpers/app_text_area.dart';
import '../../helpers/app_text_field.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../helpers/loading_dialog.dart';
import '../../helpers/message.dart';
import '../../services/firestore_service.dart';
import '../../view_models/companies_view_model.dart';
import '../../view_models/interns_view_model.dart';
import '../../helpers/app_localizations.dart';
import '../../models/user_model.dart';

class ContactForm extends StatefulWidget {

  final UserModel userModel;
  bool isIntern;
  final Function() onFinish;

  ContactForm({ this.userModel, this.onFinish, this.isIntern });

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {

  final _formKey = GlobalKey<FormState>();
  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  String phone, address;
  bool submitSt = true;

  @override
  void initState() {
    super.initState();

    if(widget.userModel != null){
      phone = widget.isIntern ? widget.userModel.mobile : widget.userModel.tel;
      address = widget.userModel.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        key: _globalScaffoldKey,
        appBar: AppBar(
          title: Text('${AppLocalizations.of(context).translate('edit')} ${AppLocalizations.of(context).translate('contact_info')}', style: TextStyle(fontSize: 18)),
          centerTitle: true,
          brightness: Brightness.dark,
          actions: [
            TextButton(
              onPressed: () {
                if(submitSt){
                  updateProfile();
                }
              },
              style: TextButton.styleFrom(
                shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                primary: Colors.white,
              ),
              child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: contactFormBody(),
      ),
    );
  }

  Widget contactFormBody(){
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: FadeInUp(
          from: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
            child: Column(
              children: [

                Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: MediaQuery.of(context).size.width,
                    child: Column(

                      children: <Widget>[

                        AppTextField(
                          isEnable: submitSt,
                          labelText: AppLocalizations.of(context).translate('phone_number'),
                          textInputFormatter: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
                          inputAction: TextInputAction.next,
                          value: phone,
                          textInputType: TextInputType.phone,
                          onChanged: (value){
                            phone = value;
                          },
                        ),

                        SizedBox(height: 20)

                      ],

                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateProfile() async{

    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      Future.delayed(Duration(milliseconds: 250), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingDialog();
          },
        );
      });

      setState(() {
        submitSt = false;
      });

      try{

        UserModel model = widget.userModel;

        if(widget.isIntern){
          model.mobile = phone != null ? phone.trim() : null;
          widget.userModel.mobile = phone != null ? phone.trim() : null;
        }else{
          model.tel = phone != null ? phone.trim() : null;
          widget.userModel.tel = phone != null ? phone.trim() : null;
        }
        model.address = address != null ? address?.trim() : null;
        widget.userModel.address = address != null ? address?.trim() : null;

        dynamic result = await Provider.of<FirestoreService>(context, listen: false).updateContactInfo(userModel: model, isIntern: widget.isIntern);

        if(result is bool && result){
          if(widget.isIntern){
            Provider.of<InternsViewModel>(context, listen: false).updateList(model: model);
          }else{
            Provider.of<CompaniesViewModel>(context, listen: false).updateList(model: model);
          }

          await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
          await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('contact_update_success'));});
          await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
          widget.onFinish();
        }else{
          setState(() {
            submitSt = true;
          });
          widget.onFinish();
          await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
          await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('contact_update_fail'));});
        }

      }catch(error){
        if(!AppConfig.isPublished){
          print('$error');
        }

        setState(() {
          submitSt = true;
        });

        await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
        await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('contact_update_fail'));});
      }
    }
  }
}
