library globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final storageDB = FirebaseFirestore.instance;
final userAuth = FirebaseAuth.instance;

DocumentReference? userDoc;
DocumentReference? storageDoc;
