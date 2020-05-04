import 'package:flutter/foundation.dart';


class CreatedTimeProvider with ChangeNotifier{

  int _minutes = 0;

  int getMinutes() => this._minutes;

  set minutes(int number){
    this._minutes = number;
    notifyListeners();
  }

}
