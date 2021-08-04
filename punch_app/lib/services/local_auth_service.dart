/*

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../config/app_config.dart';

class LocalAuthService{

  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async{
    try{
      return await _auth.canCheckBiometrics;
    } on PlatformException catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async{
    try{
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate({ String message = 'Authenticate yourself' }) async{

    final isAvailable = await hasBiometrics();
    if(!isAvailable) return false;

    try{
      return await _auth.authenticate(
          biometricOnly: true,
          localizedReason: message,
          useErrorDialogs: true,
          stickyAuth: false
      );
    } on PlatformException catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      return false;
    }
  }

}*/
