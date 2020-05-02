import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import 'actions_providers/firestore_actions.dart';
import 'actions_providers/login_action.dart';
import 'pages/on_alert_coming_page.dart';
import 'providers/push_notifications_provider.dart';
import 'package:provider/provider.dart';

import 'actions_providers/shared_preferences_provider.dart';

import './pages/maps.page.dart';


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
      navigatorkey.currentState.pushNamed("on_alert_coming", arguments: message);
    });

  } 

  @override
  void dispose() {
    // TODO: implement dispose
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
          'on_alert_coming' : (_)=>OnAlertComingPage()
        },
      );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = new UserPreferences();
    askForPermissions();
    return Scaffold(
      body: Center(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // MapsPage(),
            // RaisedButton(
            //   onPressed: () => MapsLauncher.launchCoordinates(8.9372859, -75.4413706),
            //   child: Text('LAUNCH COORDINATES'),
            // ),
            Align(
              alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                onPressed: ()=>prefs.cleanAll(),
                child: Icon(Icons.clear_all),
              ),
            )
          ],
        )
      ),
    );
  }
    void askForPermissions() async {
    Map<Permission, PermissionStatus> statuses; 
    await Future.delayed(Duration(milliseconds: 2000),() async {
      statuses = await [
        Permission.location,
        // Permission.camera,
        // Permission.storage,
        // Permission.microphone
      ].request();
    });
    print(statuses[Permission.location]);
    if(statuses[Permission.location] == PermissionStatus.granted){
      print("statuses[Permission.location] == PermissionStatus.granted");
    }
  }

}
