import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //colores 
  static const Color mexicanPink = Color(0xffCD2C58);
  static const Color softPink = Color(0xffE06B80);
  static const Color lightBackground = Color(0xffFEF2F2);
  static const Color darkAccent = Color.fromARGB(255, 74, 39, 56);
  static const Color visitantButtonColor = Color(0xff946aff); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moda Oaxaqueña'),
        //Directorio Artesanal de Oaxaca...
        backgroundColor: mexicanPink,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                //Ropa Hecha con Amor y Tradición
                'Ropa hecha con amor y tradición',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkAccent
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Fin del contenido de la página. Puedes seguir bajando.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}