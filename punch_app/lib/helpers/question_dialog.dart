import 'package:flutter/material.dart';

class QuestionDialog extends StatefulWidget {

  final String title;
  final Function onYes;
  final Function onNo;
  final GlobalKey<ScaffoldState> globalKey;

  QuestionDialog({ @required this.globalKey, @required this.title, this.onYes, this.onNo });

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation<double> scaleAnimation;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
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
                  height: 138,
                  child: Column(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          width: double.infinity,
                          height: 90,
                          color: Colors.white,
                          child: Center(
                            child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
                          )
                      ),
                      Divider(height: 0, color: Colors.grey[300], thickness: 0.5),
                      Container(
                        color: Colors.grey[300],
                        child: Row(
                          children: <Widget>[

                            Expanded(
                              child: Container(
                                color: Colors.white,
                                height: 48,
                                child: FlatButton(
                                    onPressed: (){
                                      if(widget.onNo != null){
                                        widget.onNo();
                                      }

                                      Future.delayed(Duration(milliseconds: 300), (){
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text('No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                                ),
                              ),
                            ),

                            SizedBox(width: 0.5),

                            Expanded(
                              child: Container(
                                color: Colors.white,
                                height: 48,
                                child: FlatButton(
                                    onPressed: (){
                                      widget.onYes();
                                      Future.delayed(Duration(milliseconds: 300), (){
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text('Yes', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center)
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
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