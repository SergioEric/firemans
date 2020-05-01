import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationProvider {

  static final PushNotificationProvider _instance = new PushNotificationProvider._internal();

  factory PushNotificationProvider() {
    return _instance;
  }

  PushNotificationProvider._internal();

  FirebaseMessaging _firebaseMessaging;

  createContrustor(){
    this._firebaseMessaging = FirebaseMessaging();
  }

  Future<String> initNotifications() async {
     _firebaseMessaging.requestNotificationPermissions();
     return await _firebaseMessaging.getToken();
  }

  void watchStates(){
  _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("············· onMessage: $message");
        print("DateTime.now() = ${DateTime.now()}");
        // print(message);
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("············· onLaunch: $message");
        // print(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("············· onResume: $message");
        // print(message);
      },
    );
  }
}
