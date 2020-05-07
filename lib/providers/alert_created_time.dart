import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class CreatedTimeProvider with ChangeNotifier{

  int _minutes = 0;

  int getMinutes() => this._minutes;

  set minutes(int number){
    this._minutes = number;
    notifyListeners();
  }

  int _state;

  int get state => this._state;

  set state(int val){
    this._state = val;
    notifyListeners();
  }

  String _userId;

  String get userId => this._userId;

  set userId(String id){
    this._userId = id;
    // notifyListeners();
  }

  LatLng _location;

  LatLng get location => this._location;

  void setLocation(double lat, double lon){
    this._location = LatLng(lat, lon);
  }

}
