
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ExportViewModel extends ChangeNotifier{
  // Weekly reports

  Future<dynamic> fetchAllCompaniesWeeklyData({ String uID, File localFile }) async {
    DateTime date = DateTime.now();
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    DateTime lastDayOfWeek = date.subtract(Duration(days: date.weekday - 5));

    Timestamp startDate = Timestamp.fromDate(
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day)
    );
    Timestamp endDate = Timestamp.fromDate(
        DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day)
    );

    try{
      final result =  await FirestoreService().getCompanies(uID: uID);

      List<UserModel> companyList = result.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

      List<List<dynamic>> rows = [];

      rows.add(["Companies", "", "Mon", "", "Tues", "", "Wed", "", "Thurs", "", "Fri", "", "Total", "", "Schedule", "",]);
      rows.add(["", "Interns", "In", "Out", "In", "Out", "In", "Out", "In", "Out", "In", "Out", "", "",]);

      for (int i = 0; i < companyList.length; i++) {
        List<UserModel> internList = [];
        List<dynamic> row = [];

        rows.add([companyList[i].companyName]);

        final internResult =  await FirestoreService().getInternsByCompanyID(uID: companyList[i].uID);

        if(internResult != null){
          internList = internResult.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

          await Future.forEach(internList, (UserModel intern) async{

            // user's schedule
            Duration schTotal;
            intern.schedules.forEach((key, value) {
              if(key != 'sat' && key != 'sun') {
                Iterable schArr = intern.schedules[key];
                schArr.forEach((element) {
                  if (element['clockIn'] != null &&
                      element['clockOut'] != null) {
                    var cIn = DateTime.parse(element['clockIn']
                        .toDate()
                        .toString());
                    var cOut = DateTime.parse(element['clockOut']
                        .toDate()
                        .toString());

                    if (schTotal != null) {
                      schTotal = schTotal + cOut.difference(cIn);
                    } else {
                      schTotal = cOut.difference(cIn);
                    }
                  }
                });
              }
            });

            // clocks history
            dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
                uID: intern.uID,
                startDate: startDate,
                endDate: endDate
            );

            String monStringClockIn = '';
            String monStringClockOut = '';

            String tuesStringClockIn = '';
            String tuesStringClockOut = '';

            String wedStringClockIn = '';
            String wedStringClockOut = '';

            String thursStringClockIn = '';
            String thursStringClockOut = '';

            String friStringClockIn = '';
            String friStringClockOut = '';
            Duration total;

            if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
              List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
              queryDocumentSnapshot.forEach((document) {
                DateTime docDate = DateTime.parse(document['date'].toDate().toString());
                Iterable arr = document['clocks'];
                arr.forEach((element) {
                  var cIn, cOut;
                  if(element['clock_in'] != null){
                    cIn = DateTime.parse(element['clock_in'].toDate().toString());
                  }
                  if(element['clock_out'] != null){
                    cOut = DateTime.parse(element['clock_out'].toDate().toString());
                  }
                  if(cIn != null && cOut != null){
                    if(total != null){
                      total = total + cOut.difference(cIn);
                    }else{
                      total = cOut.difference(cIn);
                    }
                  }
                  if(cIn != null){
                    if(docDate.weekday == 1){monStringClockIn = DateFormat('hh:mm a').format(cIn);}
                    if(docDate.weekday == 2){tuesStringClockIn = DateFormat('hh:mm a').format(cIn);}
                    if(docDate.weekday == 3){wedStringClockIn = DateFormat('hh:mm a').format(cIn);}
                    if(docDate.weekday == 4){thursStringClockIn = DateFormat('hh:mm a').format(cIn);}
                    if(docDate.weekday == 5){friStringClockIn = DateFormat('hh:mm a').format(cIn);}
                    /*if(docDate.weekday == 1){monStringClockIn = monStringClockIn + '${cIn.hour}:${cIn.minute}' + '\n';}
                    if(docDate.weekday == 2){tuesStringClockIn = tuesStringClockIn + '${cIn.hour}:${cIn.minute}' + '\n';}
                    if(docDate.weekday == 3){wedStringClockIn = wedStringClockIn + '${cIn.hour}:${cIn.minute}' + '\n';}
                    if(docDate.weekday == 4){thursStringClockIn = thursStringClockIn + '${cIn.hour}:${cIn.minute}' + '\n';}
                    if(docDate.weekday == 5){friStringClockIn = friStringClockIn + '${cIn.hour}:${cIn.minute}' + '\n';}*/
                  }
                  if(cOut != null){
                    if(docDate.weekday == 1){monStringClockOut = DateFormat('hh:mm a').format(cOut);}
                    if(docDate.weekday == 2){tuesStringClockOut = DateFormat('hh:mm a').format(cOut);}
                    if(docDate.weekday == 3){wedStringClockOut = DateFormat('hh:mm a').format(cOut);}
                    if(docDate.weekday == 4){thursStringClockOut = DateFormat('hh:mm a').format(cOut);}
                    if(docDate.weekday == 5){friStringClockOut = DateFormat('hh:mm a').format(cOut);}
                  }
                });
              });
            }

            rows.add([
              "",
              intern.firstName + ' ' + intern.lastName,
              monStringClockIn     != '' ? monStringClockIn : '-',
              monStringClockOut    != '' ? monStringClockOut : '-',
              tuesStringClockIn    != '' ? tuesStringClockIn : '-',
              tuesStringClockOut   != '' ? tuesStringClockOut : '-',
              wedStringClockIn     != '' ? wedStringClockIn : '-',
              wedStringClockOut    != '' ? wedStringClockOut : '-',
              thursStringClockIn   != '' ? thursStringClockIn : '-',
              thursStringClockOut  != '' ? thursStringClockOut : '-',
              friStringClockIn     != '' ? friStringClockIn : '-',
              friStringClockOut    != '' ? friStringClockOut : '-',
              total != null ? total : '-',
              "",
              schTotal != null ? schTotal : '-',
              ""
            ]);
          });
        }
        row.add("");
        rows.add(row);
      }

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }
  Future<dynamic> fetchCompanyWeeklyData({ UserModel company, File localFile }) async {

    DateTime date = DateTime.now();
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    DateTime lastDayOfWeek = date.subtract(Duration(days: date.weekday - 5));

    Timestamp startDate = Timestamp.fromDate(
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day)
    );
    Timestamp endDate = Timestamp.fromDate(
        DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day)
    );

    try{

      List<List<dynamic>> rows = [];

      rows.add(["Company", "", "Mon", "", "Tues", "", "Wed", "", "Thurs", "", "Fri", "", "Total", "", "Schedule", "",]);
      rows.add(["", "Interns", "In", "Out", "In", "Out", "In", "Out", "In", "Out", "In", "Out", "", "",]);

      List<UserModel> internList = [];
      List<dynamic> row = [];

      rows.add([company.companyName]);

      final internResult =  await FirestoreService().getInternsByCompanyID(uID: company.uID);

      if(internResult != null){
        internList = internResult.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

        await Future.forEach(internList, (UserModel intern) async{

          // user's schedule
          Duration schTotal;
          intern.schedules.forEach((key, value) {
            if(key != 'sat' && key != 'sun') {
              Iterable schArr = intern.schedules[key];
              schArr.forEach((element) {
                if (element['clockIn'] != null &&
                    element['clockOut'] != null) {
                  var cIn = DateTime.parse(element['clockIn']
                      .toDate()
                      .toString());
                  var cOut = DateTime.parse(element['clockOut']
                      .toDate()
                      .toString());

                  if (schTotal != null) {
                    schTotal = schTotal + cOut.difference(cIn);
                  } else {
                    schTotal = cOut.difference(cIn);
                  }
                }
              });
            }
          });

          // clocks history
          dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
              uID: intern.uID,
              startDate: startDate,
              endDate: endDate
          );

          String monStringClockIn = '';
          String monStringClockOut = '';

          String tuesStringClockIn = '';
          String tuesStringClockOut = '';

          String wedStringClockIn = '';
          String wedStringClockOut = '';

          String thursStringClockIn = '';
          String thursStringClockOut = '';

          String friStringClockIn = '';
          String friStringClockOut = '';

          Duration total;

          if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
            List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
            queryDocumentSnapshot.forEach((document) {
              DateTime docDate = DateTime.parse(document['date'].toDate().toString());
              Iterable arr = document['clocks'];
              arr.forEach((element) {
                var cIn, cOut;
                if(element['clock_in'] != null){
                  cIn = DateTime.parse(element['clock_in'].toDate().toString());
                }
                if(element['clock_out'] != null){
                  cOut = DateTime.parse(element['clock_out'].toDate().toString());
                }
                if(cIn != null && cOut != null){
                  if(total != null){
                    total = total + cOut.difference(cIn);
                  }else{
                    total = cOut.difference(cIn);
                  }
                }
                if(cIn != null){
                  if(docDate.weekday == 1){monStringClockIn = DateFormat('hh:mm a').format(cIn);}
                  if(docDate.weekday == 2){tuesStringClockIn = DateFormat('hh:mm a').format(cIn);}
                  if(docDate.weekday == 3){wedStringClockIn = DateFormat('hh:mm a').format(cIn);}
                  if(docDate.weekday == 4){thursStringClockIn = DateFormat('hh:mm a').format(cIn);}
                  if(docDate.weekday == 5){friStringClockIn = DateFormat('hh:mm a').format(cIn);}
                }
                if(cOut != null){
                  if(docDate.weekday == 1){monStringClockOut = DateFormat('hh:mm a').format(cOut);}
                  if(docDate.weekday == 2){tuesStringClockOut = DateFormat('hh:mm a').format(cOut);}
                  if(docDate.weekday == 3){wedStringClockOut = DateFormat('hh:mm a').format(cOut);}
                  if(docDate.weekday == 4){thursStringClockOut = DateFormat('hh:mm a').format(cOut);}
                  if(docDate.weekday == 5){friStringClockOut = DateFormat('hh:mm a').format(cOut);}
                }
              });
            });
          }

          rows.add([
            "",
            intern.firstName + ' ' + intern.lastName,
            monStringClockIn     != '' ? monStringClockIn : '-',
            monStringClockOut    != '' ? monStringClockOut : '-',
            tuesStringClockIn    != '' ? tuesStringClockIn : '-',
            tuesStringClockOut   != '' ? tuesStringClockOut : '-',
            wedStringClockIn     != '' ? wedStringClockIn : '-',
            wedStringClockOut    != '' ? wedStringClockOut : '-',
            thursStringClockIn   != '' ? thursStringClockIn : '-',
            thursStringClockOut  != '' ? thursStringClockOut : '-',
            friStringClockIn     != '' ? friStringClockIn : '-',
            friStringClockOut    != '' ? friStringClockOut : '-',
            total != null ? total : '-',
            "",
            schTotal != null ? schTotal : '-',
            ""
          ]);
        });
      }
      row.add("");
      rows.add(row);

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }
  Future<dynamic> fetchInternWeeklyData({ UserModel intern, File localFile }) async {

    DateTime date = DateTime.now();
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    DateTime lastDayOfWeek = date.subtract(Duration(days: date.weekday - 5));

    Timestamp startDate = Timestamp.fromDate(
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day)
    );
    Timestamp endDate = Timestamp.fromDate(
        DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day)
    );

    try{

      List<List<dynamic>> rows = [];

      rows.add(["", "Mon", "", "Tues", "", "Wed", "", "Thurs", "", "Fri", "", "Total", "", "Schedule", "",]);
      rows.add(["Intern", "In", "Out", "In", "Out", "In", "Out", "In", "Out", "In", "Out", "", "",]);

      List<dynamic> row = [];

      // user's schedule
      Duration schTotal;
      intern.schedules.forEach((key, value) {
        if(key != 'sat' && key != 'sun') {
          Iterable schArr = intern.schedules[key];
          schArr.forEach((element) {
            if (element['clockIn'] != null &&
                element['clockOut'] != null) {
              var cIn = DateTime.parse(element['clockIn']
                  .toDate()
                  .toString());
              var cOut = DateTime.parse(element['clockOut']
                  .toDate()
                  .toString());

              if (schTotal != null) {
                schTotal = schTotal + cOut.difference(cIn);
              } else {
                schTotal = cOut.difference(cIn);
              }
            }
          });
        }
      });

      // clocks history
      dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
          uID: intern.uID,
          startDate: startDate,
          endDate: endDate
      );

      String monStringClockIn = '';
      String monStringClockOut = '';

      String tuesStringClockIn = '';
      String tuesStringClockOut = '';

      String wedStringClockIn = '';
      String wedStringClockOut = '';

      String thursStringClockIn = '';
      String thursStringClockOut = '';

      String friStringClockIn = '';
      String friStringClockOut = '';

      Duration total;

      if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
        List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
        queryDocumentSnapshot.forEach((document) {
          DateTime docDate = DateTime.parse(document['date'].toDate().toString());
          Iterable arr = document['clocks'];
          arr.forEach((element) {
            var cIn, cOut;
            if(element['clock_in'] != null){
              cIn = DateTime.parse(element['clock_in'].toDate().toString());
            }
            if(element['clock_out'] != null){
              cOut = DateTime.parse(element['clock_out'].toDate().toString());
            }
            if(cIn != null && cOut != null){
              if(total != null){
                total = total + cOut.difference(cIn);
              }else{
                total = cOut.difference(cIn);
              }
            }
            if(cIn != null){
              if(docDate.weekday == 1){monStringClockIn = DateFormat('hh:mm a').format(cIn);}
              if(docDate.weekday == 2){tuesStringClockIn = DateFormat('hh:mm a').format(cIn);}
              if(docDate.weekday == 3){wedStringClockIn = DateFormat('hh:mm a').format(cIn);}
              if(docDate.weekday == 4){thursStringClockIn = DateFormat('hh:mm a').format(cIn);}
              if(docDate.weekday == 5){friStringClockIn = DateFormat('hh:mm a').format(cIn);}
            }
            if(cOut != null){
              if(docDate.weekday == 1){monStringClockOut = DateFormat('hh:mm a').format(cOut);}
              if(docDate.weekday == 2){tuesStringClockOut = DateFormat('hh:mm a').format(cOut);}
              if(docDate.weekday == 3){wedStringClockOut = DateFormat('hh:mm a').format(cOut);}
              if(docDate.weekday == 4){thursStringClockOut = DateFormat('hh:mm a').format(cOut);}
              if(docDate.weekday == 5){friStringClockOut = DateFormat('hh:mm a').format(cOut);}
            }
          });
        });
      }

      rows.add([
        intern.firstName + ' ' + intern.lastName,
        monStringClockIn     != '' ? monStringClockIn : '-',
        monStringClockOut    != '' ? monStringClockOut : '-',
        tuesStringClockIn    != '' ? tuesStringClockIn : '-',
        tuesStringClockOut   != '' ? tuesStringClockOut : '-',
        wedStringClockIn     != '' ? wedStringClockIn : '-',
        wedStringClockOut    != '' ? wedStringClockOut : '-',
        thursStringClockIn   != '' ? thursStringClockIn : '-',
        thursStringClockOut  != '' ? thursStringClockOut : '-',
        friStringClockIn     != '' ? friStringClockIn : '-',
        friStringClockOut    != '' ? friStringClockOut : '-',
        total != null ? total : '-',
        "",
        schTotal != null ? schTotal : '-',
        ""
      ]);

      row.add("");
      rows.add(row);

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }

  // Monthly reports

  Future<dynamic> fetchAllCompaniesMonthlyData({ String uID, File localFile }) async {
    DateTime date = DateTime.now();
    var lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    
    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, date.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, date.month, lastDayOfMonth.day));

    Map<String, int> numberOfDays = occurrenceDaysInMonth(lastDayOfMonth.day, DateFormat('EEEE').format(DateTime(date.year, date.month, 1)));

    try{
      final result =  await FirestoreService().getCompanies(uID: uID);

      List<UserModel> companyList = result.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

      List<List<dynamic>> rows = [];

      rows.add(["Companies", "",
        "${date.month}/01-${date.month}/07",
        "${date.month}/08-${date.month}/14",
        "${date.month}/15-${date.month}/21",
        "${date.month}/22-${date.month}/28",
        "${date.month}/29-${date.month}/${lastDayOfMonth.day}",
        "", "Total", "", "Schedule", "",]);

      rows.add(["", "Interns"]);

      for (int i = 0; i < companyList.length; i++) {
        List<UserModel> internList = [];
        List<dynamic> row = [];

        rows.add([companyList[i].companyName]);

        final internResult =  await FirestoreService().getInternsByCompanyID(uID: companyList[i].uID);

        if(internResult != null){
          internList = internResult.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

          await Future.forEach(internList, (UserModel intern) async{

            // user's schedule
            Duration schTotal;
            intern.schedules.forEach((key, value) {
              switch(key){
                case 'mon':
                  Duration mon = getScheduleTotal(intern, key);
                  if(mon != null) {
                    for (int i = 1; i <= numberOfDays['Monday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + mon;
                      } else {
                        schTotal = mon;
                      }
                    }
                  }
                  break;
                case 'tue':
                  Duration tue = getScheduleTotal(intern, key);
                  if(tue != null) {
                    for (int i = 1; i <= numberOfDays['Tuesday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + tue;
                      } else {
                        schTotal = tue;
                      }
                    }
                  }
                  break;
                case 'wed':
                  Duration wed = getScheduleTotal(intern, key);
                  if(wed != null) {
                    for (int i = 1; i <= numberOfDays['Wednesday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + wed;
                      } else {
                        schTotal = wed;
                      }
                    }
                  }
                  break;
                case 'thu':
                  Duration thu = getScheduleTotal(intern, key);
                  if(thu != null) {
                    for (int i = 1; i <= numberOfDays['Thursday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + thu;
                      } else {
                        schTotal = thu;
                      }
                    }
                  }
                  break;
                case 'fri':
                  Duration fri = getScheduleTotal(intern, key);
                  if(fri != null) {
                    for (int i = 1; i <= numberOfDays['Friday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + fri;
                      } else {
                        schTotal = fri;
                      }
                    }
                  }
                  break;
              }
            });

            // clocks history
            dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
              uID: intern.uID,
              startDate: startDate,
              endDate: endDate
            );

            Duration total, weekOneTotal, weekTwoTotal, weekThreeTotal, weekFourTotal, weekFiveTotal;

            if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){

              List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
              queryDocumentSnapshot.forEach((document) {
                DateTime docDate = DateTime.parse(document['date'].toDate().toString());
                if(docDate.day < 8){weekOneTotal = getTotal(document, weekOneTotal);}
                if(docDate.day >= 8 && docDate.day <= 14){weekTwoTotal = getTotal(document, weekTwoTotal);}
                if(docDate.day >= 15 && docDate.day <= 21){weekThreeTotal = getTotal(document, weekThreeTotal);}
                if(docDate.day >= 22 && docDate.day <= 28){weekFourTotal = getTotal(document, weekFourTotal);}
                if(docDate.day >= 28){weekFiveTotal = getTotal(document, weekFiveTotal);}
                total = getTotal(document, total);
              });
            }

            rows.add([
              "",
              intern.firstName + ' ' + intern.lastName,
              weekOneTotal    != null ? weekOneTotal : '-',
              weekTwoTotal    != null ? weekTwoTotal : '-',
              weekThreeTotal  != null ? weekThreeTotal : '-',
              weekFourTotal   != null ? weekFourTotal : '-',
              weekFiveTotal   != null ? weekFiveTotal : '-',
              "",
              total != null ? total : '-',
              "",
              schTotal != null ? schTotal : '-',
              ""
            ]);
          });
        }
        row.add("");
        rows.add(row);
      }

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }
  Future<dynamic> fetchCompanyMonthlyData({ UserModel company, File localFile }) async {

    DateTime date = DateTime.now();

    var lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, date.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, date.month, lastDayOfMonth.day));

    Map<String, int> numberOfDays = occurrenceDaysInMonth(lastDayOfMonth.day, DateFormat('EEEE').format(DateTime(date.year, date.month, 1)));

    try{

      List<List<dynamic>> rows = [];

      rows.add(["Company", "",
        "${date.month}/01-${date.month}/07",
        "${date.month}/08-${date.month}/14",
        "${date.month}/15-${date.month}/21",
        "${date.month}/22-${date.month}/28",
        "${date.month}/29-${date.month}/${lastDayOfMonth.day}",
        "", "Total", "", "Schedule", "",]);

      rows.add(["", "Interns"]);

      List<UserModel> internList = [];
      List<dynamic> row = [];

      rows.add([company.companyName]);

      final internResult =  await FirestoreService().getInternsByCompanyID(uID: company.uID);

      if(internResult != null){
        internList = internResult.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

        await Future.forEach(internList, (UserModel intern) async{

          // user's schedule
          Duration schTotal;
          intern.schedules.forEach((key, value) {
            switch(key){
              case 'mon':
                Duration mon = getScheduleTotal(intern, key);
                if(mon != null) {
                  for (int i = 1; i <= numberOfDays['Monday']; i++) {
                    if (schTotal != null) {
                      schTotal = schTotal + mon;
                    } else {
                      schTotal = mon;
                    }
                  }
                }
                break;
              case 'tue':
                Duration tue = getScheduleTotal(intern, key);
                if(tue != null) {
                  for (int i = 1; i <= numberOfDays['Tuesday']; i++) {
                    if (schTotal != null) {
                      schTotal = schTotal + tue;
                    } else {
                      schTotal = tue;
                    }
                  }
                }
                break;
              case 'wed':
                Duration wed = getScheduleTotal(intern, key);
                if(wed != null){
                  for(int i = 1; i <= numberOfDays['Wednesday']; i++ ){
                    if(schTotal!= null){
                      schTotal = schTotal + wed;
                    }else{
                      schTotal = wed;
                    }
                  }
                }
                break;
              case 'thu':
                Duration thu = getScheduleTotal(intern, key);
                if(thu != null){
                  for(int i = 1; i <= numberOfDays['Thursday']; i++ ){
                    if(schTotal!= null){
                      schTotal = schTotal + thu;
                    }else{
                      schTotal = thu;
                    }
                  }
                }
                break;
              case 'fri':
                Duration fri = getScheduleTotal(intern, key);
                if(fri != null){
                  for(int i = 1; i <= numberOfDays['Friday']; i++ ){
                    if(schTotal!= null){
                      schTotal = schTotal + fri;
                    }else{
                      schTotal = fri;
                    }
                  }
                }
                break;
            }
          });

          // clocks history
          dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
              uID: intern.uID,
              startDate: startDate,
              endDate: endDate
          );

          Duration total, weekOneTotal, weekTwoTotal, weekThreeTotal, weekFourTotal, weekFiveTotal;

          if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
            List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
            queryDocumentSnapshot.forEach((document) {
              DateTime docDate = DateTime.parse(document['date'].toDate().toString());
              if(docDate.day < 8){weekOneTotal = getTotal(document, weekOneTotal);}
              if(docDate.day >= 8 && docDate.day <= 14){weekTwoTotal = getTotal(document, weekTwoTotal);}
              if(docDate.day >= 15 && docDate.day <= 21){weekThreeTotal = getTotal(document, weekThreeTotal);}
              if(docDate.day >= 22 && docDate.day <= 28){weekFourTotal = getTotal(document, weekFourTotal);}
              if(docDate.day >= 28){weekFiveTotal = getTotal(document, weekFiveTotal);}
              total = getTotal(document, total);
            });
          }

          rows.add([
            "",
            intern.firstName + ' ' + intern.lastName,
            weekOneTotal    != null ? weekOneTotal : '-',
            weekTwoTotal    != null ? weekTwoTotal : '-',
            weekThreeTotal  != null ? weekThreeTotal : '-',
            weekFourTotal   != null ? weekFourTotal : '-',
            weekFiveTotal   != null ? weekFiveTotal : '-',
            "",
            total != null ? total : '-',
            "",
            schTotal != null ? schTotal : '-',
            ""
          ]);
        });
      }
      row.add("");
      rows.add(row);

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      print('errorrrR: $error');
      return error.toString();
    }
  }
  Future<dynamic> fetchInternMonthlyData({ UserModel intern, File localFile }) async {

    DateTime date = DateTime.now();

    var lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, date.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, date.month, lastDayOfMonth.day));

    Map<String, int> numberOfDays = occurrenceDaysInMonth(lastDayOfMonth.day, DateFormat('EEEE').format(DateTime(date.year, date.month, 1)));

    try{

      List<List<dynamic>> rows = [];

      rows.add(["",
        "${date.month}/01-${date.month}/07",
        "${date.month}/08-${date.month}/14",
        "${date.month}/15-${date.month}/21",
        "${date.month}/22-${date.month}/28",
        "${date.month}/29-${date.month}/${lastDayOfMonth.day}",
        "", "Total", "", "Schedule", "",]);

      rows.add(["Intern"]);

      List<dynamic> row = [];

      // user's schedule
      Duration schTotal;
      intern.schedules.forEach((key, value) {
        switch(key){
          case 'mon':
            Duration mon = getScheduleTotal(intern, key);
            if(mon != null) {
              for (int i = 1; i <= numberOfDays['Monday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + mon;
                } else {
                  schTotal = mon;
                }
              }
            }
            break;
          case 'tue':
            Duration tue = getScheduleTotal(intern, key);
            if(tue != null) {
              for (int i = 1; i <= numberOfDays['Tuesday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + tue;
                } else {
                  schTotal = tue;
                }
              }
            }
            break;
          case 'wed':
            Duration wed = getScheduleTotal(intern, key);
            if(wed != null) {
              for (int i = 1; i <= numberOfDays['Wednesday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + wed;
                } else {
                  schTotal = wed;
                }
              }
            }
            break;
          case 'thu':
            Duration thu = getScheduleTotal(intern, key);
            if(thu != null) {
              for (int i = 1; i <= numberOfDays['Thursday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + thu;
                } else {
                  schTotal = thu;
                }
              }
            }
            break;
          case 'fri':
            Duration fri = getScheduleTotal(intern, key);
            if(fri != null) {
              for (int i = 1; i <= numberOfDays['Friday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + fri;
                } else {
                  schTotal = fri;
                }
              }
            }
            break;
        }
      });

      // clocks history
      dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
          uID: intern.uID,
          startDate: startDate,
          endDate: endDate
      );

      Duration total, weekOneTotal, weekTwoTotal, weekThreeTotal, weekFourTotal, weekFiveTotal;

      if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
        List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
        queryDocumentSnapshot.forEach((document) {
          DateTime docDate = DateTime.parse(document['date'].toDate().toString());
          if(docDate.day < 8){weekOneTotal = getTotal(document, weekOneTotal);}
          if(docDate.day >= 8 && docDate.day <= 14){weekTwoTotal = getTotal(document, weekTwoTotal);}
          if(docDate.day >= 15 && docDate.day <= 21){weekThreeTotal = getTotal(document, weekThreeTotal);}
          if(docDate.day >= 22 && docDate.day <= 28){weekFourTotal = getTotal(document, weekFourTotal);}
          if(docDate.day >= 28){weekFiveTotal = getTotal(document, weekFiveTotal);}
          total = getTotal(document, total);
        });
      }

      rows.add([
        intern.firstName + ' ' + intern.lastName,
        weekOneTotal    != null ? weekOneTotal : '-',
        weekTwoTotal    != null ? weekTwoTotal : '-',
        weekThreeTotal  != null ? weekThreeTotal : '-',
        weekFourTotal   != null ? weekFourTotal : '-',
        weekFiveTotal   != null ? weekFiveTotal : '-',
        "",
        total != null ? total : '-',
        "",
        schTotal != null ? schTotal : '-',
        ""
      ]);

      row.add("");
      rows.add(row);

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }

  // Yearly reports

  Future<dynamic> fetchAllCompaniesYearlyData({ String uID, File localFile }) async {
    DateTime date = DateTime.now();

    var lastDayOfMonth = DateTime(date.year, 12 + 1, 0);

    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, 12, lastDayOfMonth.day));

    Map<String, int> numberOfDays = occurrenceDaysInYear(date.year, DateFormat('EEEE').format(DateTime(date.year, 1, 1)));

    try{
      final result =  await FirestoreService().getCompanies(uID: uID);

      List<UserModel> companyList = result.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();
      List<List<dynamic>> rows = [];

      rows.add(["Companies", "",
        "January", "February", "March", "April", "May", "Jun", "July", "August", "September",
        "October", "November", "December",
        "", "Total", "", "Schedule", "",]);

      rows.add(["", "Interns"]);

      for (int i = 0; i < companyList.length; i++) {
        List<UserModel> internList = [];
        List<dynamic> row = [];

        rows.add([companyList[i].companyName]);

        final internResult =  await FirestoreService().getInternsByCompanyID(uID: companyList[i].uID);

        if(internResult != null){
          internList = internResult.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

          await Future.forEach(internList, (UserModel intern) async{

            // user's schedule
            Duration schTotal;
            intern.schedules.forEach((key, value) {
              switch(key){
                case 'mon':
                  Duration mon = getScheduleTotal(intern, key);
                  if(mon != null){
                    for(int i = 1; i <= numberOfDays['Monday']; i++ ){
                      if(schTotal!= null){
                        schTotal = schTotal + mon;
                      }else{
                        schTotal = mon;
                      }
                    }
                  }
                  break;
                case 'tue':
                  Duration tue = getScheduleTotal(intern, key);
                  if(tue != null) {
                    for (int i = 1; i <= numberOfDays['Tuesday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + tue;
                      } else {
                        schTotal = tue;
                      }
                    }
                  }
                  break;
                case 'wed':
                  Duration wed = getScheduleTotal(intern, key);
                  if(wed != null) {
                    for (int i = 1; i <= numberOfDays['Wednesday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + wed;
                      } else {
                        schTotal = wed;
                      }
                    }
                  }
                  break;
                case 'thu':
                  Duration thu = getScheduleTotal(intern, key);
                  if(thu != null) {
                    for (int i = 1; i <= numberOfDays['Thursday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + thu;
                      } else {
                        schTotal = thu;
                      }
                    }
                  }
                  break;
                case 'fri':
                  Duration fri = getScheduleTotal(intern, key);
                  if(fri != null) {
                    for (int i = 1; i <= numberOfDays['Friday']; i++) {
                      if (schTotal != null) {
                        schTotal = schTotal + fri;
                      } else {
                        schTotal = fri;
                      }
                    }
                  }
                  break;
              }
            });

            // clocks history
            dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
                uID: intern.uID,
                startDate: startDate,
                endDate: endDate
            );

            Duration total, monthOneTotal, monthTwoTotal, monthThreeTotal,
                monthFourTotal, monthFiveTotal, monthSixTotal, monthSevenTotal,
                monthEightTotal, monthNineTotal, monthTenTotal, monthElevenTotal,
                monthTwelveTotal;

            if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
              List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
              queryDocumentSnapshot.forEach((document) {
                DateTime docDate = DateTime.parse(document['date'].toDate().toString());
                if(docDate.month == 1){monthOneTotal = getTotal(document, monthOneTotal);}
                if(docDate.month == 2){monthTwoTotal = getTotal(document, monthTwoTotal);}
                if(docDate.month == 3){monthThreeTotal = getTotal(document, monthThreeTotal);}
                if(docDate.month == 4){monthFourTotal = getTotal(document, monthFourTotal);}
                if(docDate.month == 5){monthFiveTotal = getTotal(document, monthFiveTotal);}
                if(docDate.month == 6){monthSixTotal = getTotal(document, monthSixTotal);}
                if(docDate.month == 7){monthSevenTotal = getTotal(document, monthSevenTotal);}
                if(docDate.month == 8){monthEightTotal = getTotal(document, monthEightTotal);}
                if(docDate.month == 9){monthNineTotal = getTotal(document, monthNineTotal);}
                if(docDate.month == 10){monthTenTotal = getTotal(document, monthTenTotal);}
                if(docDate.month == 11){monthElevenTotal = getTotal(document, monthElevenTotal);}
                if(docDate.month == 12){monthTwelveTotal = getTotal(document, monthTwelveTotal);}
                total = getTotal(document, total);
              });
            }

            rows.add([
              "",
              intern.firstName + ' ' + intern.lastName,
              monthOneTotal      != null ? monthOneTotal : '-',
              monthTwoTotal      != null ? monthTwoTotal : '-',
              monthThreeTotal    != null ? monthThreeTotal : '-',
              monthFourTotal     != null ? monthFourTotal : '-',
              monthFiveTotal     != null ? monthFiveTotal : '-',
              monthSixTotal      != null ? monthSixTotal : '-',
              monthSevenTotal    != null ? monthSevenTotal : '-',
              monthEightTotal    != null ? monthEightTotal : '-',
              monthNineTotal     != null ? monthNineTotal : '-',
              monthTenTotal      != null ? monthTenTotal : '-',
              monthElevenTotal   != null ? monthElevenTotal : '-',
              monthTwelveTotal   != null ? monthTwelveTotal : '-',
              "",
              total != null ? total : '-',
              "",
              schTotal != null ? schTotal : '-',
              ""
            ]);
          });
        }
        row.add("");
        rows.add(row);
      }

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }
  Future<dynamic> fetchCompanyYearlyData({ UserModel company, File localFile }) async {

    DateTime date = DateTime.now();

    var lastDayOfMonth = DateTime(date.year, 12 + 1, 0);

    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, 12, lastDayOfMonth.day));

    Map<String, int> numberOfDays = occurrenceDaysInYear(date.year, DateFormat('EEEE').format(DateTime(date.year, 1, 1)));

    try{

      List<List<dynamic>> rows = [];

      rows.add(["Company", "",
        "January", "February", "March", "April", "May", "Jun", "July", "August", "September",
        "October", "November", "December",
        "", "Total", "", "Schedule", "",]);

      rows.add(["", "Interns"]);

      List<UserModel> internList = [];
      List<dynamic> row = [];

      rows.add([company.companyName]);

      final internResult =  await FirestoreService().getInternsByCompanyID(uID: company.uID);

      if(internResult != null){
        internList = internResult.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

        await Future.forEach(internList, (UserModel intern) async{

          // user's schedule
          Duration schTotal;
          intern.schedules.forEach((key, value) {
            switch(key){
              case 'mon':
                Duration mon = getScheduleTotal(intern, key);
                if(mon != null){
                  for(int i = 1; i <= numberOfDays['Monday']; i++ ){
                    if(schTotal!= null){
                      schTotal = schTotal + mon;
                    }else{
                      schTotal = mon;
                    }
                  }
                }
                break;
              case 'tue':
                Duration tue = getScheduleTotal(intern, key);
                if(tue != null) {
                  for (int i = 1; i <= numberOfDays['Tuesday']; i++) {
                    if (schTotal != null) {
                      schTotal = schTotal + tue;
                    } else {
                      schTotal = tue;
                    }
                  }
                }
                break;
              case 'wed':
                Duration wed = getScheduleTotal(intern, key);
                if(wed != null) {
                  for (int i = 1; i <= numberOfDays['Wednesday']; i++) {
                    if (schTotal != null) {
                      schTotal = schTotal + wed;
                    } else {
                      schTotal = wed;
                    }
                  }
                }
                break;
              case 'thu':
                Duration thu = getScheduleTotal(intern, key);
                if(thu != null) {
                  for (int i = 1; i <= numberOfDays['Thursday']; i++) {
                    if (schTotal != null) {
                      schTotal = schTotal + thu;
                    } else {
                      schTotal = thu;
                    }
                  }
                }
                break;
              case 'fri':
                Duration fri = getScheduleTotal(intern, key);
                if(fri != null) {
                  for (int i = 1; i <= numberOfDays['Friday']; i++) {
                    if (schTotal != null) {
                      schTotal = schTotal + fri;
                    } else {
                      schTotal = fri;
                    }
                  }
                }
                break;
            }
          });

          // clocks history
          dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
              uID: intern.uID,
              startDate: startDate,
              endDate: endDate
          );

          Duration total, monthOneTotal, monthTwoTotal, monthThreeTotal,
              monthFourTotal, monthFiveTotal, monthSixTotal, monthSevenTotal,
              monthEightTotal, monthNineTotal, monthTenTotal, monthElevenTotal,
              monthTwelveTotal;

          if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
            List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
            queryDocumentSnapshot.forEach((document) {
              DateTime docDate = DateTime.parse(document['date'].toDate().toString());
              if(docDate.month == 1){monthOneTotal = getTotal(document, monthOneTotal);}
              if(docDate.month == 2){monthTwoTotal = getTotal(document, monthTwoTotal);}
              if(docDate.month == 3){monthThreeTotal = getTotal(document, monthThreeTotal);}
              if(docDate.month == 4){monthFourTotal = getTotal(document, monthFourTotal);}
              if(docDate.month == 5){monthFiveTotal = getTotal(document, monthFiveTotal);}
              if(docDate.month == 6){monthSixTotal = getTotal(document, monthSixTotal);}
              if(docDate.month == 7){monthSevenTotal = getTotal(document, monthSevenTotal);}
              if(docDate.month == 8){monthEightTotal = getTotal(document, monthEightTotal);}
              if(docDate.month == 9){monthNineTotal = getTotal(document, monthNineTotal);}
              if(docDate.month == 10){monthTenTotal = getTotal(document, monthTenTotal);}
              if(docDate.month == 11){monthElevenTotal = getTotal(document, monthElevenTotal);}
              if(docDate.month == 12){monthTwelveTotal = getTotal(document, monthTwelveTotal);}
              total = getTotal(document, total);
            });
          }

          rows.add([
            "",
            intern.firstName + ' ' + intern.lastName,
            monthOneTotal      != null ? monthOneTotal : '-',
            monthTwoTotal      != null ? monthTwoTotal : '-',
            monthThreeTotal    != null ? monthThreeTotal : '-',
            monthFourTotal     != null ? monthFourTotal : '-',
            monthFiveTotal     != null ? monthFiveTotal : '-',
            monthSixTotal      != null ? monthSixTotal : '-',
            monthSevenTotal    != null ? monthSevenTotal : '-',
            monthEightTotal    != null ? monthEightTotal : '-',
            monthNineTotal     != null ? monthNineTotal : '-',
            monthTenTotal      != null ? monthTenTotal : '-',
            monthElevenTotal   != null ? monthElevenTotal : '-',
            monthTwelveTotal   != null ? monthTwelveTotal : '-',
            "",
            total != null ? total : '-',
            "",
            schTotal != null ? schTotal : '-',
            ""
          ]);
        });
      }
      row.add("");
      rows.add(row);

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }
  Future<dynamic> fetchInternYearlyData({ UserModel intern, File localFile }) async {

    DateTime date = DateTime.now();

    var lastDayOfMonth = DateTime(date.year, 12 + 1, 0);

    Timestamp startDate = Timestamp.fromDate(DateTime(date.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(date.year, 12, lastDayOfMonth.day));

    Map<String, int> numberOfDays = occurrenceDaysInYear(date.year, DateFormat('EEEE').format(DateTime(date.year, 1, 1)));

    try{

      List<List<dynamic>> rows = [];

      rows.add(["",
        "January", "February", "March", "April", "May", "Jun", "July", "August", "September",
        "October", "November", "December",
        "", "Total", "", "Schedule", "",]);

      rows.add(["Intern"]);

      List<dynamic> row = [];

      // user's schedule
      Duration schTotal;
      intern.schedules.forEach((key, value) {
        switch(key){
          case 'mon':
            Duration mon = getScheduleTotal(intern, key);
            if(mon != null){
              for(int i = 1; i <= numberOfDays['Monday']; i++ ){
                if(schTotal!= null){
                  schTotal = schTotal + mon;
                }else{
                  schTotal = mon;
                }
              }
            }
            break;
          case 'tue':
            Duration tue = getScheduleTotal(intern, key);
            if(tue != null) {
              for (int i = 1; i <= numberOfDays['Tuesday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + tue;
                } else {
                  schTotal = tue;
                }
              }
            }
            break;
          case 'wed':
            Duration wed = getScheduleTotal(intern, key);
            if(wed != null) {
              for (int i = 1; i <= numberOfDays['Wednesday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + wed;
                } else {
                  schTotal = wed;
                }
              }
            }
            break;
          case 'thu':
            Duration thu = getScheduleTotal(intern, key);
            if(thu != null) {
              for (int i = 1; i <= numberOfDays['Thursday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + thu;
                } else {
                  schTotal = thu;
                }
              }
            }
            break;
          case 'fri':
            Duration fri = getScheduleTotal(intern, key);
            if(fri != null) {
              for (int i = 1; i <= numberOfDays['Friday']; i++) {
                if (schTotal != null) {
                  schTotal = schTotal + fri;
                } else {
                  schTotal = fri;
                }
              }
            }
            break;
        }
      });

      // clocks history
      dynamic historyResult = await FirestoreService().getUserClockHistoryByDateRange(
          uID: intern.uID,
          startDate: startDate,
          endDate: endDate
      );

      Duration total, monthOneTotal, monthTwoTotal, monthThreeTotal,
          monthFourTotal, monthFiveTotal, monthSixTotal, monthSevenTotal,
          monthEightTotal, monthNineTotal, monthTenTotal, monthElevenTotal,
          monthTwelveTotal;

      if(historyResult != null && historyResult is List<QueryDocumentSnapshot>){
        List<QueryDocumentSnapshot> queryDocumentSnapshot = historyResult;
        queryDocumentSnapshot.forEach((document) {
          DateTime docDate = DateTime.parse(document['date'].toDate().toString());
          if(docDate.month == 1){monthOneTotal = getTotal(document, monthOneTotal);}
          if(docDate.month == 2){monthTwoTotal = getTotal(document, monthTwoTotal);}
          if(docDate.month == 3){monthThreeTotal = getTotal(document, monthThreeTotal);}
          if(docDate.month == 4){monthFourTotal = getTotal(document, monthFourTotal);}
          if(docDate.month == 5){monthFiveTotal = getTotal(document, monthFiveTotal);}
          if(docDate.month == 6){monthSixTotal = getTotal(document, monthSixTotal);}
          if(docDate.month == 7){monthSevenTotal = getTotal(document, monthSevenTotal);}
          if(docDate.month == 8){monthEightTotal = getTotal(document, monthEightTotal);}
          if(docDate.month == 9){monthNineTotal = getTotal(document, monthNineTotal);}
          if(docDate.month == 10){monthTenTotal = getTotal(document, monthTenTotal);}
          if(docDate.month == 11){monthElevenTotal = getTotal(document, monthElevenTotal);}
          if(docDate.month == 12){monthTwelveTotal = getTotal(document, monthTwelveTotal);}
          total = getTotal(document, total);
        });
      }

      rows.add([
        intern.firstName + ' ' + intern.lastName,
        monthOneTotal      != null ? monthOneTotal : '-',
        monthTwoTotal      != null ? monthTwoTotal : '-',
        monthThreeTotal    != null ? monthThreeTotal : '-',
        monthFourTotal     != null ? monthFourTotal : '-',
        monthFiveTotal     != null ? monthFiveTotal : '-',
        monthSixTotal      != null ? monthSixTotal : '-',
        monthSevenTotal    != null ? monthSevenTotal : '-',
        monthEightTotal    != null ? monthEightTotal : '-',
        monthNineTotal     != null ? monthNineTotal : '-',
        monthTenTotal      != null ? monthTenTotal : '-',
        monthElevenTotal   != null ? monthElevenTotal : '-',
        monthTwelveTotal   != null ? monthTwelveTotal : '-',
        "",
        total != null ? total : '-',
        "",
        schTotal != null ? schTotal : '-',
        ""
      ]);

      row.add("");
      rows.add(row);

      File f = localFile;
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv);
      return true;
    }catch(error){
      return error.toString();
    }
  }

  Duration getTotal(QueryDocumentSnapshot snapshot, Duration total){
    Iterable arr = snapshot['clocks'];
    arr.forEach((element) {
      var cIn, cOut;
      if(element['clock_in'] != null){
        cIn = DateTime.parse(element['clock_in'].toDate().toString());
      }
      if(element['clock_out'] != null){
        cOut = DateTime.parse(element['clock_out'].toDate().toString());
      }
      if(cIn != null && cOut != null){
        if(total != null){
          total = total + cOut.difference(cIn);
        }else{
          total = cOut.difference(cIn);
        }
      }
    });
    return total;
  }
  Duration getScheduleTotal(UserModel intern, String key){
    Iterable schArr = intern.schedules[key];
    Duration schTotal;
    schArr.forEach((element) {
      if (element['clockIn'] != null &&
          element['clockOut'] != null) {
        var cIn = DateTime.parse(element['clockIn']
            .toDate()
            .toString());
        var cOut = DateTime.parse(element['clockOut']
            .toDate()
            .toString());

        if (schTotal != null) {
          schTotal = schTotal + cOut.difference(cIn);
        } else {
          schTotal = cOut.difference(cIn);
        }
      }
    });
    return schTotal;
  }

  Map<String, int> occurrenceDaysInMonth(int n, String firstDay){
    List<String> days = [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<int> count = List.filled(7, 4, growable: true);

    int pos = 0;
    for(int i = 0; i < 7; i++){
      if(firstDay == days[i]){
        pos = i;
        break;
      }
    }

    int inc = n - 28;

    for(int i = pos; i < pos + inc; i++){
      if(i > 6)
        count[i % 7] = 5;
      else
        count[i] = 5;
    }

    return {
      days[0] : count[0],
      days[1] : count[1],
      days[2] : count[2],
      days[3] : count[3],
      days[4] : count[4],
      days[5] : count[5],
      days[6] : count[6],
    };
  }
  Map<String, int> occurrenceDaysInYear(int year, String firstDay){
    Map<String, int> result = Map<String, int>();
    List<String> days = [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int allDaysCount = ((year % 4 == 0 && year % 100 > 0) || year %400 == 0) ? 366 : 365;

    for (int i = 0; i < days.length; i++){
      int firstDayIndex = days.indexOf(firstDay);
      int index = i - firstDayIndex;

      int count = 52;
      if(allDaysCount == 365){
        if(index == 0)
          count = 53;

      } else {
        if(index == 1 || index == 0)
          count = 53;
      }
      result.putIfAbsent(days[i], () => count);
    }
    return result;
  }
}