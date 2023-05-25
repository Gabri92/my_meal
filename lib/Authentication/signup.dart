import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../globals.dart' as globals;
import '../Utils.dart';
import '../main.dart';
import '../globals.dart';

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

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (error) {
      print(error);

      Utils.showSnackBar(error.message);
    }

    try {
      await FirebaseAuth.instance.currentUser!
          .updateDisplayName(userNameController.text.trim());

      final authUser = FirebaseAuth.instance.currentUser!;

      final user = <String, dynamic>{
        'uid': authUser.uid,
        'email': authUser.email,
        'username': authUser.displayName,
      };

      await FirebaseFirestore.instance
          .collection("Users")
          .add(user)
          .then((DocumentReference doc) => globals.userDoc = doc);

      final storage = <String, dynamic>{
        'Name': 'La dispensa di ${authUser.displayName}',
      };

      await FirebaseFirestore.instance
          .collection("Storages")
          .add(storage)
          .then((DocumentReference doc) => globals.storageDoc = doc);

      await FirebaseFirestore.instance.collection("Users").doc(userDoc?.id).set(
          ({'storageID': globals.storageDoc?.id}), SetOptions(merge: true));
    } on Exception catch (error) {
      print(error.toString());

      Utils.showSnackBar(error.toString());
    }

    // Navigator.of(context) not working!
    //if (context.mounted) Navigator.of(context).pop(); //Vedere navigator key
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const FlutterLogo(size: 120),
              const SizedBox(height: 20),
              const Text('Hey There, \n Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300)),
              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: userNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Username'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 4
                    ? 'Enter min. 4 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null),
              const SizedBox(height: 20),
              TextFormField(
                  controller: passwordConfirmController,
                  textInputAction: TextInputAction.done,
                  decoration:
                      const InputDecoration(labelText: 'Confirm password'),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value != null && value != passwordController.text.trim()
                          ? 'The password is different from the one inserted'
                          : null),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 32),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                label: const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: signUp,
              ),
              const SizedBox(height: 30),
              RichText(
                  text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 20),
                text: 'Already have an account? ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Log In',
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
