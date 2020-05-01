import 'package:shared_preferences/shared_preferences.dart';

/*

  Inicializar en el main
    final prefs = new UserPreferences();
    await prefs.initPrefs();
    
*/

class UserPreferences {

  static final UserPreferences _instancia = new UserPreferences._internal();

  factory UserPreferences() {
    return _instancia;
  }

  UserPreferences._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  String getPushToken(){
    return _prefs.getString('token') ?? null;
  }

  void setPushToken(String value) async {
    await _prefs.setString('token', value);
  }
  // int processState() {
  //   return _prefs.getInt('state') ?? null;
  // }

  // setProcessState(int value) async {
  //   await _prefs.setInt('state', value);
  // }


  void cleanAll() async {
    await _prefs.clear();
  }

}
