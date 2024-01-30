import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_app/auth/sign_up.dart';
import 'package:note_app/shared_preferences/shared_preferences.dart';
import 'auth/login.dart';

import 'screens/category/add.dart';
import 'screens/category/update_Page.dart';
import 'screens/home_page.dart';

var kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 5, 99, 125));

var kColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  Future<void> loadAppMode() async {
    // Retrieve the app mode
    bool savedMode = await AppPreferences.getAppMode();
    setState(() {
      isDarkMode = savedMode;
      print(isDarkMode);
    });
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    await AppPreferences.saveAppMode(isDarkMode);
  }

  @override
  void initState() {
    loadAppMode();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NOTY",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: kColorScheme,
        cardTheme: const CardTheme().copyWith(
          color: kColorScheme.secondaryContainer,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        textTheme: ThemeData().textTheme.copyWith(
              bodyText2: TextStyle(
                color: kColorScheme.onSecondaryContainer,

                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: kDarkColorScheme,
        cardTheme: const CardTheme().copyWith(
          color: kDarkColorScheme.secondaryContainer,
        ),
        textTheme: ThemeData().textTheme.copyWith(
              bodyText2: TextStyle(
                color: kDarkColorScheme.onSecondaryContainer,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: (FirebaseAuth.instance.currentUser != null &&
              FirebaseAuth.instance.currentUser!.emailVerified)
          ? HomePage(
              isDarkMode: isDarkMode,
              toggleTheme: toggleTheme,
            )
          : const LoginPage(),
      routes: {
        "signup": (context) => const SignUpPage(),
        "login": (context) => const LoginPage(),
        "home-page": (context) => HomePage(
              isDarkMode: isDarkMode,
              toggleTheme: toggleTheme,
            ),
        "add-category": (context) => const AddCategory(),

      },
    );
  }
}
