import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';

import '../../globals.dart' as globals;
import '../../utils.dart' as utils;
import 'storage.dart';

class ShareStoragePage extends StatefulWidget {
  const ShareStoragePage({super.key});

  @override
  State<ShareStoragePage> createState() => _ShareStoragePageState();
}

class _ShareStoragePageState extends State<ShareStoragePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final _invitationRef = FirebaseFirestore.instance.collection("Invitations");

  Future setInvitation() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    int queryCount = 0;
    await _invitationRef
        .where("Subject", isEqualTo: emailController.text)
        .get()
        .then(
          (value) => queryCount = value.size,
          onError: (e) => print(e), //TODO: Togli print
        );

    if (queryCount != 0) {
      utils.Utils.showSnackBar(
          "L'utente ha già ricevuto un altro invito", Colors.red);
      return;
    }

    final invitation = <String, dynamic>{
      'Invited by': globals.userCredential?.email.toString(),
      'Subject': emailController.text,
    };

    _invitationRef.add(invitation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(utils.primaryColor),
        title: const Text(
          'Condividi la tua dispensa',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/shared.png',
                    width: 300, height: 300),
                const SizedBox(height: 20),
                const Text('Condividi la tua dispensa!',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                      'Aggiungi l\'email della persona che vuoi aggiungere per invitarlo ad unirsi alla tua dispensa',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                ),
                const SizedBox(height: 20), //80
                SizedBox(
                  height: 50,
                  width: 325,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        fillColor: Color.fromARGB(225, 177, 219, 213),
                        filled: true,
                        labelText: 'Inserisci un\'email',
                        labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50)))),
                    controller: emailController,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Inserisci una email valida'
                            : null,
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      backgroundColor: const Color(utils.primaryColor),
                    ),
                    onPressed: setInvitation,
                    child: const Text(
                      'Invia invito',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
