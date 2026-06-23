import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto_model.dart';
import '../models/pedido_model.dart';

class ApiService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';

  // ==========================================
  // --- MÉTODOS DE AUTENTICAÇÃO E SEGURANÇA ---
  // ==========================================

  Future<bool> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']); // Guarda o token
      return true;
    } else {
      throw Exception('Falha no login. Verifique as suas credenciais.');
    }
  }

  Future<bool> registrar(String email, String senha, String tipo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha, 'tipo': tipo}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Erro ao cadastrar.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Função que injeta o Token em todas as requisições
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // --- ROTAS DO CLIENTE ---
  // ==========================================

  // Função para buscar a lista de produtos (GET /produtos)
  Future<List<Produto>> fetchProdutos() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/produtos'), headers: headers);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Produto.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar produtos do Node.js');
    }
  }

  // Função para o cliente criar um pedido (POST /order)
  Future<bool> criarPedido(int clienteId, int produtoId) async {
    final headers = await _getHeaders(); // Pega o cabeçalho com Token
    
    final response = await http.post(
      Uri.parse('$baseUrl/order'),
      headers: headers, // Injeta aqui
      body: jsonEncode({'cliente_id': clienteId, 'produto_id': produtoId}),
    );

    return response.statusCode == 201;
  }

  // Função para buscar os pedidos do cliente (GET /order/client/:clienteId)
  Future<List<Pedido>> fetchMeusPedidos(int clienteId) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/order/client/$clienteId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar pedidos.');
    }
  }

  // Função para o cliente cancelar o pedido (Adicionada para não perder a funcionalidade)
  Future<bool> cancelarPedido(int pedidoId) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/order/$pedidoId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // ==========================================
  // --- ROTAS DO ENTREGADOR (PRESTADOR) ---
  // ==========================================

  // Buscar pedidos pendentes para o Entregador (GET /request/supplier)
  Future<List<Pedido>> fetchPedidosPendentes() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/request/supplier'), headers: headers);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar solicitações pendentes.');
    }
  }

  // Aceitar um pedido (POST /request/supplier/:id/accept)
  Future<bool> aceitarPedido(int pedidoId, int prestadorId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/request/supplier/$pedidoId/accept'),
      headers: headers,
      body: jsonEncode({'prestador_id': prestadorId}),
    );
    
    return response.statusCode == 200;
  }
  
  // Buscar entregas em andamento do prestador (GET /request/supplier/:prestadorId/ongoing)
  Future<List<Pedido>> fetchEntregasEmAndamento(int prestadorId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/request/supplier/$prestadorId/ongoing'), headers: headers);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Pedido.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar entregas em andamento.');
    }
  }

  // Concluir a entrega (PUT /request/supplier/ongoing/:idPedido/status)
  Future<bool> concluirEntrega(int pedidoId) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/request/supplier/ongoing/$pedidoId/status'),
      headers: headers,
    );
    
    return response.statusCode == 200;
  }
}