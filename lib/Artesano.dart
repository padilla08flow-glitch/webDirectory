// ignore_for_file: type=lint
//import 'package:cloud_firestore/cloud_firestore.dart';

class Artesano {
  final String uid;
  final String nombre;
  final String region;
  final String descripcion;
  final String email;
  final String telefono;
  final List<String> prendas; 
  final List<String> tecnicas; 
  final bool publicado;
  
  final String? logoUrl; 

  const Artesano({
    required this.uid,
    required this.nombre,
    required this.region,
    required this.descripcion,
    required this.email,
    required this.telefono,
    required this.prendas,
    required this.tecnicas,
    this.publicado = false,
    this.logoUrl,
  });

  factory Artesano.fromFirestore(Map<String, dynamic> data, String id) {
    
    List<String> _toList(dynamic rawData) {
      if (rawData is List) {
        return List<String>.from(rawData);
      }
      if (rawData is String && rawData.isNotEmpty) {
        return [rawData];
      }
      return ['Sin definir'];
    }

    return Artesano(
      uid: id,
      nombre: data['nombreArtesano'] ?? 'Artesano Desconocido',
      region: data['regionOrigen'] ?? 'Oaxaca',
      descripcion: data['descripcion'] ?? 'Sin descripción.',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? 'Sin contacto',
      tecnicas: _toList(data['tecnicas']),
      prendas: _toList(data['prendas']),
      publicado: data['publicado'] ?? false,
      logoUrl: data['logo_url'],
    );
  }
}
