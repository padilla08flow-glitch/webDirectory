// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_directorio/Artesano.dart'; 
import 'AppColors.dart'; 

class PerfilArtesano extends StatelessWidget {
  final String artesanoUid;

  const PerfilArtesano({
    super.key,
    required this.artesanoUid,
  });

  //obtener los datos de Artesano
  Future<Artesano> _fetchArtesano() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('artesanos')
        .doc(artesanoUid)
        .get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return Artesano.fromFirestore(docSnapshot.data()!, docSnapshot.id);
    } else {
      throw Exception("Documento de artesano no encontrado");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Artesano'),
        backgroundColor: AppColors.mexicanPink,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Artesano>(
        future: _fetchArtesano(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.mexicanPink));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Artesano no encontrado.'));
          }

          final Artesano artesano = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  artesano.nombre,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppColors.softPink),
                    const SizedBox(width: 8),
                    Text(
                      artesano.region,
                      style: const TextStyle(fontSize: 18, color: AppColors.darkAccent),
                    ),
                  ],
                ),
                
                const Divider(height: 30, color: AppColors.softPink),

                //Descripccion
                const Text(
                  'Acerca de nosotros:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mexicanPink),
                ),
                const SizedBox(height: 8),
                Text(
                  artesano.descripcion,
                  style: const TextStyle(fontSize: 16, color: AppColors.darkAccent),
                ),

                const Divider(height: 30, color: AppColors.softPink),

                //Detalles
                _buildDetailSection(
                  title: 'Técnica(s) Principal(es)',
                  content: artesano.tecnicas.join(', '),
                  icon: Icons.brush_outlined,
                ),
                _buildDetailSection(
                  title: 'Prenda(s) / Producto(s)',
                  content: artesano.prendas.join(', '),
                  icon: Icons.checkroom_outlined,
                ),

                const Divider(height: 30, color: AppColors.softPink),

                //Contacto
                const Text(
                  'Contacto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mexicanPink),
                ),
                _buildContactRow(Icons.email_outlined, artesano.email),
                _buildContactRow(Icons.phone_outlined, artesano.telefono),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
  
  //tecnica/Prenda
  Widget _buildDetailSection({required String title, required String content, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.softPink),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkAccent),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              content.isEmpty || content == 'N/A' ? 'Información no proporcionada' : content,
              style: const TextStyle(fontSize: 16, color: AppColors.darkAccent),
            ),
          ),
        ],
      ),
    );
  }

  //contactos --> email / telefono
  Widget _buildContactRow(IconData icon, String detail) {
    if (detail.isEmpty || detail == 'Sin contacto') return const SizedBox.shrink(); 
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.softPink),
          const SizedBox(width: 8),
          Text(
            detail,
            style: const TextStyle(fontSize: 16, color: AppColors.darkAccent),
          ),
        ],
      ),
    );
  }
}
