
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class CompaniesViewModel extends ChangeNotifier{

  List<UserModel> _companyList = [];
  List<UserModel> get companyList => this._companyList;

  Future<dynamic> fetchData({ bool refresh, String uID }) async {

    try{
      final result =  await FirestoreService().getCompanies(uID: uID);

      if(refresh != null && refresh){
        this._companyList.clear();
      }

      this._companyList = result.map<UserModel>((model) => UserModel.fromJson(model.id, model.data())).toList();

      notifyListeners();
      return true;
    }catch(error){
      print('error: $error');
      return error.toString();
    }
  }

  bool addToList({ UserModel model }) {
    try{
      _companyList.add(model);
      _companyList.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });
      notifyListeners();
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return false;
    }
  }

  bool updateList({ UserModel model }) {
    try{
      _companyList.removeWhere((element) => element.uID == model.uID);
      _companyList.add(model);
      _companyList.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });
      notifyListeners();
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return false;
    }
  }

  bool removeFromList({ UserModel model }){
    try{
      _companyList.remove(model);
      notifyListeners();
      return true;
    }catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return false;
    }
  }
}