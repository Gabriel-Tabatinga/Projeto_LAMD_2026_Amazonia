import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/api_service.dart';

class DetalhesSolicitacaoScreen extends StatefulWidget {
  final Pedido pedido;

  const DetalhesSolicitacaoScreen({super.key, required this.pedido});

  @override
  State<DetalhesSolicitacaoScreen> createState() => _DetalhesSolicitacaoScreenState();
}

class _DetalhesSolicitacaoScreenState extends State<DetalhesSolicitacaoScreen> {
  bool _isCarregando = false;

  void _aceitarPedido() async {
    setState(() => _isCarregando = true);
    try {
      // Simula o entregador de ID 99 aceitando o pedido
      bool sucesso = await ApiService().aceitarPedido(widget.pedido.id, 99);
      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido Aceito!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volta para a tela de pendentes
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isCarregando = false);
    }
  }

  void _recusarPedido() {
    // Apenas volta para a tela anterior sem fazer nada no backend
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitação #${widget.pedido.id}'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.local_shipping, size: 100, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Text(
              'Entrega Solicitada pelo Cliente ID: ${widget.pedido.clienteId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Produto a ser entregue: ${widget.pedido.produtoId}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (_isCarregando)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: _recusarPedido,
                    icon: const Icon(Icons.close),
                    label: const Text('Recusar'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: _aceitarPedido,
                    icon: const Icon(Icons.check),
                    label: const Text('Aceitar Demanda'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}