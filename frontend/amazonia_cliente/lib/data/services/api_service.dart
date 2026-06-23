import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/produto_model.dart';
import '../models/pedido_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';


  Future<bool> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // guarda o token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      
      return true;
    } else {
      throw Exception('Falha no login. Verifique as suas credenciais.');
    }
  }

  // Função de Cadastro
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

  // Função para Deslogar (Apagar o Token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Função auxiliar para pegar o token salvo
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

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
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/order'),
      headers: headers,
      body: jsonEncode({
        'cliente_id': clienteId,
        'produto_id': produtoId,
      }),
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
  
  Future<bool> cancelarPedido(int pedidoId) async {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('$baseUrl/order/$pedidoId'),
      headers: headers,
    );
    
    return response.statusCode == 200;
  }
}
