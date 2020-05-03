import 'package:bomberos/providers/push_notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
  
import '../actions_providers/shared_preferences_provider.dart';
import '../actions_providers/firestore_actions.dart';

import '../models/alert.model.dart';

import './maps.page.dart';

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
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Icon(Icons.dashboard, color: Colors.black,),
        ),
        drawer: Drawer(),
        body: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(doc),
            FutureBuilder(
              future: alert,
              builder: (BuildContext context, AsyncSnapshot<AlertInformation> snapshot){
                List<Widget> children;
                if(snapshot.hasData) {
                  prefs.setDocumentAlertId(doc);
                  // prefs.setState(0);
                  children =[
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Align(
                      alignment: Alignment.topCenter,
                      child: Text("${snapshot.data.category}"))),
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
            (alertAcepted == 0) ? Container(
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
                          alertAcepted = 1;
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
                                      if(prefs.getState() != null){
                                        prefs.setState(2);
                                        // await prefs.removeState();
                                        // await prefs.removeDocumentAlertId();
                                      }
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
            (showCallBox) ? onCallInComing() : Container(),
            (prefs.getState() == 0) ?
              Container(child: Align(
                alignment: Alignment.bottomRight,
                child: Text("received", style: TextStyle(color: Colors.red),)),)
              : (prefs.getState() == 1) 
                ? Container(child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text("accepted")),)
                    : Container(child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text("rejected")),)
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
}
