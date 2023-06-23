library globals;

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

UserCredentials? userCredential;

class UserCredentials {
  String? email;
  String? storageID;
  String? uid;
  String? username;

  UserCredentials({this.email, this.storageID, this.uid, this.username});

  factory UserCredentials.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    // SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserCredentials(
      email: data?["email"],
      storageID: data?["storageID"],
      uid: data?["uid"],
      username: data?["username"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "email": email,
      if (storageID != null) "storageID": storageID,
      if (uid != null) "uid": uid,
      if (username != null) "username": username,
    };
  }
}
