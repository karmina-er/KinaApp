import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No se encontró un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Ese correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo no es válido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)], // Degradado vibrante
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView( // Evita errores al abrir el teclado
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícono principal flotante
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Títulos
                  Text(
                    _isLogin ? "Bienvenido a KINA" : "Comienza tu viaje",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? "Inicia sesión para continuar" : "Regístrate para crear tu espacio seguro",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // Tarjeta Blanca central
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Campo de Correo con Ícono
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo Institucional o Personal',
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF764BA2)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo de Contraseña con Ícono
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF764BA2)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Botón Principal
                          _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFF764BA2))
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF764BA2),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 3,
                            ),
                            onPressed: _submitForm,
                            child: Text(
                              _isLogin ? "Iniciar Sesión" : "Registrarme",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Botón de Cambio de Modo
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia Sesión",
                              style: const TextStyle(color: Color(0xFF764BA2), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Mensaje de Privacidad al fondo
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_person, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Tus respuestas emocionales son 100% privadas.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}