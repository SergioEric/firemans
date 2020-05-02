import '../actions_providers/firestore_actions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class OnAlertComingPage extends StatelessWidget {
  
  FirestoreActions fstore = FirestoreActions();

  @override
  Widget build(BuildContext context) {
    final String doc = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            // height: 400,
            child: Align(
              alignment: Alignment.center,
              child: StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('alerts').document(doc).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting: return new Text('Loading...');
                  default:
                    return Column(
                      children: <Widget>[
                        new ListTile(
                            title: Text(snapshot.data["categories"]),
                            subtitle: Text(snapshot.data.documentID),
                            trailing: (snapshot.data["state"] == 0)
                            ? Text("pendiente")
                              : (snapshot.data["state"] == 1)
                               ? Text("aceptada") 
                                  : Text("rechazada"),
                        ),
                        Image.network(snapshot.data["getDownloadUrl"], fit: BoxFit.fitHeight, height: 220,)
                      ],
                    );
                }
              },
                ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(width: 40,),
              RawMaterialButton(
                onPressed: (){
                  fstore.acceptOrRejectAlert(document: doc, state: 1);
                },
                child: Text("Aceptar", style: TextStyle(color: Colors.white),),
                fillColor: Colors.green,
              ),
              RawMaterialButton(
                onPressed: (){
                  fstore.acceptOrRejectAlert(document: doc, state: 2);
                },
                child: Text("Rechazar", style: TextStyle(color: Colors.white),),
                fillColor: Colors.redAccent,
              ),
              SizedBox(width: 40,),
            ],
          )
        ],
      ),
   );
  }
}
