import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import 'lista_produtos_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  
  bool _isLogin = true; // Alterna entre Login e Cadastro
  bool _isCarregando = false;

  void _submeter() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isCarregando = true);

    try {
      if (_isLogin) {
        // Tenta fazer o login
        bool sucesso = await ApiService().login(_emailController.text, _senhaController.text);
        if (sucesso && mounted) {
          // Navega para a tela principal e remove a tela de login do histórico
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ListaProdutosScreen()),
          );
        }
      } else {
        // Tenta fazer o cadastro
        bool sucesso = await ApiService().registrar(_emailController.text, _senhaController.text, 'cliente');
        if (sucesso && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada! Faça o login agora.'), backgroundColor: Colors.green),
          );
          setState(() => _isLogin = true); // Volta para a tela de login
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCarregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shopping_cart, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Bem-vindo à Amazonia' : 'Crie sua Conta',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isCarregando ? null : _submeter,
                  child: _isCarregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLogin ? 'Entrar' : 'Cadastrar', style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // Inverte o modo
                  });
                },
                child: Text(
                  _isLogin ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Faça Login',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}