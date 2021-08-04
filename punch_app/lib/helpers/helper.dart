import 'package:data_connection_checker/data_connection_checker.dart';
import '../config/app_config.dart';

class Helper{

  static Future<bool> isNetAvailable() async {
    try{
      return await DataConnectionChecker().hasConnection;
    }catch(error){
      if(!AppConfig.isPublished){
        print(error);
      }
      return false;
    }
  }

}