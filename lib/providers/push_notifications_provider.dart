import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationProvider {

  static final PushNotificationProvider _instance = new PushNotificationProvider._internal();

  factory PushNotificationProvider() {
    return _instance;
  }

  PushNotificationProvider._internal();

  FirebaseMessaging _firebaseMessaging;

  StreamController _streamController = StreamController<String>.broadcast();

  Stream<String> get message => _streamController.stream;

 
  createContrustor(){
    this._firebaseMessaging = FirebaseMessaging();
  }

  Future<String> initNotifications() async {
     _firebaseMessaging.requestNotificationPermissions();
     return await _firebaseMessaging.getToken();
  }

  void watchStates(){
    print("watching States ··················");
  _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("············· onMessage: $message");
        print("DateTime.now() = ${DateTime.now()}");
        String docId = message["data"]["id"] ?? 'no-data';
        String typeCall = message["data"]["call"] ?? null;
        if(message["data"]["call"] != null){
          _streamController.sink.add(typeCall);
        }else{
          _streamController.sink.add(docId);
        }
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("············· onLaunch: $message");
        // print(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("············· onResume: $message");
        // print(message);
        String docId = message["data"]["id"] ?? 'no-data';
        _streamController.sink.add(docId);
      },
    );
  }
  dispose(){
    _streamController?.close();
  }
}
