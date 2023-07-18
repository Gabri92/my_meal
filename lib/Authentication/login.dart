import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../Authentication/reset_psw.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils.dart' as utils;
import '../globals.dart' as globals;
import '../main.dart';

// LOGIN WIDGET
class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignup;

  const LoginWidget({
    Key? key,
    required this.onClickedSignup,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseFirestore.instance
        .collection("Users")
        .where("email", isEqualTo: emailController.text)
        .get()
        .then((value) => globals.userCredential =
            globals.UserCredentials.fromFirestore(value.docs.first))
        .onError((error, stackTrace) => utils.Utils.showSnackBar(
            "Errore nel caricamento del profilo utente", Colors.red));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      utils.Utils.showSnackBar(e.message, Colors.red);
    }

    // Navigator.of(context) not working!
    //Vedere navigator key
    //if (context.mounted) Navigator.of(context).pop();
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxHeight > 700) {
            return _buildNormalLoginPage();
          } else {
            return _buildSmallerLoginPage();
          }
        },
      );

  Widget _buildNormalLoginPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          const Text('Che bello rivederti!',
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
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            width: 325,
            child: TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(225, 177, 219, 213),
                    filled: true,
                    labelText: 'La tua password',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Inserisci almeno 6 caratteri'
                    : null),
          ),
          const SizedBox(height: 80),
          SizedBox(
            height: 60,
            width: 300,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                backgroundColor: const Color(utils.primaryColor),
              ),
              onPressed: signIn,
              child: const Text(
                'Accedi',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 50),
          GestureDetector(
            child: Text(
              'Hai dimenticato la password?',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordPage(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 20),
              text: 'Non sei registrato? ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignup,
                  text: 'Clicca qui',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallerLoginPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Text('Che bello rivederti!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          const Text('Iniziamo a gestire la tua dispensa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
          const SizedBox(height: 80),
          SizedBox(
            height: 50,
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
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            width: 320,
            child: TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(225, 177, 219, 213),
                    filled: true,
                    labelText: 'La tua password',
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)))),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Inserisci almeno 6 caratteri'
                    : null),
          ),
          const SizedBox(height: 80),
          SizedBox(
            height: 50,
            width: 280,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                backgroundColor: const Color(utils.primaryColor),
              ),
              onPressed: signIn,
              child: const Text(
                'Accedi',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            child: Text(
              'Hai dimenticato la password?',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordPage(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 18),
              text: 'Non sei registrato? ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignup,
                  text: 'Clicca qui',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
