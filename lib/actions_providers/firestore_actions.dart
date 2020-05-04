import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/alert.model.dart';
// import './shared_preferences_provider.dart';
class FirestoreActions {

  static final FirestoreActions _instancia = new FirestoreActions._internal();

  factory FirestoreActions() {
    return _instancia;
  }

  FirestoreActions._internal();

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
    @required int state}) async{
    await alertCollection.document(document).updateData({
      "state" : state
    });
  }

  Future<AlertInformation> getDocument(documentRef) async {
    DocumentSnapshot doc = await alertCollection.document(documentRef).get();
    AlertInformation data;
    if (doc.exists){
      data = AlertInformation(
        imageUrl  : doc.data["getDownloadUrl"] as String,
        category  : doc.data["categories"] as String,
        latitude  : doc.data["latitude"] as double,
        longitude : doc.data["longitude"] as double,
        userId    : doc.data["userId"] as String,
        state     : doc.data["state"] as int,
        created   :  doc.data["created"]
      );
    }

    return data;
  }

}
