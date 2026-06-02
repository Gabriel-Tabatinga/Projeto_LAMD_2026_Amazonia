import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/produto_model.dart';
import '../models/pedido_model.dart';

class ApiService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';

  // Função para buscar a lista de produtos (GET /produtos)
  Future<List<Produto>> fetchProdutos() async {
    final response = await http.get(Uri.parse('$baseUrl/produtos'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Produto.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar produtos do Node.js');
    }
  }

  // Função para o cliente criar um pedido (POST /order)
  Future<bool> criarPedido(int clienteId, int produtoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cliente_id': clienteId, 'produto_id': produtoId}),
    );

    return response.statusCode == 201;
  }

  // Função para buscar os pedidos do cliente (GET /order/client/:clienteId)
  Future<List<Pedido>> fetchMeusPedidos(int clienteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/client/$clienteId'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar pedidos.');
    }
  }

  // Buscar pedidos pendentes para o Entregador (GET /request/supplier)
  Future<List<Pedido>> fetchPedidosPendentes() async {
    final response = await http.get(Uri.parse('$baseUrl/request/supplier'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar solicitações pendentes.');
    }
  }

  // Aceitar um pedido (POST /request/supplier/:id/accept)
  Future<bool> aceitarPedido(int pedidoId, int prestadorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/request/supplier/$pedidoId/accept'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prestador_id': prestadorId}),
    );
    
    return response.statusCode == 200;
  }
  
  // Buscar entregas em andamento do prestador (GET /request/supplier/:prestadorId/ongoing)
  Future<List<Pedido>> fetchEntregasEmAndamento(int prestadorId) async {
    final response = await http.get(Uri.parse('$baseUrl/request/supplier/$prestadorId/ongoing'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar entregas em andamento.');
    }
  }

  // Concluir a entrega (PUT /request/supplier/ongoing/:idPedido/status)
  Future<bool> concluirEntrega(int pedidoId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/request/supplier/ongoing/$pedidoId/status'),
    );
    
    return response.statusCode == 200;
  }
}
