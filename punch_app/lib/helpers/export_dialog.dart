import 'package:flutter/material.dart';
import '../helpers/app_localizations.dart';

class ExportDialog extends StatefulWidget {

  final Function onWeekly;
  final Function onMonthly;
  final Function onYearly;
  final GlobalKey<ScaffoldState> globalKey;

  ExportDialog({ @required this.globalKey, this.onWeekly, this.onYearly, this.onMonthly });

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation<double> scaleAnimation;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (widget.globalKey != null) {
      widget.globalKey.currentState.hideCurrentSnackBar();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.linearToEaseOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  //height: 214,
                  height: 263,
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          height: 70,
                          color: Colors.white,
                          child: Center(
                            child: Text(AppLocalizations.of(context).translate('export_csv_file'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
                          )
                      ),
                      Divider(height: 0, color: Colors.grey[300], thickness: 0.5),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 48,
                        child: FlatButton(
                            onPressed: (){
                              widget.onWeekly();
                              Future.delayed(Duration(milliseconds: 300), (){
                                Navigator.pop(context);
                              });
                            },
                            child: Text(AppLocalizations.of(context).translate('weekly'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                        ),
                      ),
                      Divider(height: 0, color: Colors.grey[300], thickness: 0.5),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 48,
                        child: FlatButton(
                            onPressed: (){
                              widget.onMonthly();
                              Future.delayed(Duration(milliseconds: 300), (){
                                Navigator.pop(context);
                              });
                            },
                            child: Text(AppLocalizations.of(context).translate('monthly'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                        ),
                      ),
                      Divider(height: 0, color: Colors.grey[300], thickness: 0.5),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 48,
                        child: FlatButton(
                            onPressed: (){
                              widget.onYearly();
                              Future.delayed(Duration(milliseconds: 300), (){
                                Navigator.pop(context);
                              });
                            },
                            child: Text(AppLocalizations.of(context).translate('all_time'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                        ),
                      ),
                      Divider(height: 0, color: Colors.grey[300], thickness: 0.5),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 48,
                        child: FlatButton(
                            onPressed: (){
                              Future.delayed(Duration(milliseconds: 300), (){
                                Navigator.pop(context);
                              });
                            },
                            child: Text(AppLocalizations.of(context).translate('cancel'), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.red[600]), textAlign: TextAlign.center)
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}