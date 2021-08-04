
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;
import 'package:path/path.dart' as Path;

class FirebaseStorage {

  final firebaseStorage.Reference storageRef = firebaseStorage.FirebaseStorage.instance.ref();

  Future<dynamic> uploadLogo({ String imagePath, String uID }) async{

    dynamic result;

    try {
      var logoRef = storageRef.child('logos/$uID${Path.extension(imagePath)}');
      await logoRef.putFile(File(imagePath)).whenComplete(() async {
        await logoRef.getDownloadURL().then((value) => {
          if(value != null){
            result = value
          }
        });
      });
      return result;
    } catch(error){
      return error;
    }
  }

  Future<dynamic> uploadAvatar({ String imagePath, String uID  }) async{

    dynamic result;

    try {
      var logoRef = storageRef.child('avatar/$uID${Path.extension(imagePath)}');
      await logoRef.putFile(File(imagePath)).whenComplete(() async {
        await logoRef.getDownloadURL().then((value) => {
          if(value != null){
            result = value
          }
        });
      });
      return result;
    } catch(error){
      print('upload image error : $error');
      return error;
    }
  }
}