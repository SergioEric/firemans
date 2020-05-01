import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/directions_provider.dart';

class MapsPage extends StatefulWidget {

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  GoogleMapController _mapController;

  // static final alertPosition = LatLng(8.9372859, -75.4413706);
  static final alertPosition = LatLng(8.9466781, -75.4430247); //parque central
  static final bomberosPosition = LatLng(8.9354, -75.4411);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: alertPosition,
    zoom: 14.4746,
    // zoom: 19.151926040649414,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

@override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top:24),
          child: 
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: onMapCreated,
              markers:_createMarkers() ,
              // polylines: ,
            )
          ),
        Container(
          margin: EdgeInsets.only(bottom: 24),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
            // mini: true,
            onPressed: _centerView,
            child: Icon(Icons.zoom_out_map),
            // label: Text("centrar"),
            // icon: Icon(Icons.directions_boat),
          ),
          ),
        )
      ],
    );
  }

  Set<Marker> _createMarkers(){
    var temp =Set<Marker>();

    temp.add(Marker(
      position: alertPosition,
      markerId: MarkerId("m1 alertPosition"),
      infoWindow : InfoWindow(title: "Alerta")
    ));
    
    temp.add(Marker(
      position: bomberosPosition,
      markerId: MarkerId("m2 bomberosPosition")
    ));

    return temp;
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void _centerView() async {
    // final GoogleMapController controller = await _controller.future;
    // var api = Provider.of<DirectionProvider>(context, listen: false);

    await _mapController.getVisibleRegion();

     print("buscando direcciones");
     
    //  api.findDirections(bomberosPosition, alertPosition);

    var left = math.min(bomberosPosition.latitude, alertPosition.latitude);
    var right = math.max(bomberosPosition.latitude, alertPosition.latitude);

    var top = math.max(bomberosPosition.longitude, alertPosition.longitude);
    var bottom = math.min(bomberosPosition.longitude, alertPosition.longitude);

    
    // api.currentRoute.first.points.forEach((point) {
    //   left = math.min(left, point.latitude);
    //   right = math.max(right, point.latitude);
    //   top = math.max(top, point.longitude);
    //   bottom = math.min(bottom, point.longitude);
    // });
    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top)
      );

    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
    _mapController.animateCamera(cameraUpdate);

  }

  void onMapCreated(GoogleMapController controller) {
    // _controller.complete(controller);
    _mapController = controller;
    _centerView();
  }
}
