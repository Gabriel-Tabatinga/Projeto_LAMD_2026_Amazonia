import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/api_service.dart';

class MeusPedidosScreen extends StatefulWidget {
  const MeusPedidosScreen({super.key});

  @override
  State<MeusPedidosScreen> createState() => _MeusPedidosScreenState();
}

class _MeusPedidosScreenState extends State<MeusPedidosScreen> {
  late Future<List<Pedido>> futurePedidos;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();

    // ATUALIZAÇÃO ASSÍNCRONA (Polling): Atualiza a lista a cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _carregarPedidos();
    });
  }

  void _carregarPedidos() {
    setState(() {
      // Simula a busca pelos pedidos do Cliente de ID 1
      futurePedidos = ApiService().fetchMeusPedidos(1);
    });
  }

  @override
  void dispose() {
    // Muito importante cancelar o timer quando sair da tela para não vazar memória
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Pedido>>(
        future: futurePedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não tem pedidos.'));
          }

          List<Pedido> pedidos = snapshot.data!;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              Pedido pedido = pedidos[index];

              // Muda a cor do ícone dependendo do status
              Color statusColor = pedido.status == 'pendente'
                  ? Colors.orange
                  : Colors.green;
              IconData statusIcon = pedido.status == 'pendente'
                  ? Icons.access_time
                  : Icons.check_circle;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(statusIcon, color: statusColor, size: 30),
                  title: Text(
                    'Pedido #${pedido.id} (Produto ${pedido.produtoId})',
                  ),
                  subtitle: Text('Status: ${pedido.status.toUpperCase()}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
