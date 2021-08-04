import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'package:punch_app/services/firestore_service.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../../../database/storage.dart';
import '../../../helpers/uppercase_text_formatter.dart';
import '../../../helpers/loading_dialog.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import '../../../helpers/app_localizations.dart';
import '../../../helpers/app_text_field.dart';
import '../../../helpers/fading_edge_scrollview.dart';
import '../../../helpers/message.dart';
import '../../../helpers/progress_button.dart';
import '../../../view_models/user_view_model.dart';

class RegCodeFragment extends StatefulWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  final Function() onFinish;
  RegCodeFragment({ this.globalScaffoldKey, this.onFinish });

  @override
  _RegCodeFragmentState createState() => _RegCodeFragmentState();
}


class _RegCodeFragmentState extends State<RegCodeFragment> with TickerProviderStateMixin{

  final _formKey = GlobalKey<FormState>();
  final Storage storage = new Storage();
  AnimationController _buttonAnimationController;
  ScrollController scrollController = ScrollController();

  String regCode;
  bool regCodeSt, submitSt = true, counterSt = false;
  String code, email;

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
    return FocusWatcher(child: Scaffold(body: regCodeFragmentBody(), resizeToAvoidBottomInset: false));
  }

  Widget regCodeFragmentBody(){

    String name = '';
    code = Provider.of<UserViewModel>(context, listen: false).regCode;
    email = Provider.of<UserViewModel>(context, listen: false).email;

    if(Provider.of<UserViewModel>(context, listen: false).firstName != '' && Provider.of<UserViewModel>(context, listen: false).lastName != ''){
       name = capitalize(Provider.of<UserViewModel>(context, listen: false).firstName) + ' ' + capitalize(Provider.of<UserViewModel>(context, listen: false).lastName);
    }

    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: FadeInUp(
          from: 10,
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 30 ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).translate('hi'), style: TextStyle(fontSize: 60, color: Colors.grey[600])),
                Text(name, style: TextStyle(fontSize: 30, color: Colors.grey[600])),
                SizedBox(height: 20),
                Text(AppLocalizations.of(context).translate('we_are_exited'), style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                SizedBox(height: 40),
                Text(AppLocalizations.of(context).translate('reg_code_title'), style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(

                      children: <Widget>[

                        AppTextField(
                          isEnable: regCodeSt,
                          labelText: AppLocalizations.of(context).translate('registration_code'),
                          textInputFormatter: [FilteringTextInputFormatter.deny(RegExp('[ ]')), UpperCaseTextFormatter()],
                          inputAction: TextInputAction.done,
                          onValidate: (value){

                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('registration_code_empty_validate');
                            }
                            return null;
                          },

                          onFieldSubmitted: (value){
                            regCode = value;
                            submitForm();
                          },

                          onChanged: (value){
                            regCode = value;
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
                            child: Text(AppLocalizations.of(context).translate('verify_code'), style:  TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                            onPressed: (AnimationController controller) {
                              if(submitSt){
                                submitForm();
                              }
                            },
                          ),
                        ),

                        SizedBox(height: 60),

                        Text(AppLocalizations.of(context).translate('not_receive_code'), style: TextStyle(fontSize: 14, color: Colors.grey[500])),

                        SizedBox(height: 10),

                        counterSt == false ? SizedBox(
                            height: 40,
                            width: 200,
                            child: TextButton(
                              onPressed: submitSt ? (){
                                sendEmail();
                              } : null,
                              child: Text(AppLocalizations.of(context).translate('send_code_again'), style: TextStyle(color: AppColors.primaryColor, fontSize: 14, fontWeight: FontWeight.normal)),
                            )
                        ) : Container(
                          margin: EdgeInsets.only(top: 12),
                          child: Countdown(
                            seconds: 59,
                            build: (BuildContext context, double time) {
                              var minutes = (time.toInt() % 3600 ~/ 60).toInt().toString().padLeft(2, '0');
                              var seconds = (time.toInt() % 60).toInt().toString().padLeft(2, '0');
                              return Text("$minutes:$seconds", style: TextStyle(fontSize: 14, color: Colors.grey[600]));
                            },
                            interval: Duration(milliseconds: 100),
                            onFinished: () {
                              print('Timer is done!');
                              setState(() { counterSt = false; });
                            },
                          ),
                        ),

                        SizedBox(height: 20)

                      ],

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendEmail() async{
    Future.delayed(Duration(milliseconds: 250), (){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return LoadingDialog();
        },
      );
    });

    await Provider.of<UserViewModel>(context, listen: false).sendEmail( message: 'Your registration code is: $code', email: email);
    await Future.delayed(Duration(milliseconds: 1500), (){
      Navigator.pop(context);
    });
    await Future.delayed(Duration(milliseconds: 800), (){
      Message.show(widget.globalScaffoldKey, AppLocalizations.of(context).translate('email_sent'));
    });

    setState(() { counterSt = true; });
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {

      _buttonAnimationController.forward();

      setState(() {
        regCodeSt = false;
        submitSt = false;
      });
      
      try{
        await Future.delayed(Duration(milliseconds: 2500));
        if(code.toUpperCase() == regCode.toUpperCase()){
          await Provider.of<FirestoreService>(context, listen: false).updateVerified(uID: Provider.of<UserViewModel>(context, listen: false).uID);
          storage.saveBool('verified', true);
          widget.onFinish();
        }else{
          setState(() {
            regCodeSt = true;
            submitSt = true;
          });

          _buttonAnimationController.reverse();
          Message.show(widget.globalScaffoldKey, AppLocalizations.of(context).translate('code_not_correct'));
        }
      }catch(error){
        if(!AppConfig.isPublished){
          print('$error');
        }

        setState(() {
          regCodeSt = true;
          submitSt = true;
        });

        _buttonAnimationController.reverse();
        Message.show(widget.globalScaffoldKey, error);
      }
    }
  }

  String capitalize(String value) {
    return "${value[0].toUpperCase()}${value.substring(1)}";
  }
}