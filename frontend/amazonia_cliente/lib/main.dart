import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const AmazoniaApp());
}

class AmazoniaApp extends StatelessWidget {
  const AmazoniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amazonia.com',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Define a tela inicial do app
      home: const LoginScreen(),
    );
  }
}