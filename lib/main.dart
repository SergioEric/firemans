import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import 'actions_providers/firestore_actions.dart';
import 'actions_providers/login_action.dart';
import 'pages/home_page.dart';
import 'pages/on_alert_coming_page.dart';
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
  pushProvider.watchStates();
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

  @override
  void initState() {
    super.initState();
    pushProvider.message.listen((message){
      print(message);
      if(message.length > 5) {
        // if is not a call, 
        navigatorkey.currentState.pushReplacementNamed("on_alert_coming", arguments: message);
      }
      // switch(message){
      //   case 'audio':
      //     navigatorkey.currentState.pushNamed("video_call_page", arguments: message);
      //     break;
      //   default:
      //     break;
      // }
    });

  } 

  @override
  void dispose() {
    super.dispose();
    pushProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorkey,
        title: 'Bomberos',
        theme: ThemeData(
        ),
        home: HomePage(),
        routes: {
          'home' : (_)=>HomePage(),
          'on_alert_coming' : (_)=>OnAlertComingPage(),
          'video_call_page' : (_)=>VideoCallPage()
        },
      );
  }
}

