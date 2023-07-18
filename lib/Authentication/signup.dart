import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../Utils.dart' as utils;
import '../main.dart';

// SIGNUP WIDGET
class SignUpWidget extends StatefulWidget {
  final VoidCallback onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    userNameController.dispose();

    super.dispose();
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Crea nuovo utente in Firebase
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (error) {
      print(error);

      utils.Utils.showSnackBar(error.message, Colors.red);
    }

    // Aggiunge nome ad utente firebase
    try {
      await FirebaseAuth.instance.currentUser!
          .updateDisplayName(userNameController.text.trim());

      final authUser = FirebaseAuth.instance.currentUser!;

      final user = <String, dynamic>{
        'uid': authUser.uid,
        'email': authUser.email,
        'username': authUser.displayName,
      };

      // Crea nuovo utente in Firestore
      DocumentReference? userDoc;
      await FirebaseFirestore.instance
          .collection("Users")
          .add(user)
          .then((DocumentReference doc) => userDoc = doc);

      final storage = <String, dynamic>{
        'Name': 'La dispensa di ${authUser.displayName}',
      };

      // Crea nuovo magazzino in Firestore
      DocumentReference? storageDoc;
      await FirebaseFirestore.instance
          .collection("Storages")
          .add(storage)
          .then((DocumentReference doc) => storageDoc = doc);

      // Assegna id magazzino all'utente
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userDoc?.id)
          .set(({'storageID': storageDoc?.id}), SetOptions(merge: true));
    } catch (error) {
      print(error.toString());

      utils.Utils.showSnackBar(error.toString(), Colors.red);
    }

    // Navigator.of(context) not working!
    //if (context.mounted) Navigator.of(context).pop(); //Vedere navigator key
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxHeight > 700) {
            return _buildNormalSignupPage();
          } else {
            return _buildSmallerSignupPage();
          }
        },
      );

  Widget _buildNormalSignupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text('Benvenuto/a!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text('Iniziamo a gestire la tua dispensa',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
            const SizedBox(height: 80),
            SizedBox(
              height: 50,
              width: 325,
              child: TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(225, 177, 219, 213),
                    filled: true,
                    labelText: 'La tua email',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Inserisci una email valida'
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 325,
              child: TextFormField(
                controller: userNameController,
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(225, 177, 219, 213),
                    filled: true,
                    labelText: 'Username',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 4
                    ? 'Inserisci almeno 4 caratteri'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 325,
              child: TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 325,
              child: TextFormField(
                  controller: passwordConfirmController,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Conferma la password',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value != null && value != passwordController.text.trim()
                          ? 'La password è diversa da quella inserita'
                          : null),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 60,
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  backgroundColor: const Color(utils.primaryColor),
                ),
                onPressed: signUp,
                child: const Text(
                  'Registrati',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 30),
            RichText(
                text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 20),
              text: 'Hai già un account? ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignIn,
                  text: 'Accedi',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallerSignupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text('Benvenuto/a!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Iniziamo a gestire la tua dispensa',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
            const SizedBox(height: 60),
            SizedBox(
              height: 45,
              width: 320,
              child: TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(225, 177, 219, 213),
                    filled: true,
                    labelText: 'La tua email',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Inserisci una email valida'
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              width: 320,
              child: TextFormField(
                controller: userNameController,
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(225, 177, 219, 213),
                    filled: true,
                    labelText: 'Username',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 4
                    ? 'Inserisci almeno 4 caratteri'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              width: 320,
              child: TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              width: 320,
              child: TextFormField(
                  controller: passwordConfirmController,
                  decoration: const InputDecoration(
                      fillColor: Color.fromARGB(225, 177, 219, 213),
                      filled: true,
                      labelText: 'Conferma la password',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value != null && value != passwordController.text.trim()
                          ? 'La password è diversa da quella inserita'
                          : null),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 50,
              width: 280,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  backgroundColor: const Color(utils.primaryColor),
                ),
                onPressed: signUp,
                child: const Text(
                  'Registrati',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
                text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 18),
              text: 'Hai già un account? ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignIn,
                  text: 'Accedi',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
