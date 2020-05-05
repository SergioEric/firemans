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

  Future<void> removePushToken() async {
    await _prefs.remove('token');
  }
  
  Future<void> setState(int value)async {
    await _prefs.setInt('state', value);
  }
  int getState() {
    return _prefs.getInt('state') ?? null;
  }
  
  Future<void> removeState() async {
    await _prefs.remove('state');
  }

  String getDocumentAlertId(){
    return _prefs.getString('documentId') ?? null;
  }

  Future<void> setDocumentAlertId(String value) async {
    await _prefs.setString('documentId', value);
  }
  Future<void> removeDocumentAlertId() async {
    await _prefs.remove('documentId');
  }
  Future<void>  cleanAll() async {
    await _prefs.clear();
  }

}
