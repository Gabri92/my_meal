import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_meal/Pages/profile.dart';
import '../utils.dart';
import 'Pages/homepage.dart';

import '../globals.dart' as globals;
import '../utils.dart' as utils;
import 'Authentication/Login.dart';
import 'Authentication/Signup.dart';

// MAIN
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
bool firstTimeHere = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // @override
  // Key? get key => navigatorKey;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: messengerKey,
        home: Scaffold(
          body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong!'));
              } else if (snapshot.hasData) {
                return const MainScreen();
              } else {
                return const AuthPage();
              }
            },
          ),
        ),
      );
}

// AUTH PAGE
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedSignup: toggle)
      : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final screens = [
    HomePage(userCredentials: getUserCredentials()),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          iconSize: 32,
          backgroundColor: const Color.fromARGB(255, 230, 230, 230),
          selectedItemColor: const Color(utils.primaryColor),
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: 'Settings',
            )
          ],
        ),
      ),
    );
  }
}

Future<void> getUserCredentials() async {
  try {
    DocumentSnapshot<Map<String, dynamic>> user;
    String? email = FirebaseAuth.instance.currentUser?.email;
    await FirebaseFirestore.instance
        .collection("Users")
        .where("email", isEqualTo: email)
        .get()
        .then((value) {
      user = value.docs.single;
      globals.userCredential = globals.UserCredentials.fromFirestore(user);
    });
  } catch (error) {
    throw Exception("Errore nel recuperare le credenziali utente: $error");
  }
}
