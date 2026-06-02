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

  // Nova função para cancelar o pedido
  void _cancelarPedido(int pedidoId) async {
    // Mostra um diálogo de confirmação antes de cancelar
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text('Tens a certeza que queres cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      bool sucesso = await ApiService().cancelarPedido(pedidoId);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado com sucesso.'), backgroundColor: Colors.redAccent),
        );
        _carregarPedidos(); // Atualiza a lista imediatamente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
        title: const Text('Meus Pedidos'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Pedido>>(
        future: futurePedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Ainda não tens pedidos.'));
          }

          List<Pedido> pedidos = snapshot.data!;
          pedidos = pedidos.reversed.toList();
          
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              Pedido pedido = pedidos[index];
              
              Color statusColor;
              IconData statusIcon;
              
              switch (pedido.status) {
                case 'pendente':
                  statusColor = Colors.orange;
                  statusIcon = Icons.access_time;
                  break;
                case 'aceito':
                  statusColor = Colors.blue;
                  statusIcon = Icons.moped;
                  break;
                case 'concluido':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'cancelado':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.grey;
                  statusIcon = Icons.help;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(statusIcon, color: statusColor, size: 30),
                  title: Text('Pedido #${pedido.id} (Produto ${pedido.produtoId})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${pedido.status.toUpperCase()}'),
                  // botão de cancelar
                  trailing: pedido.status == 'pendente' 
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Cancelar Pedido',
                        onPressed: () => _cancelarPedido(pedido.id),
                      )
                    : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}