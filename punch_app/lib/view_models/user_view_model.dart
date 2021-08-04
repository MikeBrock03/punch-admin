import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/cloud_function_service.dart';
import '../models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  UserModel _userModel;

  String get uID {
    return this._userModel.uID;
  }

  String get firstName {
    return this._userModel != null ? this._userModel.firstName : '';
  }

  String get lastName {
    return this._userModel != null ? this._userModel.lastName : '';
  }

  String get email {
    return this._userModel.email;
  }

  String get tel {
    return this._userModel.tel;
  }

  String get mobile {
    return this._userModel.mobile;
  }

  String get platform {
    return this._userModel.platform;
  }

  Timestamp get createdAt {
    return this._userModel.createdAt;
  }

  String get imageURL {
    return this._userModel.imageURL;
  }

  String get regCode {
    return this._userModel.regCode;
  }

  double get roleID {
    return this._userModel.roleID;
  }

  List<String> get tags {
    return this._userModel.tags;
  }

  bool get status {
    return this._userModel.status;
  }

  bool get verified {
    return this._userModel.verified;
  }

  void setUID(String value) {
    _userModel.uID = value;
    notifyListeners();
  }

  void setFirstName(String value) {
    _userModel.firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _userModel.lastName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _userModel.email = value;
    notifyListeners();
  }

  void setTel(String value) {
    _userModel.tel = value;
    notifyListeners();
  }

  void setMobile(String value) {
    _userModel.mobile = value;
    notifyListeners();
  }

  void setPlatform(String value) {
    _userModel.platform = value;
    notifyListeners();
  }

  void setCreatedAt(Timestamp value) {
    _userModel.createdAt = value;
    notifyListeners();
  }

  void setImageUrl(String value) {
    _userModel.imageURL = value;
    notifyListeners();
  }

  void setRoleID(double value) {
    _userModel.roleID = value;
    notifyListeners();
  }

  void setTags(List<String> value) {
    _userModel.tags = value;
    notifyListeners();
  }

  void setStatus(bool value) {
    _userModel.status = value;
    notifyListeners();
  }

  void setVerified(bool value) {
    _userModel.verified = value;
    notifyListeners();
  }

  void setUserModel(UserModel model) {
    _userModel = model;
  }

  Future<dynamic> sendEmail({String email, String message}) async {
    Map<String, dynamic> postData = {
      "email": email,
      "message": message,
    };

    try {
      final result = await CloudFunctionService().sendEmail(postData);
      return result;
    } catch (error) {
      return error.toString();
    }
  }
}
