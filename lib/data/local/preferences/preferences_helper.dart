import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  PreferencesHelper._(this._preferences);
  final SharedPreferences _preferences;
  static Future<PreferencesHelper> create() async =>
      PreferencesHelper._(await SharedPreferences.getInstance());
  String get profileName => _preferences.getString('profile_name') ?? 'Student';
  Future<void> setProfileName(String value) =>
      _preferences.setString('profile_name', value);
}
