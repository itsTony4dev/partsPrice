import 'package:flutter/material.dart';
import 'package:pcparts/pages/login.dart';
import 'package:pcparts/pages/homepage.dart';
import 'package:pcparts/pages/selected.dart';
import 'package:pcparts/pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PC Parts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define initial route
      initialRoute: '/login',
      // Define your routes
      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUp(),
        '/selected-products': (context) => const SelectedProductsPage(),
      },
    );
  }
}