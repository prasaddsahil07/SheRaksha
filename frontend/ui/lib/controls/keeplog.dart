
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userName = prefs.getString('userName') ?? 'User';

  return {'isLoggedIn': isLoggedIn, 'userName':userName};
}

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.setString('userName','User'); 
}