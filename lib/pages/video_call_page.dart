import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/status_bar.dart';

// Agora AppId
const String APP_ID = '44bd4f6553754929b4fded09c4729c92';

class VideoCallPage extends StatefulWidget {

  final String channelName;
  const VideoCallPage({Key key, this.channelName = "1"}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<VideoCallPage> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  int _user_quality = 0;
  bool muted = false;

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  
  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark
      )
    );
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  
  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

    /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onNetworkQuality = (
      int uid,
      int txQuality,
      int rxQuality 
      ){
        setState(() {
          _user_quality = txQuality;
        });
        //QUALITY_UNKNOWN(0): The quality is unknown.
        //QUALITY_EXCELLENT(1): The quality is excellent.
        //QUALITY_GOOD(2): The quality is quite good, but the bitrate may be slightly lower than excellent.
        //QUALITY_POOR(3): Users can feel the communication slightly impaired.
        //QUALITY_BAD(4): Users can communicate not very smoothly.
        //QUALITY_VBAD(5): The quality is so bad that users can barely communicate.
        //QUALITY_DOWN(6): The network is disconnected and users cannot communicate at all.
        //QUALITY_DETECTING(8): The SDK is detecting the network quality.

    };
  }

    /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

    /// Video view wrapper // ? DELETE THIS
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

    /// Video view row wrapper // ? DELETE THIS PART
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper // * REFACTOR FOR 2 USERS 
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return _mainPreview(context,views[0]);
      case 2:
        return Stack(
          children: <Widget>[
        _mainPreview(context,views[1]),
        _drawBackAndPreview(views[0]),
        // _expandedVideoRow([views[0]]),
        // _expandedVideoRow([views[1]])
          ],
        );
      // case 3:
      //   return Container(
      //       child: Column(
      //     children: <Widget>[
      //       _expandedVideoRow(views.sublist(0, 2)),
      //       _expandedVideoRow(views.sublist(2, 3))
      //     ],
      //   ));
      // case 4:
      //   return Container(
      //       child: Column(
      //     children: <Widget>[
      //       _expandedVideoRow(views.sublist(0, 2)),
      //       _expandedVideoRow(views.sublist(2, 4))
      //     ],
      //   ));
      default:
    }
    return Container();
  }
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MaterialButton(
            height: 50,
            minWidth: 50,
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Color(0xff433879),
              size: 20.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            elevation: 2.0,
            color: muted ? Colors.black45 : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          MaterialButton(
            height: 50,
            minWidth: 50,
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.white,
              size: 20.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            elevation: 2.0,
            color: Color(0xff433879),
            padding: const EdgeInsets.all(12.0),
            highlightColor:  Color(0xff574A97),
            highlightElevation: 12,
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
    // TODO Make sure agora engine is closed !
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  Widget _callInformation(){
    //TODO Refactor this part, change Positioned
    return Container(
          // margin: EdgeInsets.all(12),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 30),
          child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: double.infinity,),
        Text("Audrey Hawkins", 
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
    Shadow(color: Colors.black38, blurRadius: 6)
            ]
          ),),
        SizedBox(height: 4,),
        Text("Doctora at Sahagun Hospital",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            shadows: [
    Shadow(color: Colors.black38, blurRadius: 6)
            ]
          ),),
        SizedBox(height: 4,),
        Container(
          child: Text("23:12",style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            shadows: [
    Shadow(color: Colors.black38, blurRadius: 6)
            ]
          ),),
          width: 70,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.4),
            borderRadius: BorderRadius.circular(8)
          ),
        )
      ],
          ),
        );
  }


  @override
  Widget build(BuildContext context) {
    defaultStatusBar();
    return WillPopScope(
      onWillPop: ()async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xff574A97),
        body: Stack(
          // fit: StackFit.expand, //TODO Fix this
          children: <Widget>[
            // SizedBox(width: double.infinity,),
            // _mainPreview(context,null),
            _viewRows(),
          // _drawBackAndPreview(null),
            _netWorkButton(),
          _toolbar(),
          _callInformation(),
          ],
       ),
   ),
    );
  }

  Widget _netWorkButton(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Container(
          margin: EdgeInsets.only(left: 23, top:30),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: (){},
            child:  Text("$_user_quality", style: TextStyle(color: Colors.black),)
          ),
        ),
        Expanded(child: Container())
      ] 
    );
  }

  Widget _mainPreview(BuildContext context, view ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ) ,
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.80, //TODO determinar el alto maximo
      child: ClipRRect(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          child: view,
          // child: Image.network("https://a.storyblok.com/f/67603/900x1391/49db222deb/jenny-yu-06.jpg",
          //     fit: BoxFit.fill,
          // ),
      ),
    );
  }


  Widget _drawBackAndPreview(view) {
    return Container(
        margin: EdgeInsets.only(left: 10, top: 30),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(),
              // width: 0,
              // height: 0,
            ),
            // FloatingActionButton(
            //   backgroundColor: Colors.white,
            //   onPressed: (){},
            //   child:  Text("$_user_quality", style: TextStyle(color: Colors.black),)
            // ),
            Stack(
              children: <Widget>[
                view !=null ? Container(
                  width: 110,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(.4), blurRadius: 6),
                      // BoxShadow(color: Colors.green),
                    ]
                  ),
                ) : Container(),
                ClipRRect(
                borderRadius:BorderRadius.circular(30) ,
                // clipBehavior : Clip.antiAliasWithSaveLayer,
                child: Container(
                  width: 110,
                  height: 140,
                  // alignment: Alignment.topRight,
                  // color: Colors.red,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // color: Colors.black54,
                  ),
                  child: view,
                  // child: Image.network("https://via.placeholder.com/110x140"),
                )
              ),
              ],
            )
          ],
        ),
      );
  }
}
