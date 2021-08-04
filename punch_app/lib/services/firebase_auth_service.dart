
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import '../database/storage.dart';
import '../models/user_model.dart';

class FirebaseAuthService {

  final Storage storage = new Storage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<UserModel> get authStateChanges => _firebaseAuth.authStateChanges().map(_userFromFirebaseUser);

  Future<dynamic> login({ String email, String password }) async{
    try{
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException catch(error){
      return error.message;
    }
  }

  Future<dynamic> register({ String email, String password }) async{
    try{
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      storage.saveBool('verified', false);
      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException catch(error){
      return error.message;
    }
  }

  Future<dynamic> registerWithoutAuth({ String email }) async {
    //FirebaseApp app = await Firebase.initializeApp(name: UniqueKey().toString(), options: Firebase.app().options);
    FirebaseApp app = await Firebase.initializeApp(name: 'secondpunch', options: Firebase.app().options);
    String password = 'f8a89e';
    try {
      UserCredential result = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: password);
      await app.delete();
      return _userFromFirebaseUser(result.user);
    }on FirebaseAuthException catch(error){
      await app.delete();
      return error.message;
    }
  }

  Future<dynamic> signInAnonymous() async{
    try{
      UserCredential result = await _firebaseAuth.signInAnonymously();
      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException catch(error){
      return error.message;
    }
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  UserModel _userFromFirebaseUser(user){
    return user != null ? UserModel(
      uID: user.uid,
    ) : null;
  }

}