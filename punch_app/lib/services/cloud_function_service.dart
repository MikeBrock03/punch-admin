
import 'dart:convert';
import '../helpers/helper.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;

class CloudFunctionService{

  Map<String, String> postHeaders = {
    'Content-type': 'application/x-www-form-urlencoded',
    'Accept': '*/*',
    'Token': AppConfig.apiKey,
  };

  Future<dynamic> sendEmail(dynamic postData) async {

    if(await Helper.isNetAvailable()){

      final url = AppConfig.apiURL + 'sendEmail';
      final http.Response response = await http.post(Uri.parse(url) ,headers: postHeaders, body: postData);

      if (response.statusCode == 200) {

        if(response.body != null){

          if(!AppConfig.isPublished){
            print(response.body);
          }

          return response.body;

        }else{
          throw 'receive_error';
        }

      } else {
        if(response.statusCode == 404){
          throw '404';
        }else{
          throw json.decode(utf8.decode(response.bodyBytes));
        }
      }

    }else{
      throw 'connection_error_description';
    }
  }
}