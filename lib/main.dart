import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_meal/Pages/profile.dart';
import '../utils.dart';
import 'Pages/homepage.dart';

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

final screens = [
  HomePage(userCredentials: getUserCredentials()),
  const ProfilePage(),
];

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
                return HomePage(userCredentials: getUserCredentials());
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
// class BottomAppNavBar extends StatelessWidget {
//   const BottomAppNavBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       height: 60,
//       shape: const CircularNotchedRectangle(),
//       color: Colors.blue,
//       child: IconTheme(
//         data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             IconButton(
//               onPressed: () {},
//               tooltip: 'Home',
//               icon: const Icon(Icons.home_filled),
//               iconSize: 32,
//               padding: const EdgeInsets.all(16),
//             ),
//             IconButton(
//               onPressed: () {},
//               tooltip: 'Profile',
//               icon: const Icon(Icons.manage_accounts),
//               iconSize: 32,
//               padding: const EdgeInsets.all(16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class BottomAppNavBar extends StatefulWidget {
  const BottomAppNavBar({super.key});

  @override
  State<BottomAppNavBar> createState() => _BottomAppNavBarState();
}

class _BottomAppNavBarState extends State<BottomAppNavBar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => setState(() => currentIndex = index),
      type: BottomNavigationBarType.fixed,
      iconSize: 32,
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Profile',
        )
      ],
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
