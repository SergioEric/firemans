import 'package:cloud_firestore/cloud_firestore.dart';

class AlertInformation{

  final String userId;
  final double latitude;
  final double longitude;
  final String category;
  final String imageUrl;
  final int state;
  final Timestamp created;

  AlertInformation(
  {  this.userId,
    this.latitude,
    this.longitude,
    this.category,
    this.imageUrl,
    this.state,
    this.created}
  );

}
