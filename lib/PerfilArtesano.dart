// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_directorio/Artesano.dart'; 
import 'AppColors.dart'; 
import 'package:url_launcher/url_launcher.dart';

class PerfilArtesano extends StatelessWidget {
  final String artesanoUid;

  const PerfilArtesano({
    super.key,
    required this.artesanoUid,
  });

  Future<void> _launchURL(String url) async {
    // ignore: unused_local_variable
    String effectiveUrl = url;
    if(!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('tel:') && !url.startsWith('mailto:')){ 
      effectiveUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      } else{
      throw 'No se pudo abrir la URL: $url';
      }
  }

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

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.mexicanPink,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
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
                const SizedBox(height: 24),

                _buildSectionCard(
                  title: 'Acerca de nosotros',
                  content: Text(
                    artesano.descripcion,
                    style: const TextStyle(fontSize: 16, color: AppColors.darkAccent),
                  ),
                ),

                _buildSectionCard(
                  title: 'Detalles del Arte',
                  content: Column(
                    children: [
                      _buildDetailSection(
                        title: 'Técnicas(s) Principales(es)',
                        content: artesano.tecnicas.join(', '),
                        icon: Icons.palette_outlined,
                      ),
                      const SizedBox(height: 15),
                      _buildDetailSection(
                        title: 'Prenda(s) / Producto(s)', 
                        content: artesano.prendas.join(', '), 
                        icon: Icons.checkroom_outlined,
                      ),
                    ],
                  ),
                ),

                _buildSectionCard(
                  title: 'Contacto',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildContactRow(
                        Icons.place_outlined,
                        'Ubicación del Taller (Link)',
                        artesano.ubicacionTaller,
                        isLink: true,
                      ),
                      if (artesano.ubicacionTaller.isNotEmpty) const SizedBox(height: 10),

                      _buildContactRow(Icons.email_outlined, artesano.email, 'mailto:${artesano.email}'),
                      _buildContactRow(Icons.phone_outlined, artesano.telefono, 'tel:${artesano.telefono}'),
                      const SizedBox(height: 20),
                      _buildSocialMediaLinks(artesano,)
                    ],
                  ),
                ),
                 const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }


  // ns
  //tecnica/Prenda
  Widget _buildDetailSection({required String title, required String content, required IconData icon}) {
    return Column(
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
            content.isEmpty || content.contains('Sin definir') ? 'Información no proporcionada' : content,
            style: const TextStyle(fontSize: 16, color: AppColors.darkAccent),
          ),
        ),
      ],
    );
  }

  //contactos  / telefono
  Widget _buildContactRow(IconData icon, String detail, String urlScheme, {bool isLink = false}) {
    if (urlScheme.isEmpty || (detail.isEmpty && !isLink) || detail == 'Sin contacto') return const SizedBox.shrink(); 
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: () => _launchURL(urlScheme),
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
      ),
    );
  }

  Widget _buildSocialMediaLinks(Artesano artesano) {
    final Map<String, dynamic> redes = artesano.redesSociales;
    final List<Widget> socialIcons = [];
    
    //facebook
    final String facebook = redes['facebook'] ?? '';
    if (facebook.isNotEmpty) {
      socialIcons.add(
        IconButton(
          onPressed: () => _launchURL(facebook), 
          icon: const Icon(Icons.facebook, size: 35, color: AppColors.mexicanPink),
        ),
      );
    }

    // Instagram
    final String instagram = redes['instagram'] ?? '';
    if (instagram.isNotEmpty) {
      socialIcons.add(
        IconButton(
          onPressed: () => _launchURL(instagram), 
          icon: const Icon(Icons.photo_camera_outlined, size: 30, color: AppColors.mexicanPink),
        ),
      );
    }

    if (socialIcons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Redes Sociales',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mexicanPink),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: socialIcons,
        ),
      ],
    );
  }
}
