import 'package:flutter/material.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/api_service.dart';

class DetalhesProdutoScreen extends StatefulWidget {
  final Produto produto;

  const DetalhesProdutoScreen({super.key, required this.produto});

  @override
  State<DetalhesProdutoScreen> createState() => _DetalhesProdutoScreenState();
}

class _DetalhesProdutoScreenState extends State<DetalhesProdutoScreen> {
  bool _isCarregando = false;

  void _solicitarEntrega() async {
    setState(() {
      _isCarregando = true;
    });

    try {
      // Simula o cliente de ID 1 realizando o pedido deste produto específico
      bool sucesso = await ApiService().criarPedido(1, widget.produto.id);

      if (!mounted) return; // Segurança do Flutter para evitar crash

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pedido criado com sucesso! O entregador será notificado.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para a tela anterior
        Navigator.pop(context);
      } else {
        throw Exception("Erro retornado pelo servidor");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao criar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCarregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.inventory_2, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              widget.produto.nome,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Valor: R\$ ${widget.produto.preco.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isCarregando ? null : _solicitarEntrega,
                child: _isCarregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Solicitar Entrega',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
