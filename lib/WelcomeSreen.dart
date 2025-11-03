import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_directorio/SignupPage.dart';
import 'package:web_directorio/HomePage.dart';
import 'package:web_directorio/ForgotPasswordPage.dart'; // Importamos la página para la navegación

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Paleta de Colores
  static const Color mexicanPink = Color(0xffCD2C58);
  static const Color softPink = Color(0xffE06B80);
  static const Color lightBackground = Color(0xffFEF2F2);
  static const Color darkAccent = Color.fromARGB(255, 74, 39, 56);
  static const Color visitantButtonColor = Color(0xff946aff); 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Lógica de Autenticación (SignIn) ---

  Future<void> singIn() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showErrorDialog('empty-fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Successful navigation to HomePage
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

  // Visual error handler (Snack Bar)
  void _showErrorDialog(String code) {
    String message;

    switch (code) {
      case 'user-not-found':
      case 'invalid-credential': // Modern Firebase uses this for general auth errors
        message = 'Usuario o contraseña incorrectos. Verifica tus datos.';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta.';
        break;
      case 'invalid-email':
        message = 'Verifica tu dirección de correo.';
        break;
      case 'empty-fields':
        message = 'Por favor, introduce tu email y contraseña.';
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
  
  // --- Widgets de Diseño ---

  // Text field component
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

  // Left Column (Visitant)
  Widget _buildVisitantColumn(BuildContext context, double width) {
    return Container(
      padding: const EdgeInsets.all(40),
      // Only round the corner if it's a large screen
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: width > 800 ? const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ) : BorderRadius.circular(20), 
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bienvenido',
              style: GoogleFonts.bebasNeue(
                fontSize: 48,
                color: darkAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Si no quieres crear una cuenta, puedes continuar y explorar como visitante.',
              style: TextStyle(fontSize: 18, color: darkAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Redirects the user to the HomePage (the Directory)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: visitantButtonColor,
                minimumSize: const Size(220, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Ir al Directorio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Right Column (Artisan Login)
  Widget _buildLoginColumn(BuildContext context, double width) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: width > 800 ? const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ) : BorderRadius.circular(20),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Hola de Nuevo!',
                style: GoogleFonts.bebasNeue(
                  fontSize: 38,
                  color: mexicanPink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Email/Usuario
              _buildTextField(
                controller: _emailController,
                hintText: 'Correo electrónico o Usuario',
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Contraseña
              _buildTextField(
                controller: _passwordController,
                hintText: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste la Contraseña?',
                    style: TextStyle(
                      color: softPink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : singIn,
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
                        'Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Aún no tienes una cuenta?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: darkAccent,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      ' Regístrate Aquí',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to handle responsiveness
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final cardWidth = isLargeScreen ? constraints.maxWidth * 0.75 : constraints.maxWidth * 0.9;
          
          return Container(
            // ** CAMBIO CLAVE: Reemplazamos el LinearGradient por una DecorationImage **
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Asegúrate de que esta ruta sea correcta según el nombre de tu archivo en assets/
                image: AssetImage('assets/fondoLogin1.jpg'), 
                fit: BoxFit.cover, // Para que la imagen cubra todo el fondo
              ),
            ),
            // El resto de la estructura (Center, Container, Row/Column) permanece igual
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                  maxHeight: isLargeScreen ? 600 : double.infinity, // Fixed height on desktop
                ),
                decoration: BoxDecoration(
                  // Añadimos un color de fondo semitransparente o un color sólido
                  // para que la tarjeta del formulario resalte sobre la imagen.
                  color: lightBackground.withOpacity(0.95), // Fondo de la tarjeta semi-transparente
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: darkAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isLargeScreen
                    ? Row( // Split Screen for desktop/tablet
                        children: [
                          Expanded(child: _buildVisitantColumn(context, constraints.maxWidth)),
                          Expanded(child: _buildLoginColumn(context, constraints.maxWidth)),
                        ],
                      )
                    : Column( // Stacked layout for mobile
                        children: [
                          _buildVisitantColumn(context, constraints.maxWidth),
                          const SizedBox(height: 10), 
                          _buildLoginColumn(context, constraints.maxWidth),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}