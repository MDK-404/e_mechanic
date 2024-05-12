import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static const String _userTypeKey = 'userType';

  // Method to set userType in SharedPreferences
  static Future<void> setUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
  }

  // Method to get userType from SharedPreferences
  static Future<String?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }
}
