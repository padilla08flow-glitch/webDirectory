// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:web_directorio/Artesano.dart';
import 'package:web_directorio/PerfilArtesano.dart';
import 'AppColors.dart';

class GaleriaArtesanoCard extends StatelessWidget{
  final Artesano artesano;

  const GaleriaArtesanoCard({
    Key? key, 
    required this.artesano, 
  }): super(key: key);
  
  void _navegarAPerfil(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PerfilArtesano(artesanoUid: artesano.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    final String tecnicaPrincipal = artesano.tecnicas.isNotEmpty ? artesano.tecnicas.first : 'Sin Técnica';
    final String prendaPrincipal = artesano.prendas.isNotEmpty ? artesano.prendas.first : 'Sin Prenda';

    return GestureDetector(
      onTap: () => _navegarAPerfil(context),
      child:  Card(
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.softPink.withAlpha(67),
                  child: const Center(
                  child: Icon(
                    Icons.storefront_outlined, 
                    size: 60, 
                    color: AppColors.mexicanPink
                ),
              ),
            ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artesano.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAccent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4,),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.softPink),
                      const SizedBox(width: 4),
                      Text(
                        artesano.region,
                        style: const TextStyle(
                          fontSize: 16, 
                          color: AppColors.darkAccent
                        ), 
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Técnica: $tecnicaPrincipal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkAccent,
                    ),
                  ),
                  Text(
                    'Prenda: $prendaPrincipal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkAccent,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () => _navegarAPerfil(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mexicanPink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('VER PERFIL'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
