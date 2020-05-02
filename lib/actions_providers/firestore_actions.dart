import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// import './shared_preferences_provider.dart';
class FirestoreActions {

  FirestoreActions();

  // static final prefs = new UserPreferences();

  // final String pushToken = prefs.getPushToken();
  final alertCollection = Firestore.instance.collection("alerts");
  final tokenDocument = Firestore.instance.collection("fireman_info").document('bomberosToken');

  saveTokenToFireStore(String token) async {
   DocumentSnapshot doc =  await tokenDocument.get();
   if(doc.exists){
    await tokenDocument.updateData({
      "token" : token,
    });
   }else{
    await tokenDocument.setData({
      "token" : token,
    });
   }
  }

  Future<void> acceptOrRejectAlert({
    @required String document,
    @required int state}){
    alertCollection.document(document).updateData({
      "state" : state
    });
  }

}
