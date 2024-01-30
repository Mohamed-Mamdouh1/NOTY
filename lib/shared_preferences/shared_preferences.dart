import 'package:shared_preferences/shared_preferences.dart';
class AppPreferences{
  static const String appModeKey = 'app_mode';

  static Future<void> saveAppMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(appModeKey, isDarkMode);
  }

  static Future<bool> getAppMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(appModeKey) ?? false;
  }
}