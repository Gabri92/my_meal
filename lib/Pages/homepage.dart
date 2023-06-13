import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../globals.dart' as globals;
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
          color: Colors.blue,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (badState) ...[
              const Text(
                'Prodotto non valido',
              ),
            ] else ...[
              Text(
                document['Nome'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                DateFormat.yMd().format(expireDate),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]
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
            Container(
                constraints: BoxConstraints(
                  maxHeight:
                      Theme.of(context).textTheme.headlineMedium!.fontSize! *
                              1.1 +
                          200.0,
                ),
                padding: const EdgeInsets.all(16),
                color: Colors.blue,
                child: Column(
                  children: [
                    const Text(
                      "Alimenti in scadenza",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                    ),
                    const SizedBox(height: 5),
                    StreamBuilder<QuerySnapshot>(
                      stream: _storageRef,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                          );
                        }
                      },
                    ),
                  ],
                )),
            const SizedBox(height: 70),
            ElevatedButton.icon(
              icon: const Icon(Icons.food_bank_outlined, size: 32),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text(
                'Vai alla dispensa',
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
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.new_label, size: 32),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text(
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
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.share, size: 32),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text(
                'Condividi la dispensa',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app, size: 32),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.red,
              ),
              label: const Text(
                'log Out',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
