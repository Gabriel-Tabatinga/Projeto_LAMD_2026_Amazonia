import 'package:flutter/material.dart';
import 'presentation/screens/solicitacoes_pendentes_screen.dart';

void main() {
  runApp(const PrestadorApp());
}

class PrestadorApp extends StatelessWidget {
  const PrestadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amazonia.com - Entregador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const SolicitacoesPendentesScreen(),
    );
  }
}