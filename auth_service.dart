import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
 static const baseUrl = 'http://10.103.198.103:3000';
 //static final storage=FlutterSecureStorage();


 static Future<Map<String, dynamic>>signup(String name, String email, String password) async{
  final response =await http.post(
    Uri.parse('$baseUrl/auth/signup'),
    headers:{'Content-Type':'application/json'},
    body:jsonEncode({'name':name,'email':email,'password':password})
  );
  return{
  'statusCode':response.statusCode,
  'body':jsonDecode(response.body),
 };

 }
 
static Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final response = await http.post(
       
        Uri.parse('$baseUrl/auth/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password})
    );

   
    return jsonDecode(response.body); 
    
  } catch (e) {
    return {'message': 'Connection Error'};
  }
}
}