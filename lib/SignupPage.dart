import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  // Paleta de Colores (consistente con el resto del app)
  static const Color mexicanPink = Color(0xffCD2C58);
  static const Color softPink = Color(0xffE06B80);
  static const Color lightBackground = Color(0xffFEF2F2);
  static const Color darkAccent = Color.fromARGB(255, 74, 39, 56);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Lógica de Registro con Firebase
  Future<void> signUp() async {
    // 1. Validación de campos no vacíos
    if (_emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showErrorDialog('empty-fields');
      return;
    }

    // 2. Validación de Contraseñas
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showErrorDialog('passwords-do-not-match');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Crear Usuario en Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Registro exitoso, navegar a la página principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.code);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Manejo de errores visuales (Snack Bar)
  void _showErrorDialog(String code) {
    String message;

    switch (code) {
      case 'weak-password':
        message = 'La contraseña debe tener al menos 6 caracteres.';
        break;
      case 'email-already-in-use':
        message = 'Este correo ya está registrado.';
        break;
      case 'invalid-email':
        message = 'El formato del correo es inválido.';
        break;
      case 'passwords-do-not-match':
        message = 'Las contraseñas no coinciden.';
        break;
      case 'empty-fields':
        message = 'Por favor, completa todos los campos.';
        break;
      default:
        message = 'Ocurrió un error en el registro. Código: $code';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: mexicanPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Widget para construir los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: darkAccent),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: softPink),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: softPink.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: mexicanPink, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double maxFormWidth = 400.0;
    
    return Scaffold(
      body: Container(
        // INICIO DE LA MODIFICACIÓN: Usamos BoxDecoration para cargar la imagen
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondoLogin1.jpg'), // Asegúrate de que esta ruta sea correcta
            fit: BoxFit.cover, // Para cubrir toda la pantalla
          ),
        ),
        // FIN DE LA MODIFICACIÓN
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxFormWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    // Puedes hacer el fondo del formulario semi-transparente o sólido
                    color: lightBackground.withOpacity(0.95), 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Sombra más visible sobre fondo de imagen
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      const Icon(
                        Icons.add_business_outlined,
                        size: 80,
                        color: mexicanPink,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '¡Únete al Directorio!',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          color: darkAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Crea tu cuenta de artesano en tres pasos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: darkAccent,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email TextField
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      // Password TextField
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password TextField
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmar Contraseña',
                        icon: Icons.lock_reset_outlined,
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),

                      // Botón de Registro
                      ElevatedButton(
                        onPressed: _isLoading ? null : signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mexicanPink,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'REGISTRARME',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),

                      // Volver al Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes una cuenta? ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: darkAccent,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Vuelve a la página anterior (Login o WelcomeScreen)
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: mexicanPink,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}