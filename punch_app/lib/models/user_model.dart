import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String                uID;
  String                firstName;
  String                lastName;
  String                companyName;
  String                email;
  String                tel;
  String                mobile;
  String                address;
  String                platform;
  String                registererID;
  String                companyID;
  String                regCode;
  Timestamp             createdAt;
  String                imageURL;
  String                logoURL;
  String                education;
  String                certification;
  double                roleID;
  List<dynamic>         tags;
  Map<String, dynamic>  clocks;
  Map<String, dynamic>  schedules;
  bool                  status;
  bool                  verified;
  bool                  hasPassword;

  UserModel({ this.uID, this.firstName, this.lastName, this.email, this.tel, this.mobile, this.address, this.platform, this.registererID,
              this.regCode, this.status, this.createdAt, this.imageURL, this.roleID, this.tags, this.clocks, this.schedules, this.verified,
              this.hasPassword, this.companyName, this.logoURL, this.education, this.certification, this.companyID
  });

  factory UserModel.fromJson(String uID, Map<String, dynamic> json) {
    return UserModel(
      uID:              uID,
      firstName:        json["first_name"],
      lastName:         json["last_name"],
      companyName:      json["company_name"],
      email:            json["email"],
      tel:              json["tel"],
      mobile:           json["mobile"],
      address:          json["address"],
      platform:         json["platform"],
      registererID:     json["registerer_id"],
      companyID:        json["company_id"],
      regCode:          json["reg_code"],
      createdAt:        json["created_at"],
      imageURL:         json["image_url"] ?? '',
      logoURL:          json["logo_url"] ?? '',
      education:        json["education"],
      certification:    json["certification"],
      roleID:           json["role_id"],
      tags:             json["tags"],
      clocks:           json["clocks"],
      schedules:        json["schedules"],
      status:           json["status"],
      verified:         json["verified"],
      hasPassword:      json["has_password"],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'first_name':       this.firstName,
      'last_name':        this.lastName,
      'company_name':     this.companyName,
      'email':            this.email,
      'tel':              this.tel,
      'mobile':           this.mobile,
      'address':          this.address,
      'platform':         this.platform,
      'registerer_id':    this.registererID,
      'company_id':       this.companyID,
      'reg_code':         this.regCode,
      'created_at':       this.createdAt,
      'image_url':        this.imageURL,
      'logo_url':         this.logoURL,
      'education':        this.education,
      'certification':    this.certification,
      'role_id':          this.roleID,
      'tags':             this.tags,
      'clocks':           this.clocks,
      'schedules':        this.schedules,
      'status':           this.status,
      'verified':         this.verified,
      'has_password':     this.hasPassword,
    };
  }

  @override
  String toString() {
    return 'UserModel(uID: $uID, firstName: $firstName, lastName: $lastName, companyName: $companyName, email: $email, tel: $tel, mobile: $mobile, address: $address, platform: $platform, registererID: $registererID, companyID: $companyID, regCode: $regCode, createdAt: $createdAt, imageURL: $imageURL, logoURL: $logoURL, education: $education, certification: $certification, roleID: $roleID, tags: $tags, clocks: $clocks, schedules: $schedules, status: $status, verified: $verified, hasPassword: $hasPassword )';
  }
}