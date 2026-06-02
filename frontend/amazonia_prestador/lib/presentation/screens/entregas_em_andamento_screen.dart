import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/api_service.dart';

class EntregasEmAndamentoScreen extends StatefulWidget {
  const EntregasEmAndamentoScreen({super.key});

  @override
  State<EntregasEmAndamentoScreen> createState() => _EntregasEmAndamentoScreenState();
}

class _EntregasEmAndamentoScreenState extends State<EntregasEmAndamentoScreen> {
  late Future<List<Pedido>> futureEmAndamento;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarEmAndamento();
    // Atualiza a cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _carregarEmAndamento();
    });
  }

  void _carregarEmAndamento() {
    setState(() {
      // Simula o entregador de ID 99 a ver as suas próprias entregas
      futureEmAndamento = ApiService().fetchEntregasEmAndamento(99);
    });
  }

  void _finalizar(int pedidoId) async {
    try {
      bool sucesso = await ApiService().concluirEntrega(pedidoId);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrega concluída com sucesso!'), backgroundColor: Colors.green),
        );
        _carregarEmAndamento(); // Atualiza a lista para remover o pedido concluído
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao concluir: $e'), backgroundColor: Colors.red),
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
        title: const Text('As Minhas Entregas'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<List<Pedido>>(
        future: futureEmAndamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Não tens nenhuma entrega em andamento.'));
          }

          List<Pedido> pedidos = snapshot.data!;
          
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              Pedido pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.directions_bike, color: Colors.blue, size: 30),
                  title: Text('Entrega #${pedido.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Levar Produto ${pedido.produtoId} ao Cliente ${pedido.clienteId}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () => _finalizar(pedido.id),
                    child: const Text('Concluir'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}