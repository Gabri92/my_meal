import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../utils.dart';

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

//HOMEPAGE
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!; //Recupera credenziali user

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Signed In as',
              ),
              const SizedBox(height: 4),
              Text(
                user.email!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text('Welcome back'),
              //const SizedBox(height: 4),
              const Text(
                //TODO: Risolvere
                //user.displayName!,
                'da risolvere',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                icon: const Icon(Icons.arrow_back, size: 32),
                label: const Text(
                  'Sign out',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
