import 'package:flutter/material.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/api_service.dart';
import 'detalhes_produto_screen.dart';
import 'meus_pedidos_screen.dart';
import 'login_screen.dart';

class ListaProdutosScreen extends StatefulWidget {
  const ListaProdutosScreen({super.key});

  @override
  State<ListaProdutosScreen> createState() => _ListaProdutosScreenState();
}

class _ListaProdutosScreenState extends State<ListaProdutosScreen> {
  late Future<List<Produto>> futureProdutos;

  @override
  void initState() {
    super.initState();
    futureProdutos = ApiService().fetchProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amazonia.com - Produtos'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Meus Pedidos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeusPedidosScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // Apaga o token do cofre
              await ApiService().logout();
              
              if (!context.mounted) return;
              // Redireciona para o Login e destrói as telas anteriores
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Produto>>(
        future: futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum produto disponível no momento.'),
            );
          }

          List<Produto> produtos = snapshot.data!;

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              Produto produto = produtos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.inventory_2,
                    color: Colors.blueAccent,
                  ),
                  title: Text(
                    produto.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetalhesProdutoScreen(produto: produto),
                      ),
                    );
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
