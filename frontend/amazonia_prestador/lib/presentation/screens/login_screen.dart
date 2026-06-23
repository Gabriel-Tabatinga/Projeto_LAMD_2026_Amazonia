import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import 'solicitacoes_pendentes_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  
  bool _isLogin = true;
  bool _isCarregando = false;

  void _submeter() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos.')));
      return;
    }

    setState(() => _isCarregando = true);

    try {
      if (_isLogin) {
        bool sucesso = await ApiService().login(_emailController.text, _senhaController.text);
        if (sucesso && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SolicitacoesPendentesScreen()),
          );
        }
      } else {
        bool sucesso = await ApiService().registrar(_emailController.text, _senhaController.text, 'entregador');
        if (sucesso && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta de Entregador criada! Faça login.'), backgroundColor: Colors.green),
          );
          setState(() => _isLogin = true);
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
              const Icon(Icons.two_wheeler, size: 100, color: Colors.orangeAccent),
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Portal do Entregador' : 'Cadastro de Entregador',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white),
                  onPressed: _isCarregando ? null : _submeter,
                  child: _isCarregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLogin ? 'Entrar' : 'Cadastrar', style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Quero ser um entregador' : 'Já sou entregador',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}