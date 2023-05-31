import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../globals.dart' as globals;
import '../../main.dart';
import 'storage.dart';

//HOMEPAGE
class HomePage extends StatefulWidget {
  final Future<void> userCredentials;

  const HomePage({super.key, required this.userCredentials});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.all(30)),
            Container(
              constraints: BoxConstraints.expand(
                height: Theme.of(context).textTheme.headlineMedium!.fontSize! *
                        1.1 +
                    200.0,
              ),
              padding: const EdgeInsets.all(24),
              color: Colors.blue,
              child: const Text(
                "Alimenti in scadenza",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
            ),
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
      bottomNavigationBar: const BottomAppNavBar(),
    );
  }
}
