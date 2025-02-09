
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userName = prefs.getString('userName') ?? 'User';
  final token = prefs.getString('token') ?? '';
  final id = prefs.getString('id') ?? '';

  return {'isLoggedIn': isLoggedIn, 'userName':userName, 'token':token, 'id':id};
}

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.setString('userName','User'); 
  await prefs.setString('token', '');
  await prefs.setString('id', '');
}