import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../utils.dart';
import '../homepage.dart';

import '../globals.dart' as globals;
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
                return const HomePage();
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

// //App bar
class BottomAppNavBar extends StatelessWidget {
  const BottomAppNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60,
      shape: const CircularNotchedRectangle(),
      color: Colors.blue,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              tooltip: 'Home',
              icon: const Icon(Icons.home_filled),
              iconSize: 32,
              padding: const EdgeInsets.all(16),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'Profile',
              icon: const Icon(Icons.manage_accounts),
              iconSize: 32,
              padding: const EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }
}
