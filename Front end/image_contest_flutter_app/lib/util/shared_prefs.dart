import 'dart:convert';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  //Set/Get UserLoggedIn Status
  void setTutorialSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('tutorialSeen', true);
  }

  Future<bool> getTutorialSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialSeen') ?? false;
  }

  void setUserLoggedIn(bool loggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', loggedIn);
    ConstantUtil.isLoggedIn = loggedIn;
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  //Set/Get UserLoggedIn Status
  void setAuthorizationKey(String authKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('authKey', authKey);
  }

  Future<String> getAuthorizationKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('authKey') as String;
  }

  void saveUser(UserModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(model.toJson());
    prefs.setString('user', jsonString);
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userMap = prefs.getString('user') != null
        ? json.decode(prefs.getString('user')!)
        : null;
    return UserModel.fromJson(userMap);
  }

  //Set/Get UserLoggedIn Status
  Future<bool> setLanguageCode(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('language', code);
  }

  Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (prefs.get('language') as String == null){
    return 'en';
    // }
    // else{
    //   return prefs.get('language') as String;
    // }
  }

  void clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
