import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_meal/Pages/shared.dart';

import '../../globals.dart' as globals;
import '../../utils.dart' as utils;
import 'storage.dart';

//HOMEPAGE
class HomePage extends StatefulWidget {
  final Future<void> userCredentials;

  const HomePage({super.key, required this.userCredentials});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _storageRef = FirebaseFirestore.instance
      .collection("Storages")
      .doc(globals.userCredential?.storageID) //TODO: Generalizzare
      .collection("Dispensa")
      .orderBy("Scadenza")
      .where(
        "Scadenza",
        isLessThan: Timestamp.fromDate(
          DateTime.now().add(
            const Duration(days: 5),
          ),
        ),
      )
      .snapshots();

  final Stream<QuerySnapshot> _invitationRef = FirebaseFirestore.instance
      .collection('Invitations')
      .snapshots(); //globals.userCredential?.email)

  Widget _buildListItem(BuildContext context, QueryDocumentSnapshot document) {
    bool badState = false;
    DateTime expireDate;

    if (document.data().toString().contains('Nome') &&
        document.data().toString().contains('Scadenza')) {
      Timestamp expireDateTimeStamp = document['Scadenza'];
      expireDate = expireDateTimeStamp.toDate();
      badState = false;
    } else {
      expireDate = DateTime.now();
      badState = true;
    }

    return ListTile(
      title: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (badState) ...[
              const Text(
                'Prodotto non valido',
              ),
            ] else ...[
              Text(
                document['Nome'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(185, 0, 0, 0)),
              ),
              Text(
                DateFormat.yMd().format(expireDate),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 120, 30, 0)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _invitationDialog(BuildContext context, QueryDocumentSnapshot doc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color.fromARGB(64, 255, 251, 9),
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
          border: Border.all(
            color: const Color.fromARGB(255, 99, 97, 5),
            width: 1.5,
          )),
      child: SizedBox(
        height: 75,
        width: 320,
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                text:
                    'Hai ricevuto un invito di condivisione della dispensa da: ',
                style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.black),
                children: [
                  TextSpan(
                    text: doc['Subject'].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    height: 30,
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        foregroundColor: Colors.greenAccent,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Accetta',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )),
                SizedBox(
                    height: 30,
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Rifiuta',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.all(30)),
            Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: _invitationRef,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        var docs = snapshot.data!.docs.where((element) =>
                            element['Subject'] ==
                            globals.userCredential?.email);
                        if (docs.isNotEmpty) {
                          return _invitationDialog(context, docs.first);
                        } else {
                          return Container(
                            height: 0,
                          );
                        }
                      } else {
                        return Container(height: 0);
                      }
                    }),
                const SizedBox(height: 25),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 120, 30, 0),
                          width: 1.0),
                      color: const Color.fromARGB(255, 120, 30, 0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0))),
                  child: const SizedBox(
                      child: Text(
                    "Alimenti in scadenza",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.white),
                  )),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0))),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _storageRef,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }
                      if (snapshot.hasData) {
                        return SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10),
                            itemExtent: 40.0,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) => _buildListItem(
                                context, snapshot.data!.docs[index]),
                          ),
                        );
                      } else {
                        return const Text(
                          'Niente',
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            SizedBox(
              height: 60,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  backgroundColor: const Color(utils.primaryColor),
                ),
                child: const Text(
                  'Vai all\' intera dispensa',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StoragePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 60,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  backgroundColor: const Color(utils.primaryColor),
                ),
                child: const Text(
                  'Inserisci nuovi prodotti',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NewProductPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 60,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  backgroundColor: const Color(utils.primaryColor),
                ),
                child: const Text(
                  'Condividi la dispensa',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ShareStoragePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
