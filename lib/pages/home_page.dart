import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../actions_providers/shared_preferences_provider.dart';
// import '../actions_providers/login_action.dart';
import 'widgets/status_bar.dart';
import 'widgets/styling.dart';

class HomePage extends StatelessWidget {
  final prefs = new UserPreferences();

  void checkState(context) async {
    if(prefs.getState() != null){
      // ? alert received
      if(prefs.getDocumentAlertId() != null){
        Navigator.of(context).pushReplacementNamed("on_alert_coming", arguments: prefs.getDocumentAlertId());
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    defaultStatusBar();
    askForPermissions();
    // final FirebaseAuthentication auth = FirebaseAuthentication();
    Timer(Duration(milliseconds: 0),(){
      checkState(context);
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff9883DF),
        title: Text("App Bomberos",style: GoogleFonts.signika(),),
        centerTitle: true,
      ),
      // drawer: Drawer(),
      body: Center(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // MapsPage(),
            // RaisedButton(
            //   onPressed: () => MapsLauncher.launchCoordinates(8.9372859, -75.4413706),
            //   child: Text('LAUNCH COORDINATES'),
            // ),
            // Align(
            //   child: RawMaterialButton(
            //     onPressed: ()=>auth.getLogOut(),
            //     child: Icon(Icons.restore),
            //   ),
            // ),
            // Align(
            //   alignment: Alignment.bottomRight,
            //     child: FloatingActionButton(
            //     onPressed: ()=>prefs.cleanAll(),
            //     child: Icon(Icons.clear_all),
            //   ),
            // ),
            // Container(
            //   child: Text("App Bomberos"),
            // ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset("assets/undraw_moonlight_5ksn.png")),
            Container(
              alignment: Alignment.center,
              child: Text("Sin novedades", style:homePageMessageStyle),
            ),
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
        Permission.camera,
        Permission.microphone
        // Permission.storage,
      ].request();
    });
    print(statuses[Permission.location]);
    if(statuses[Permission.location] == PermissionStatus.granted){
      print("statuses[Permission.location] == PermissionStatus.granted");
    }
  }

}
