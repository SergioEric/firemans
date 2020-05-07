import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void defaultStatusBar(){
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xffA593E0),
      statusBarBrightness: Brightness.light
    )
  );
}
