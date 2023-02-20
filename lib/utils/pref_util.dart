import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String isRegistered = 'isRegistered';
const String isCurrencySelected = 'isCurrencySelected';
const String selectedCurrency = 'selectedCurrency';
const String userName = 'username';
const String guidView = 'guidView';
const String installedDate = 'installedDate';

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async => _prefsInstance ?? await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  static String getString({String? key}) {
    return _prefsInstance!.getString(key!) ?? "";
  }

  static Future<bool> setString({String? key, String? value}) async {
    var prefs = await _instance;
    return prefs.setString(key!, value!);
  }

  static void clearSharedPreferences() async {
    var prefs = await _instance;
    await prefs.clear();
  }

  static bool getBool({String? key}) {
    return _prefsInstance!.getBool(key!) ?? false;
  }

  static Future<Object> setBool({String? key, bool? value}) async {
    var prefs = await _instance;
    return prefs.setBool(key!, value!);
  }

  static int getInt({String? key}) {
    return _prefsInstance!.getInt(key!) ?? 0;
  }

  static Future<bool> setInt({String? key, int? value}) async {
    var prefs = await _instance;
    return prefs.setInt(key!, value!);
  }

  static Future<Object> setListString({String? key, List<String>? value}) async {
    var prefs = await _instance;
    return prefs.setStringList(key!, value!);
  }

  static List getStringList({String? key}) {
    return _prefsInstance!.getStringList(key!) ?? <String>[];
  }

  static Future<Object> setMapListString({String? key, List? value}) async {
    var prefs = await _instance;
    return prefs.setString(key!, jsonEncode(value));
  }

  static List getStringListMap({String? key}) {
    var listData = _prefsInstance!.getString(key!);
    return listData != null ? jsonDecode(listData) : [];
  }

  static List getList({String? key}) {
    var listData = _prefsInstance!.getString(key!);
    return listData != null ? jsonDecode(listData) : [];
  }

  static Future<bool> setList({String? key, List? value}) async {
    var prefs = await _instance;
    return prefs.setString(key!, jsonEncode(value));
  }
}