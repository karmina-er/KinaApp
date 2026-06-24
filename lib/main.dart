import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA4y44gvuC-jco_NDGR37sOF2Yuw49JLSs",
      appId: "1:309290558218:android:0e257dd8bb8bcd30fe50f3",
      messagingSenderId: "309290558218",
      projectId: "kina-app1",
    ),
  );

  runApp(const SafeMindApp());
}

class SafeMindApp extends StatelessWidget {
  const SafeMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeMind App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}