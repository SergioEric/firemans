import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import 'actions_providers/firestore_actions.dart';
import 'actions_providers/login_action.dart';
import 'pages/home_page.dart';
import 'pages/on_alert_coming_page.dart';
import 'pages/widgets/status_bar.dart';
import 'providers/alert_created_time.dart';
import 'providers/push_notifications_provider.dart';
import 'package:provider/provider.dart';

import 'actions_providers/shared_preferences_provider.dart';

import './pages/maps.page.dart';
import './pages/video_call_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new UserPreferences();
  await prefs.initPrefs();
  final pushProvider = new PushNotificationProvider();
  final authUser = FirebaseAuthentication();
  pushProvider.createContrustor();
  // pushProvider.watchStates();
  bool session = await authUser.isSignedIn();
  String token = '';
  FirestoreActions fstore = FirestoreActions();

  if(!session){
    print("session no existe ");
    await authUser.login();
    token = await pushProvider.initNotifications();
    await fstore.saveTokenToFireStore(token);
    prefs.setPushToken(token);
  }
  if(prefs.getPushToken() != null && prefs.getPushToken().length >0){
    print("token SI existe en prefs");
    token= prefs.getPushToken();
  }else{
    await authUser.login();
    print("token no existe en prefs");
    token = await pushProvider.initNotifications();
    await fstore.saveTokenToFireStore(token);
    prefs.setPushToken(token);
  }
  print(token);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();
  final pushProvider = new PushNotificationProvider();
  FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    this._firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("············· onMessage: $message");
        print("FROM INITSTATE on MAIN - DateTime.now() = ${DateTime.now()}");
        String docId = message["data"]["id"] ?? 'no-data';
        String typeCall = message["data"]["call"] ?? null;
        if(message["data"]["call"] != null){
          // _streamController.sink.add(typeCall);
        }else{
          // print("_streamController.sink.add(docId);");
          navigatorkey.currentState.pushReplacementNamed("on_alert_coming", arguments: docId);
        }
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("············· onLaunch: $message");
        // print(message);
        print("FROM INITSTATE on MAIN - DateTime.now() = ${DateTime.now()}");
        String docId = message["data"]["id"] ?? 'no-data';
        // String typeCall = message["data"]["call"] ?? null;
        if(message["data"]["call"] != null){
          // _streamController.sink.add(typeCall);
        }else{
          navigatorkey.currentState.pushReplacementNamed("on_alert_coming", arguments: docId);
        }   
      },
      onResume: (Map<String, dynamic> message) async {
        print("············· onResume: $message");
        // print(message);
        print("FROM INITSTATE on MAIN - DateTime.now() = ${DateTime.now()}");
        String docId = message["data"]["id"] ?? 'no-data';
        String typeCall = message["data"]["call"] ?? null;
        if(message["data"]["call"] != null){
          // _streamController.sink.add(typeCall);
        }else{
          navigatorkey.currentState.pushReplacementNamed("on_alert_coming", arguments: docId);
        }      
      },
    );
  } 
  wacthForSink(){
    print("wacthForSink");
    pushProvider.message.listen((message){
      print("message on init of MyApp page $message");
      if(message.length > 5) {
        // if is not a call, 
        print("message.length > 5");
        navigatorkey.currentState.pushReplacementNamed("on_alert_coming", arguments: message);
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    // pushProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // wacthForSink();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    defaultStatusBar();
    return ChangeNotifierProvider(
      create: (_)=>CreatedTimeProvider(),
          child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorkey,
          title: 'Bomberos',
          theme: ThemeData(
          ),
          home: HomePage(),
          routes: {
            'app' :   (_)=> MyApp(),
            'home' : (_)=>HomePage(),
            'on_alert_coming' : (_)=>OnAlertComingPage(),
            'video_call_page' : (_)=>VideoCallPage()
          },
        ),
    );
  }
}

