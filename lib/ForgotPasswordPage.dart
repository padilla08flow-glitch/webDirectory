import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // Paleta de Colores (consistente con el resto del app)
  static const Color mexicanPink = Color(0xffCD2C58);
  static const Color softPink = Color(0xffE06B80);
  static const Color lightBackground = Color(0xffFEF2F2);
  static const Color darkAccent = Color.fromARGB(255, 74, 39, 56);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- Lógica de Restablecimiento de Contraseña ---

  Future<void> passwordReset() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('empty-field');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Successful notification
      _showSuccessDialog();

      // Clear the text field
      _emailController.clear();
      
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

  // Visual error handler (Snack Bar)
  void _showErrorDialog(String code) {
    String message;

    switch (code) {
      case 'user-not-found':
        message = 'No existe una cuenta registrada con este correo.';
        break;
      case 'invalid-email':
        message = 'El formato del correo es inválido.';
        break;
      case 'empty-field':
        message = 'Por favor, introduce tu dirección de correo.';
        break;
      default:
        message = 'Ocurrió un error inesperado. Código: $code';
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

  // Visual success handler
  void _showSuccessDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Widget para construir el campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
      // Eliminamos el AppBar ya que la mayoría de apps de autenticación lo ocultan
      // Opcional: si deseas mantenerlo, asegúrate de que el fondo sea transparente o del color de la imagen.
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        backgroundColor: Colors.transparent, // Lo hacemos transparente
        elevation: 0, // Quitamos la sombra
      ),
      extendBodyBehindAppBar: true, // Para que el body se extienda detrás del AppBar
      body: Container(
        // INICIO DE LA MODIFICACIÓN: Imagen de fondo
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondoLogin1.jpg'), // La imagen solicitada
            fit: BoxFit.cover, 
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: BoxDecoration(
                    // Hacemos el formulario semi-transparente para ver el fondo, pero claro para leer
                    color: lightBackground.withOpacity(0.95), 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Sombra más oscura para contraste
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título e Ícono
                      const Icon(
                        Icons.lock_reset_outlined,
                        size: 80,
                        color: mexicanPink,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '¿Olvidaste tu Contraseña?',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          color: darkAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un enlace para restablecerla.',
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
                      const SizedBox(height: 30),

                      // Botón de Envío
                      ElevatedButton(
                        onPressed: _isLoading ? null : passwordReset,
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
                                'ENVIAR ENLACE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Volver al Login
                      TextButton(
                        onPressed: () {
                          // Vuelve a la página de login/WelcomeScreen
                          Navigator.pop(context); 
                        },
                        child: const Text(
                          'Volver al Inicio de Sesión',
                          style: TextStyle(
                            color: softPink,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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