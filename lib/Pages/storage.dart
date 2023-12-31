import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../globals.dart' as globals;
import '../../Utils.dart' as utils;

class StoragePage extends StatefulWidget {
  static const String route = '/home/storage';
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

enum Order { byDefault, byName, byDate }

class _StoragePageState extends State<StoragePage> {
  Color btnColor = Colors.blue;
  Order order = Order.byDefault;
  TextEditingController editingController = TextEditingController();

  var _storageRef;

  // TODO: Aggiustare
  @override
  void initState() {
    _storageRef = FirebaseFirestore.instance
        .collection("Storages")
        .doc(globals.userCredential?.storageID) //TODO: Generalizzare
        .collection("Dispensa")
        .snapshots();
    super.initState();
  }

  // void filterSearchResults(String query) {
  //   setState(() {
  //     if (query == "") {
  //       _storageRef = FirebaseFirestore.instance
  //           .collection("Storages")
  //           .doc(globals.userCredential?.storageID)
  //           .collection("Dispensa")
  //           .snapshots();
  //     } else {
  //       _storageRef = FirebaseFirestore.instance
  //           .collection("Storages")
  //           .doc(globals.userCredential?.storageID)
  //           .collection("Dispensa")
  //           .where("Nome", isGreaterThanOrEqualTo: query)
  //           .snapshots();
  //     }
  //   });
  // }

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
            builder: (context) => ModifyProductPage(document: document),
          ),
        );
      },
      title: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          // color: Color(utils.primaryColor),
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (badState) ...[
              const Text(
                'Prodotto non valido',
              ),
            ] else ...[
              Text(
                document['Nome'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat.yMd().format(expireDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
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
        backgroundColor: const Color(utils.primaryColor),
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
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Center(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(
                  //       width: 2,
                  //       color: const Color(utils.primaryColor),
                  //     ),
                  //     borderRadius: const BorderRadius.all(Radius.circular(28)),
                  //   ),
                  //   child: SizedBox(
                  //     height: 50,
                  //     width: 350,
                  //     child: TextField(
                  //       onChanged: (value) {
                  //         filterSearchResults(value);
                  //       },
                  //       controller: editingController,
                  //       decoration: const InputDecoration(
                  //         labelText: 'Search',
                  //         hintText: 'Search',
                  //         prefixIcon: Icon(Icons.search,
                  //             color: Color(utils.primaryColor)),
                  //         border: OutlineInputBorder(
                  //           borderRadius:
                  //               BorderRadius.all(Radius.circular(25.0)),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 140,
                          child: ElevatedButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(utils.primaryColor),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                            ),
                            icon: const Icon(Icons.abc),
                            label: const Text('Nome'),
                            onPressed: () => setState(
                              () {
                                if (order == Order.byDefault ||
                                    order == Order.byDate) {
                                  _storageRef = FirebaseFirestore.instance
                                      .collection("Storages")
                                      .doc(globals.userCredential
                                          ?.storageID) //TODO: Generalizzare
                                      .collection("Dispensa")
                                      .orderBy("Nome")
                                      .snapshots();
                                  order = Order.byName;
                                } else {
                                  _storageRef = FirebaseFirestore.instance
                                      .collection("Storages")
                                      .doc(globals.userCredential
                                          ?.storageID) //TODO: Generalizzare
                                      .collection("Dispensa")
                                      .snapshots();
                                  order = Order.byDefault;
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: ElevatedButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color(utils.primaryColor),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                              ),
                              icon: const Icon(Icons.abc),
                              label: const Text('Scadenza'),
                              onPressed: () => setState(() {
                                    if (order == Order.byDefault ||
                                        order == Order.byName) {
                                      _storageRef = FirebaseFirestore.instance
                                          .collection("Storages")
                                          .doc(globals.userCredential
                                              ?.storageID) //TODO: Generalizzare
                                          .collection("Dispensa")
                                          .orderBy("Scadenza")
                                          .snapshots();
                                      order = Order.byDate;
                                    } else {
                                      _storageRef = FirebaseFirestore.instance
                                          .collection("Storages")
                                          .doc(globals.userCredential
                                              ?.storageID) //TODO: Generalizzare
                                          .collection("Dispensa")
                                          .snapshots();
                                      order = Order.byDefault;
                                    }
                                  })),
                        )
                      ]),
                  SizedBox(
                    height: 500, //TODO: Se ho un altro schermo?
                    child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemExtent: 50.0,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                              key: UniqueKey(),
                              onDismissed: (direction) {
                                FirebaseFirestore.instance
                                    .collection("Storages")
                                    .doc(globals.userCredential?.storageID)
                                    .collection("Dispensa")
                                    .doc(snapshot.data!.docs[index].id)
                                    .delete();
                              },
                              background: Container(color: Colors.red),
                              child: _buildListItem(
                                  context, snapshot.data!.docs[index]));
                        }),
                  ),
                ],
              ),
            ));
          } else {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxHeight > 700) {
                  return _buildNormalEmptyPage();
                } else {
                  return _buildSmallerEmptyPage();
                }
              },
            );
          }
        },
      ),
      // bottomNavigationBar: const MainScreen(),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(utils.primaryColor),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewProductPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNormalEmptyPage() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dispensa.png',
                  width: 300, height: 300),
              const SizedBox(height: 40),
              const Text(
                'Inizia inserendo il tuo primo prodotto nella Dispensa Digitale.'
                ' Inquadra l’ alimento con la fotocamera del telefono o inserisci i dati manualmente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallerEmptyPage() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dispensa.png',
                  width: 250, height: 250),
              const SizedBox(height: 20),
              const Text(
                'Inizia inserendo il tuo primo prodotto nella Dispensa Digitale.'
                ' Inquadra l’ alimento con la fotocamera del telefono o inserisci i dati manualmente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
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

  @override
  void dispose() {
    productController.dispose();
    dateInputController.dispose();

    super.dispose();
  }

  void sendProductToDb() {
    final dbRef = FirebaseFirestore.instance
        .collection("Storages")
        .doc(globals.userCredential?.storageID) //TODO: Generalizzare
        .collection("Dispensa");

    if (productController.text == "" || dateInputController.text == "") {
      utils.Utils.showSnackBar("Mancano dei dati", Colors.red);
      return;
    }

    dbRef.where("Nome", isEqualTo: productController.text).count().get().then(
      (res) {
        if (res.count != 0) {
          utils.Utils.showSnackBar(
              "Prodotto già presente in dispensa", Colors.red);
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
      onError: (e) =>
          utils.Utils.showSnackBar("Si è verificato un errore: $e", Colors.red),
    );

    // Utils.showSnackBar('Prodotto già esistente in dispensa');
    //TODO: Inserire circularprogressindicator
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(utils.primaryColor),
          title: const Text(
            'Inserimento prodotto',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxHeight > 700) {
              return _buildNormalNewPage();
            } else {
              return _buildSmallerNewPage();
            }
          },
        ),
      );

  Widget _buildNormalNewPage() {
    return Form(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dispensa.png',
                  width: 300, height: 300),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 325,
                child: TextFormField(
                  controller: productController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci il prodotto...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value == null ? 'Inserire un prodotto' : null,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: 325,
                child: TextFormField(
                  controller: dateInputController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci la data di scadenza...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
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
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 60,
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    backgroundColor: const Color(utils.primaryColor),
                  ),
                  onPressed: sendProductToDb,
                  child: const Text(
                    'Inserisci prodotto',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallerNewPage() {
    return Form(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dispensa.png',
                  width: 200, height: 200),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: 320,
                child: TextFormField(
                  controller: productController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci il prodotto...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value == null ? 'Inserire un prodotto' : null,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 320,
                child: TextFormField(
                  controller: dateInputController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci la data di scadenza...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
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
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 50,
                width: 280,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    backgroundColor: const Color(utils.primaryColor),
                  ),
                  onPressed: sendProductToDb,
                  child: const Text(
                    'Inserisci prodotto',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ModifyProductPage extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const ModifyProductPage({super.key, required this.document});

  Map<String, dynamic> getData() {
    Map<String, dynamic> productDetails = {
      "name": document["Nome"],
      "expire": document["Scadenza"],
    };

    return productDetails;
  }

  @override
  State<ModifyProductPage> createState() => _ModifyProductPageState();
}

class _ModifyProductPageState extends State<ModifyProductPage> {
  final TextEditingController productController = TextEditingController();
  final TextEditingController dateInputController = TextEditingController();

  void sendProductToDb() {
    final dbRef = FirebaseFirestore.instance
        .collection("Storages")
        .doc(globals.userCredential?.storageID) //TODO: Generalizzare
        .collection("Dispensa");

    if (productController.text == "" || dateInputController.text == "") {
      utils.Utils.showSnackBar("Mancano dei dati", Colors.red);
      return;
    }

    dbRef
        .where("Nome", isEqualTo: productController.text)
        .where("Scadenza",
            isEqualTo: Timestamp.fromDate(
              DateTime.parse(dateInputController.text),
            ))
        .count()
        .get()
        .then(
      (res) {
        if (res.count != 0) {
          utils.Utils.showSnackBar(
              "Prodotto già presente in dispensa", Colors.red);
          return;
        } else {
          final data = <String, dynamic>{
            "Nome": productController.text,
            "Scadenza": Timestamp.fromDate(
              DateTime.parse(dateInputController.text),
            ),
          };
          dbRef.doc(widget.document.id).update(data).then((value) {
            utils.Utils.showSnackBar(
                "Modifiche salvate con successo!", Colors.green);
          }, onError: (e) => print("Errore: $e"));
        }
      },
      onError: (e) =>
          utils.Utils.showSnackBar("Si è verificato un errore: $e", Colors.red),
    );

    // Utils.showSnackBar('Prodotto già esistente in dispensa');
    //TODO: Inserire circularprogressindicator
  }

  String timestampToString(Timestamp t) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(t.seconds * 1000);

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSSS');
    final String formattedText = formatter.format(date);
    return formattedText;
  }

  @override
  void dispose() {
    productController.dispose();
    dateInputController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    productController.text = widget.document["Nome"];
    dateInputController.text = timestampToString(widget.document["Scadenza"]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(utils.primaryColor),
        title: const Text(
          'Modifica il tuo prodotto',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxHeight > 700) {
            return _buildNormalModPage();
          } else {
            return _buildSmallerModPage();
          }
        },
      ),
    );
  }

  Widget _buildNormalModPage() {
    return Form(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dispensa.png',
                  width: 300, height: 300),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 325,
                child: TextFormField(
                  controller: productController,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci il prodotto...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  validator: (value) =>
                      value == null ? 'Inserire un prodotto' : null,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: 325,
                child: TextFormField(
                  controller: dateInputController,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci il prodotto...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
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
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 60,
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    backgroundColor: const Color(utils.primaryColor),
                  ),
                  onPressed: sendProductToDb,
                  child: const Text(
                    'Salva le modifiche',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallerModPage() {
    return Form(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dispensa.png',
                  width: 200, height: 200),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: 320,
                child: TextFormField(
                  controller: productController,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci il prodotto...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  validator: (value) =>
                      value == null ? 'Inserire un prodotto' : null,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 320,
                child: TextFormField(
                  controller: dateInputController,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Inserisci il prodotto...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
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
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 50,
                width: 280,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    backgroundColor: const Color(utils.primaryColor),
                  ),
                  onPressed: sendProductToDb,
                  child: const Text(
                    'Salva le modifiche',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
