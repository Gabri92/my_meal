import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Authentication/reset_psw.dart';
import '../../globals.dart' as globals;
import '../../utils.dart' as utils;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user = globals.userCredential?.toFirestore();

  Future _deleteAccount() async {
    await FirebaseAuth.instance.currentUser?.delete();
  }

  Future _launchPrivacyUrl() async {
    const url = 'https://www.iubenda.com/privacy-policy/88819315';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              user?["username"],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            ),
            Text(
              user?["email"],
              style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  color: Colors.black),
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
                  'Reset password',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Visibility(
              visible: false,
              child: SizedBox(
                height: 60,
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    backgroundColor: const Color(utils.primaryColor),
                  ),
                  child: const Text(
                    'Notifiche',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {},
                ),
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
                  'Privacy Policy',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () => _launchPrivacyUrl,
              ),
            ),
            const SizedBox(height: 30),
            Visibility(
              visible: false,
              child: SizedBox(
                height: 60,
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    backgroundColor: const Color(utils.primaryColor),
                  ),
                  child: const Text(
                    'App Tutorial',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {},
                ),
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
                  'Logout',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              height: 60,
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Elimina account',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    scrollable: false,
                    content: const Text(
                        'Sei sicuro di voler cancellare il tuo account?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Torna al profilo'),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          _deleteAccount();
                          Navigator.pop(context, 'Elimina account');
                        },
                        child: const Text(
                          'Elimina account',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
