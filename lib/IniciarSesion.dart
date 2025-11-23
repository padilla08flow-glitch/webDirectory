// ignore_for_file: type=lint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CampoTextoLogin.dart';
import 'AppColors.dart';
import 'Registro.dart';
import 'PagHome.dart';
import 'RestablecerPassword.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> singIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      _showErrorDialog(
        'campo vacío'
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PagHome() 
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if(mounted) _showErrorDialog(e.code);
    } finally {
      if (mounted){
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _showErrorDialog(String errorCode) {
    String mensaje = 'Error desconocido al inciar sesión.';
    switch (errorCode) {
      case 'user-not-found':
        mensaje = 'Usuario o contraseña incorrectos. Verifica tus datos.';
        break;
      case 'wrong-password':
        mensaje = 'Contraseña incorrecta.';
        break;
      case 'invalid-email':
        mensaje = 'Verifica tu dirección de correo.';
        break;
      case 'empty-fields':
        mensaje = 'Por favor, introduce tu email y contraseña.';
        break;
      default:
        mensaje = 'Ocurrió un error inesperado. Código: $errorCode';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.mexicanPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Widget _columnaVisitante(BuildContext context, double width) {
    final isLargeScreen = width > 800;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: isLargeScreen ? const BorderRadius.only(
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
                color: AppColors.darkAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Si no quieres crear una cuenta, puedes continuar y explorar como visitante.',
              style: TextStyle(fontSize: 18, color: AppColors.darkAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const PagHome(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueBonito,
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

  Widget _columnaInicioSesion(BuildContext context, double width) {
    final isLargeScreen = width > 800;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: isLargeScreen ? const BorderRadius.only(
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
                  color: AppColors.mexicanPink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Email
              CampoTextoLogin(
                controller: _emailController,
                hintText: 'Correo electrónico',
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Contraseña
              CampoTextoLogin(
                controller: _passwordController,
                hintText: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // Contraña olvidada
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RestablecerPassword()
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste la Contraseña?',
                    style: TextStyle(
                      color: AppColors.softPink,
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
                onPressed: _cargando ? null : singIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mexicanPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: _cargando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,fontSize: 18,)),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Aún no tienes una cuenta?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkAccent,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Registro(),
                        ),
                      );
                    },
                    child: const Text(
                      ' Regístrate Aquí',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final cardWidth = isLargeScreen ? constraints.maxWidth * 0.75 : constraints.maxWidth * 0.9;
          
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondoLogin1.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                  maxHeight: isLargeScreen ? 600 : double.infinity,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground.withAlpha(242),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkAccent.withAlpha(77),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isLargeScreen
                    ? Row(
                        children: [
                          Expanded(child: _columnaVisitante(context, constraints.maxWidth)),
                          Expanded(child: _columnaInicioSesion(context, constraints.maxWidth)),
                        ],
                      )
                    :SingleChildScrollView(
                      child : Column(
                        children: [
                          _columnaVisitante(context, constraints.maxWidth),
                          const SizedBox(height: 10), 
                          _columnaInicioSesion(context, constraints.maxWidth),
                        ],
                      ),
                    )
              ),
            ),
          );
        },
      ),
    );
  }
}
