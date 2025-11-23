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
      if (rawData is String) {
        return [rawData];
      }
      if (rawData is List) {
        return List<String>.from(rawData);
      }
      return ['Sin definir'];
    }

    return Artesano(
      uid: id,
      nombre: data['nombre'] ?? 'Artesano Desconocido',
      region: data['region'] ?? 'Oaxaca',
      descripcion: data['descripcion'] ?? 'Sin descripción.',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? 'Sin contacto',
      tecnicas: _toList(data['tecnica']), 
      prendas: _toList(data['prenda']), 
      publicado: data['publicado'] ?? false,
    );
  }
}
