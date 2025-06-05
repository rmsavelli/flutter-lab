import 'package:shared_preferences/shared_preferences.dart';

class SpHelper {
  static const keyName = 'name';
  static const keyImage = 'image';

  Future<bool> setSettings(String name, String image) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyName, name);
      await prefs.setString(keyImage, image);
      return true;
    } on Exception catch(_) {
      return false;
    }
  }

  Future<Map<String, String>> getSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString(keyName) ?? '';
    final String image = prefs.getString(keyImage) ?? '';
    try {
      return {
        keyName: name,
        keyImage: image,
      };
    } on Exception catch (_) {
      return {};
    }
  }
}

