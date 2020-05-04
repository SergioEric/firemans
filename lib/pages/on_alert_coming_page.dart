import 'dart:async';

import 'package:bomberos/providers/alert_created_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
  
import '../providers/push_notifications_provider.dart';
import '../actions_providers/shared_preferences_provider.dart';
import '../actions_providers/firestore_actions.dart';

import '../models/alert.model.dart';

import './maps.page.dart';
import './widgets/styling.dart';

class OnAlertComingPage extends StatefulWidget {
  @override
  _OnAlertComingPageState createState() => _OnAlertComingPageState();
}

class _OnAlertComingPageState extends State<OnAlertComingPage> {
  FirestoreActions fstore;

  double _scale = 1.0;
  double _previusScale = 1.0;
  int alertAcepted = 0;
  // Offset position = Offset(0,0);
  bool showCallBox = false;
  int difference = 0;
  final pushProvider = new PushNotificationProvider();

  @override
  void initState() {
    super.initState();
    fstore = FirestoreActions();
    pushProvider.message.listen((message){
      print(message);
      switch(message){
        case 'video':
          showCallBox = true;
          setState(() { });
          break;
        default:
          break;
      }
    });
  }

  _onScaleStart(ScaleStartDetails details){
    _previusScale = _scale;
    setState(() {});
    print(details);
  }
  _onScaleUpdate(ScaleUpdateDetails details){
    _scale = _previusScale * details.scale;
    setState(() {});
    print(details);
  }

  _onScaleEnd(ScaleEndDetails details){
    _previusScale = 1.0;
    setState(() {});
    print("_onScaleEnd");
  }
  @override
  void dispose() {
    super.dispose();
    pushProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarBrightness: Brightness.dark
    //   )
    // );
    final String doc = ModalRoute.of(context).settings.arguments;
    final prefs = new UserPreferences();
    final alert = fstore.getDocument(doc);
    final size = MediaQuery.of(context).size;
    print("prefs.getState ==  ${prefs.getState()}");
    CreatedTimeProvider provider = Provider.of<CreatedTimeProvider>(context, listen: false);
    Color notColor = (prefs.getState() == 1) ? my_green : (prefs.getState() == 2) ? my_red : obscure; 
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: (prefs.getState() == 1) ? acceptedStateDrawer() : (prefs.getState() == 2) ? rejectedStateDrawer() : (prefs.getState() == 3) ? doneStateDrawer() : pendingStateDrawer(),
        body: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(doc),
            Container(
              margin: EdgeInsets.only(top: 35),
              alignment: Alignment.topLeft,
              child: ButtonDrawer(notColor)),
            FutureBuilder(
              future: alert,
              builder: (BuildContext context, AsyncSnapshot<AlertInformation> snapshot){
                List<Widget> children;
                if(snapshot.hasData) {
                  prefs.setDocumentAlertId(doc);
                  prefs.setState(snapshot.data.state);
                  // Timestamp now = Timestamp.fromDate(DateTime.now());
                  DateTime now = DateTime.now();
                  DateTime created = snapshot.data.created.toDate();
                  int difference = now.difference(created).inMinutes;
                  // print(difference);
                  Timer(Duration(milliseconds: 0),(){
                    // setState(() {
                    //   this.difference = difference;
                    // });
                    provider.minutes = difference;
                  });
                  children =[
                    // Text(snapshot.data.created.difference(DateTime.now()).toString()),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("${snapshot.data.category}", style: categoryTextStyle,),)),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onScaleStart: _onScaleStart,
                        onScaleUpdate:_onScaleUpdate,
                        onScaleEnd: _onScaleEnd,
                        child: Transform.scale(
                        scale: (_scale < 1) ? 1 : _scale,
                        child: FadeInImage.assetNetwork(placeholder: "assets/Spin-1s-480px.gif",
                        image: snapshot.data.imageUrl, height: 512,),
                          ),
                      ),
                    ),
                    // Text(snapshot.data.userId)
                  ];
                }else if (snapshot.hasError) {
                  children = [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ];
                }else {
                  children = <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Cargando datos...'),
                    )
                  ];
                }
                 return Stack(
                   // mainAxisAlignment: MainAxisAlignment.center,
                   // crossAxisAlignment: CrossAxisAlignment.center,
                   children: children,
                 );
              },
            ),
            (prefs.getState() == 0)
              ? Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      RawMaterialButton(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.done, color: Colors.white,),
                        fillColor:Colors.green,  
                        onPressed: (){
                          //TODO hide action buttons
                          fstore.acceptOrRejectAlert(document: doc, state: 1);
                          // alertAcepted = 1;
                          prefs.setState(1);
                          setState(() {
                          });
                        },
                      ),
                      Text("aceptar", style: TextStyle(
                        // fontSize : 23
                      ))
                    ],),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      RawMaterialButton(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close,  color: Colors.white),
                        fillColor:Colors.redAccent,  
                        onPressed: (){
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context)=>AlertDialog(
                              title: Text("¿Estas seguro?"),
                              // content: Text("content"),
                              actions: <Widget>[
                                FlatButton(
                                  // shape: CircleBorder(),
                                  // color: Colors.greenAccent,
                                  child: Text("Si",style: TextStyle(fontSize: 20),),
                                  onPressed: () async{
                                    await fstore.acceptOrRejectAlert(document: doc, state: 2);
                                    prefs.setState(2);
                                    // if(prefs.getState() != null){
                                      // await prefs.removeState();
                                      // await prefs.removeDocumentAlertId();
                                    // }
                                    Navigator.pop(context);
                                    alertAcepted = 2;
                                    setState(() {
                                    });
                                  }
                                ),
                                FlatButton(
                                  child: Text("No",style: TextStyle(fontSize: 20),),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            )
                          );
                        },
                      ),
                      Text("rechazar", style: TextStyle(
                        // fontSize : 23
                      ))
                    ],),
                    // SizedBox(width: 40,),
                  ],
                ),
              ),
            ) : Container(),
            Container(
              margin: EdgeInsets.only(bottom:10),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: mapsButton())
            ),
            (showCallBox) ? onCallInComing() : Container(), // ? calling
            // (prefs.getState() == 0) ?
            //   Container(child: Align(
            //     alignment: Alignment.bottomRight,
            //     child: Text("received", style: TextStyle(color: Colors.red),)),)
            //     : (prefs.getState() == 1) 
            //       ? Container(child: Align(
            //         alignment: Alignment.bottomRight,
            //         child: Text("accepted")),)
            //           : Container(child: Align(
            //             alignment: Alignment.bottomRight,
            //             child: Text("rejected")),)
          ],
        ),
   ),
    );
  }

  Widget mapsButton(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RawMaterialButton(
          onPressed: (){
            print("goto maps");
            // Navigator.of(context).push(
            //   MaterialPageRoute(builder: (_)=>MapsPage())
            // );
          },
          // shape: CircleBorder(),
          child: Image.asset("assets/iconfinder_rounded_maps.png", width: 88,),
          elevation: 4,
        ),
        Text("abrir maps")
      ],
    );
  }

  Widget onCallInComing(){
    FlutterRingtonePlayer.playRingtone();
    Vibration.vibrate(pattern: [500, 1000, 500, 2000], intensities: [1, 255]);
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95)
      ),
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 150),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                RawMaterialButton(
                  fillColor: Colors.green,
                  onPressed: (){
                    FlutterRingtonePlayer.stop();
                    Vibration.cancel();
                    showCallBox = false;
                    setState(() {
                    });
                    Navigator.of(context).pushNamed("video_call_page");
                  },
                  child: Icon(Icons.call)
                ),
                RawMaterialButton(
                  fillColor: Colors.red,
                  onPressed: (){
                    FlutterRingtonePlayer.stop();
                    Vibration.cancel();
                    showCallBox = false;
                    setState(() {
                    });
                  },
                  child: Icon(Icons.call_end),
                ),
              ],),
            ),
          )
        ],
      ),
    );
  }

  Drawer pendingStateDrawer(){
    return Drawer(
      child: Consumer<CreatedTimeProvider>(
        builder: (context,state,child){
          return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            SizedBox(height: 60,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '"Tienes una alerta ',
                style: alertMessagetStyle,
                children: <TextSpan>[
                  TextSpan(text: 'recibida"', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 30,),
            Text("Han pasado ${state.getMinutes()} minutos", style:alertTimertStyle,textAlign: TextAlign.center,),
            FlatButton(
              color: secondary,
              onPressed: (){},
              child: Text("Rechazar", style:buttonStyeText,),
            ),
            SizedBox(height: 60,),
          ],),
        );
      },
      ),
    );
  }
  Drawer acceptedStateDrawer(){
    return Drawer(
      child: Consumer<CreatedTimeProvider>(
        builder: (context,state,child){
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
              SizedBox(height: 60,),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '"Tienes una alerta ',
                  style: alertMessagetStyle,
                  children: <TextSpan>[
                    TextSpan(text: 'aceptada"', style: TextStyle(fontWeight: FontWeight.bold,color: primary)),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Text("Han pasado ${state.getMinutes()} minutos", style:alertTimertStyle, textAlign: TextAlign.center,),
              FlatButton(
                // color: secondary,
                onPressed: (){},
                child: Text("marcar como leida", style:markAsReadedText,),
              ),
              SizedBox(height: 60,),
            ],),
          );
        },
      ),
    );
  }
  Drawer doneStateDrawer(){
    return Drawer(
      child: Consumer<CreatedTimeProvider>(
        builder: (context,state, child){
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
              SizedBox(height: 60,),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '"Tienes una alerta ',
                  style: alertMessagetStyle,
                  children: <TextSpan>[
                    TextSpan(text: 'Atendida"', style: TextStyle(fontWeight: FontWeight.bold,color: my_green)),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Text("Han pasado ${state.getMinutes()} minutos", style:alertTimertStyle, textAlign: TextAlign.center,),
              FlatButton(
                // color: secondary,
                onPressed: (){},
                child: Text("ir a home", style:markAsReadedText,),
              ),
              SizedBox(height: 60,),
            ],),
          );
        },
      ),
    );
  }
  Drawer rejectedStateDrawer(){
    return Drawer(
      child: Consumer<CreatedTimeProvider>(
        builder: (context,state,child){
          return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            SizedBox(height: 60,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '"Tienes una alerta ',
                style: alertMessagetStyle,
                children: <TextSpan>[
                  TextSpan(text: 'rechazada"', style: TextStyle(fontWeight: FontWeight.bold,color: my_red)),
                ],
              ),
            ),
            SizedBox(height: 30,),
            Text("Han pasado ${state.getMinutes()} minutos", style:alertTimertStyle,textAlign: TextAlign.center,),
            FlatButton(
              // color: secondary,
              onPressed: (){},
              child: Text("ir a home", style:markAsReadedText,),
            ),
            SizedBox(height: 60,),
          ],),
        );
      },
    ),
    );
  }
}

class ButtonDrawer extends StatelessWidget {
  final Color color;
  ButtonDrawer(this.color);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed:(){
        Scaffold.of(context).openDrawer();
      },
      child: Icon(Icons.notification_important, color: this.color, size: 30,),
    );
  }
}
