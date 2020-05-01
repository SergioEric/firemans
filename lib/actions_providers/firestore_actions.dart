import 'package:cloud_firestore/cloud_firestore.dart';

// import './shared_preferences_provider.dart';
class FirestoreActions {

  FirestoreActions();

  // static final prefs = new UserPreferences();

  // final String pushToken = prefs.getPushToken();

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

}
