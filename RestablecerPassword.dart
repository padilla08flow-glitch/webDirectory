// ignore_for_file: type=lint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AppColors.dart';

class RestablecerPassword extends StatefulWidget {
  const RestablecerPassword({super.key});

  @override
  State<RestablecerPassword> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<RestablecerPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('empty-field');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      _mostrarCuadroDialogo();

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
  void _showErrorDialog(String code) {
    String message;

    switch (code) {
      case 'user-not-found':
        message = 'No existe una cuenta registrada con este correo.';
        break;
      case 'invalid-email':
        message = 'El formato del correo es inválido.';
        break;
      case 'empty-fields':
        message = 'Por favor, introduce tu dirección de correo.';
        break;
      default:
        message = 'Ocurrió un error inesperado. Código: $code';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.mexicanPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarCuadroDialogo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.darkAccent),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.softPink),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.softPink.withAlpha(127), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mexicanPink, width: 2),
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
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondoLogin1.jpg'), 
            fit: BoxFit.cover, 
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxFormWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground.withAlpha(242), 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(77),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_reset_outlined,
                        size: 80,
                        color: AppColors.mexicanPink,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        '¿Olvidaste tu Contraseña?',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          color: AppColors.darkAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un enlace para restablecerla.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkAccent,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _isLoading ? null : passwordReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mexicanPink,
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
                      
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); 
                        },
                        child: const Text(
                          'Volver al Inicio de Sesión',
                          style: TextStyle(
                            color: AppColors.softPink,
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
