// ignore_for_file: type=lint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_directorio/PagHome.dart';
import 'AppColors.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _nombreArtesanoController = TextEditingController(); 
  final TextEditingController _tecnicaController = TextEditingController(); 
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreArtesanoController.dispose();
    _tecnicaController.dispose();
    _regionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //toda la logica del Registro 
  Future<void> signUpRegistro() async {
    final String nombreArtesano = _nombreArtesanoController.text.trim();
    final String tecnica = _tecnicaController.text.trim(); 
    final String region = _regionController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (nombreArtesano.isEmpty || tecnica.isEmpty || region.isEmpty || email.isEmpty || password.isEmpty || _confirmPasswordController.text.trim().isEmpty) {
      _showErrorDialog('empty-fields');
      return;
    }

    if (password != _confirmPasswordController.text.trim()) {
      _showErrorDialog('passwords-do-not-match');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      //crear el usuario --> al fin 
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //guardar datos --> algo
      await FirebaseFirestore.instance
        .collection('artesanos')
        .doc(userCredential.user!.uid)
        .set({
          
          'nombreArtesano': nombreArtesano,
          'email': email,
          'tecnicas': [tecnica], 
          'regionOrigen': region,
          
          'prendas': ['Sin definir'], 
          'descripcion': '¡Artesano recién registrado! Completa tu perfil para más detalles.',
          'telefono': 'Sin contacto',
          'redesSociales': {},
          
          'uid': userCredential.user!.uid,
          'fechaRegistro': FieldValue.serverTimestamp(),
          'publicado': true, //se mustra automaticamente en el Directorio 
        });

      //si no hay errores
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PagHome(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.code);
    }catch(e){
      _showErrorDialog('Error inesperado: $e'); 
      print('Error de Registro (Firestore/Conexión): $e');
      
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
        backgroundColor: AppColors.mexicanPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
      style: const TextStyle(color: AppColors.darkAccent), 
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.softPink), 
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.softPink.withAlpha(112), width: 1),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    
                    color: AppColors.lightBackground.withAlpha(225),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38, 
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Icon(
                        Icons.add_business_outlined,
                        size: 80,
                        color: AppColors.mexicanPink, 
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '¡Únete al Directorio!',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          color: AppColors.darkAccent, 
                        ),
                      ),

                      const SizedBox(height: 5),
                      const Text(
                        'Crea tu perfil de Artesano',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkAccent, 
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Nombre de Artesano
                      _buildTextField(
                        controller: _nombreArtesanoController,
                        hintText: 'Nombre de Artesano o Taller',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      
                      // Tecnica Principal
                      _buildTextField(
                        controller: _tecnicaController,
                        hintText: 'Técnica Principal (ej. Telar de cintura)',
                        icon: Icons.palette_outlined,
                      ),
                      const SizedBox(height: 15),
                      
                      // Region 
                      _buildTextField(
                        controller: _regionController,
                        hintText: 'Región (ej. Teotitlán)',
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 15),

                      // Email 
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      // Password 
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),

                      // Confirmar Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmar Contraseña',
                        icon: Icons.lock_reset_outlined,
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),

                      // Boton de Registro
                      ElevatedButton(
                        onPressed: _isLoading ? null : signUpRegistro,
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
                              color: AppColors.darkAccent,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mexicanPink,
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