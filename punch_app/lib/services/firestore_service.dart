
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class FirestoreService {

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');

  Future<dynamic> createProfile({ UserModel userModel }) async{
    try {
      return await userCollection.doc(userModel.uID).set(userModel.toMap());
    } catch(error){

      print('error::::: $error');

      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> getUserData({ @required String uID }) async{
    try{
      dynamic result;
      await userCollection.doc(uID).get().then((document){
        if(document.data().isNotEmpty){
          result = UserModel(
            uID:          uID,
            firstName:    document.data()['first_name'],
            lastName:     document.data()['last_name'],
            email:        document.data()['email'],
            tel:          document.data()['tel'],
            mobile:       document.data()['mobile'],
            address:      document.data()['address'],
            platform:     document.data()['platform'],
            registererID: document.data()['registerer_id'],
            regCode:      document.data()['reg_code'],
            createdAt:    document.data()['created_at'],
            imageURL:     document.data()['image_url'],
            roleID:       document.data()['role_id'],
            tags:         document.data()['tags'],
            status:       document.data()['status'],
            verified:     document.data()['verified'],
            hasPassword:  document.data()['has_password']
          );
        }
      });
      return result;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> updateVerified({ @required String uID }) async{
    try{
      await userCollection.doc(uID).update({
        'verified' : true
      });
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> updateProfile({ @required UserModel userModel }) async{
    try{
      await userCollection.doc(userModel.uID).update({
        'logo_url' :      userModel.logoURL,
        'company_name' :  userModel.companyName,
        'first_name' :    userModel.firstName,
        'last_name' :     userModel.lastName,
        'education' :     userModel.education,
        'certification' : userModel.certification,
      });
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> updateInternProfile({ @required UserModel userModel }) async{
    try{
      await userCollection.doc(userModel.uID).update({
        'image_url' :      userModel.imageURL,
        'first_name' :    userModel.firstName,
        'last_name' :     userModel.lastName,
        'company_id' :     userModel.companyID,
        'schedules' : userModel.schedules,
      });
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> updateContactInfo({ @required UserModel userModel, bool isIntern }) async{
    try{

      var data;

      if(isIntern){
        data = {
          'mobile' :     userModel.mobile,
          'address' :    userModel.address,
        };
      }else{
        data = {
          'tel' :        userModel.tel,
          'address' :    userModel.address,
        };
      }

      await userCollection.doc(userModel.uID).update(data);
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> deleteUser({ @required String uID }) async{
    try{
      await userCollection.doc(uID).delete();
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> getCompanies({ String uID }) async{
    try{
      dynamic result;
      await userCollection
          .where("role_id", isEqualTo: AppConfig.employerUserRole)
          .where("registerer_id", isEqualTo: uID)
          .where("status", isEqualTo: true)
          .orderBy("created_at", descending: true)
          .get()
          .then((querySnapshot){
              if(querySnapshot.docs.isNotEmpty){
                result = querySnapshot.docs;
              }
            }
          );
      return result;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Future<dynamic> getInternsByCompanyID({ String uID }) async{
    try{
      dynamic result;
      await userCollection
          .where("role_id", isEqualTo: AppConfig.internUserRole)
          .where("company_id", isEqualTo: uID)
          .where("status", isEqualTo: true)
          .orderBy("created_at", descending: true)
          .get()
          .then((querySnapshot){
        if(querySnapshot.docs.isNotEmpty){
          result = querySnapshot.docs;
        }
      }
      );
      return result;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  List<UserModel> _internListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();
  }

  Future<dynamic> getClockHistory({ @required String uID, String $date }) async{
    try{
      dynamic result;
      await userCollection.doc(uID).collection('clock_history').doc($date).get().then((document){
        if(document.data() != null && document.data().isNotEmpty){
          result = document.data();
          /*result = {
            'clock_in'      : document.data()['clock_in'] ?? null,
            'clock_out'     : document.data()['clock_out'] ?? null,
            'location'      : document.data()['location'] ?? null,
          };*/
        }else{
          return null;
        }
      });
      return result;
    }catch(error){
      if(!AppConfig.isPublished){
        return error;
      }
    }
  }

  Stream<List<UserModel>> getRealTimeInterns({ String uID }) {

    try{
      return userCollection
          .where("role_id", isEqualTo: AppConfig.internUserRole)
          .where("registerer_id", isEqualTo: uID)
          .where("status", isEqualTo: true)
          .orderBy("created_at", descending: true)
          .snapshots().map(_internListFromSnapshot);
    }catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return null;
    }
  }
}