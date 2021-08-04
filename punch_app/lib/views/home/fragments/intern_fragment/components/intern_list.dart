import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../helpers/app_navigator.dart';
import '../../../../../views/intern_view_select/intern_view_select.dart';
import '../../../../../helpers/app_localizations.dart';
import '../../../../../helpers/fading_edge_scrollview.dart';
import '../../../../../models/user_model.dart';

class InternList extends StatefulWidget {
  @override
  _InternListState createState() => _InternListState();
}

class _InternListState extends State<InternList> {

  void rebuildView() async{
    // rebuild every 10 seconds to calculate interns times
    await Future.delayed(Duration(seconds: 10));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final DateTime date = DateTime.now();
    String day = DateFormat('EEEE').format(date).substring(0,3).toLowerCase();

    final internList = Provider.of<List<UserModel>>(context);

    List<UserModel> clockedInterns = [];
    List<UserModel> notClockedInterns = [];

    if(internList != null && internList.isEmpty){
      return notFoundView();
    }

    if(internList != null){
      internList.forEach((intern) {

        int inTimeSt = -1;

        final format = DateFormat("HH:mm");
        DateTime clockIn;
        DateTime clockOut;
        DateTime clockInDate;
        DateTime clockOutDate;

        // -------  check if any users clocked in today whether or not in their schedule ---------
        if(intern.clocks[day]['clock_in'] != null){
          clockIn = format.parse(DateFormat.Hm().format(intern.clocks[day]['clock_in'].toDate()));
          clockInDate = DateTime.parse(intern.clocks[day]['clock_in'].toDate().toString());
        }

        if(intern.clocks[day]['clock_out'] != null){
          clockOut = format.parse(DateFormat.Hm().format(intern.clocks[day]['clock_out'].toDate()));
          clockOutDate = DateTime.parse(intern.clocks[day]['clock_out'].toDate().toString());
        }

        if(clockIn != null && clockInDate.year == date.year && clockInDate.day == date.day){
          if(clockOut != null && clockOutDate.year == date.year && clockOutDate.day == date.day){
            inTimeSt = -1;
          }else{
            inTimeSt = 1;
          }
        }
        // ----------------

        // check user clockout time in their schedule

        if(intern.schedules[day] != null){

          Iterable schedules = intern.schedules[day];

          schedules.forEach((element) {
            final format = DateFormat("HH:mm");
            DateTime inTime;
            DateTime outTime;
            DateTime nowTime = format.parse(DateFormat.Hm().format(date));

            if(element['clockIn'] != null && element['clockOut'] != null){

              inTime = format.parse(DateFormat.Hm().format(element['clockIn'].toDate()));
              outTime = format.parse(DateFormat.Hm().format(element['clockOut'].toDate()));

              if(clockIn != null && clockInDate.year == date.year && clockInDate.day == date.day){
                inTimeSt = 1;
              }else{
                if(nowTime.isAfter(inTime) && nowTime.isBefore(outTime)){
                  inTimeSt = 0;
                }else{
                  inTimeSt = -1;
                }
              }

              if(clockOut != null && clockOutDate.year == date.year && clockOutDate.day == date.day){
                if(clockOut.isBefore(outTime)){
                  inTimeSt = 0;
                }else{
                  inTimeSt = -1;
                }
              }
            }

          });
        }

        if(inTimeSt == 0){
          notClockedInterns.add(intern);
        }else if(inTimeSt == 1){
          clockedInterns.add(intern);
        }

      });
    }

    if(clockedInterns.isEmpty && notClockedInterns.isEmpty){
      return notFoundView();
    }

    rebuildView();

    return FadeIn(
      child: Container(
          child: FadingEdgeScrollView.fromListView(
              child: ListView(
                controller: ScrollController(),
                physics: BouncingScrollPhysics(),
                children: [

                  notClockedInterns != null && notClockedInterns.isNotEmpty ? Column(
                    children: [

                      SizedBox(height: 30),
                      Text(AppLocalizations.of(context).translate('interns_not_check_in_title'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[500]), textAlign: TextAlign.center),
                      SizedBox(height: 20),

                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(12),
                        itemCount: notClockedInterns.length,
                        scrollDirection: Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20),
                        itemBuilder: (BuildContext context, int index) {

                          if(notClockedInterns.isEmpty){
                            return notFoundView();
                          }

                          var intern = notClockedInterns[index];

                          return Hero(
                            tag: intern.uID,
                            child: GestureDetector(
                              onTap: (){
                                AppNavigator.push(context: context, page: InternViewSelect(intern: intern));
                              },
                              child: Stack(
                                children: [
                                  Container(
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
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(intern.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 8,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: new BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ) : Container(),

                  clockedInterns != null && clockedInterns.isNotEmpty ? Column(
                    children: [

                      SizedBox(height: notClockedInterns.isEmpty ? 30 : 50),
                      Text(AppLocalizations.of(context).translate('interns_check_in_title'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[500]), textAlign: TextAlign.center),
                      SizedBox(height: 20),

                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(12),
                        itemCount: clockedInterns.length,
                        scrollDirection: Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20),
                        itemBuilder: (BuildContext context, int index) {

                          var intern = clockedInterns[index];

                          return Hero(
                            tag: intern.uID,
                            child: GestureDetector(
                              onTap: (){
                                AppNavigator.push(context: context, page: InternViewSelect(intern: intern));
                              },
                              child: Stack(
                                children: [
                                  Container(
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
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(intern.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 8,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: new BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ) : Container(),

                  SizedBox(height: 60),
                ],
              )
          )
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
}