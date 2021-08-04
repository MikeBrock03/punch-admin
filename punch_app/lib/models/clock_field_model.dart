
import 'package:cloud_firestore/cloud_firestore.dart';

class ClockFieldModel {
  String day;
  DateTime clockIn;
  DateTime clockOut;
  String location;

  ClockFieldModel({ this.day, this.clockIn, this.clockOut, this.location });

  Map<String, dynamic> toMap(){
    return{
      //'day':       this.day,
      'clockIn':   this.clockIn,
      'clockOut':  this.clockOut,
    };
  }

  Map<String, dynamic> toMapForFirebase(){
    return{
      //'day':       this.day,
      'clockIn':   this.clockIn != null ? Timestamp.fromDate(this.clockIn) : null,
      'clockOut':  this.clockOut != null ? Timestamp.fromDate(this.clockOut) : null,
    };
  }

}