import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../globals.dart' as globals;
import '../main.dart';
import '../utils.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final Stream<QuerySnapshot> _storageRef = FirebaseFirestore.instance
      .collection("Storages")
      .doc('goUrDkyiqb62WpzgOWP3') //TODO: Generalizzare
      .collection("Dispensa")
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ModifyProductPage(),
          ),
        );
      },
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
    const title = 'La tua Dispensa Digitale';

    // TEST OFFLINE
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _storageRef,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemExtent: 50.0,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data!.docs[index]),
            );
          } else {
            return const Text(
              'Niente',
            );
          }
        },
      ),
      bottomNavigationBar: const BottomAppNavBar(),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

class NewProductPage extends StatefulWidget {
  const NewProductPage({super.key});

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final TextEditingController productController = TextEditingController();
  final TextEditingController dateInputController = TextEditingController();

  @override
  void initState() {
    dateInputController.text = "";
    super.initState();
  }

  void sendProductToDb() {
    final dbRef = FirebaseFirestore.instance
        .collection("Storages")
        .doc('goUrDkyiqb62WpzgOWP3') //TODO: Generalizzare
        .collection("Dispensa");

    if (productController.text == "" || dateInputController.text == "") {
      Utils.showSnackBar("Mancano dei dati");
      return;
    }

    dbRef.where("Nome", isEqualTo: productController.text).count().get().then(
      (res) {
        if (res.count != 0) {
          Utils.showSnackBar("Prodotto già presente in dispensa");
          return;
        } else {
          final data = <String, dynamic>{
            "Nome": productController.text,
            "Scadenza": Timestamp.fromDate(
              DateTime.parse(dateInputController.text),
            ),
          };
          dbRef.add(data).then((value) {
            print("Prodotto aggiunto!");
            productController.text = "";
            dateInputController.text = "";
          }, onError: (e) => print("Errore: $e"));
        }
      },
      onError: (e) => Utils.showSnackBar("Si è verificato un errore: $e"),
    );

    // Utils.showSnackBar('Prodotto già esistente in dispensa');
    //TODO: Inserire circularprogressindicator
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Inserimento prodotto',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const FlutterLogo(size: 120),
              const SizedBox(height: 20),
              TextFormField(
                controller: productController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Inserisci il prodotto...'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    value == null ? 'Inserire un prodotto' : null,
              ),
              TextFormField(
                controller: dateInputController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    labelText: 'Inserisci la data di scadenza...'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    value == null ? 'Inserire la data di scadenza' : null,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100));

                  if (pickedDate != null) {
                    setState(() {
                      dateInputController.text = pickedDate.toString();
                      // DateFormat.yMd().format(pickedDate); //TODO: RIVEDERE
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.plus_one_outlined, size: 32),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                label: const Text(
                  'Inserisci',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: sendProductToDb,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: const BottomAppNavBar(),
      );
}

class ModifyProductPage extends StatefulWidget {
  @override
  State<ModifyProductPage> createState() => _ModifyProductPageState();
}

class _ModifyProductPageState extends State<ModifyProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Modifica il tuo prodotto',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const BottomAppNavBar(),
    );
  }
}

// class Product {
//   String? name;
//   String? category;
//   Timestamp? expireDate;

//   Product({
//     this.name,
//     this.category,
//     this.expireDate,
//   });

//   factory Product.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> snapshot,
//     SnapshotOptions options,
//   ) {
//     final data = snapshot.data();
//     return Product(
//       name: data?['Nome'],
//       category: data?['Categoria'],
//       expireDate: data?['Scadenza'],
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       if (name != null) "Nome": name,
//       if (category != null) "Categoria": category,
//       if (expireDate != null) "Scadenza": expireDate,
//     };
//   }

//   bool isNull(var value) {
//     if (value != null) {
//       return false;
//     } else {
//       return true;
//     }
//   }
// }
