import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/api_service.dart';
import 'detalhes_solicitacao_screen.dart';
import 'entregas_em_andamento_screen.dart';
import 'login_screen.dart';

class SolicitacoesPendentesScreen extends StatefulWidget {
  const SolicitacoesPendentesScreen({super.key});

  @override
  State<SolicitacoesPendentesScreen> createState() => _SolicitacoesPendentesScreenState();
}

class _SolicitacoesPendentesScreenState extends State<SolicitacoesPendentesScreen> {
  late Future<List<Pedido>> futurePendentes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarPendentes();
    // Polling a cada 5 segundos para simular a notificação assíncrona
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _carregarPendentes();
    });
  }

  void _carregarPendentes() {
    setState(() {
      futurePendentes = ApiService().fetchPedidosPendentes();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Entregador'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.moped),
            tooltip: 'Entregas em Andamento',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EntregasEmAndamentoScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await ApiService().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Pedido>>(
        future: futurePendentes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma nova entrega disponível no momento.'));
          }

          List<Pedido> pedidos = snapshot.data!;
          
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              Pedido pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.motorcycle, color: Colors.orangeAccent, size: 30),
                  title: Text('Nova Solicitação #${pedido.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Produto ID: ${pedido.produtoId}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesSolicitacaoScreen(pedido: pedido),
                      ),
                    ).then((_) => _carregarPendentes()); // Atualiza a lista ao voltar
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}