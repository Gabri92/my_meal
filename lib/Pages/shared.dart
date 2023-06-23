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
        title: const Text('Condi vidi la tua dispensa'),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const FlutterLogo(size: 120),
              const SizedBox(height: 60),
              const Text('Condividi la tua dispensa!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                    'Aggiungi l\'email della persona che vuoi aggiungere per invitarlo ad unirsi alla tua dispensa',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
              ),
              const SizedBox(height: 20), //80
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.done,
                decoration:
                    const InputDecoration(labelText: 'Inserisci un\'email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Inserisci una email valida'
                        : null,
              ),
              ElevatedButton(
                onPressed: setInvitation,
                child: const Text('Invia invito'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
