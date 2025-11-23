// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_directorio/Artesano.dart';
import 'package:web_directorio/GaleriaArtesanoCard.dart';
import 'package:web_directorio/IniciarSesion.dart'; //listo

import 'AppColors.dart'; 

class PagHome extends StatelessWidget {
  const PagHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Artesanos', style: TextStyle(color: Colors.white)),

        backgroundColor: AppColors.mexicanPink, 
        actions: [
          //boton para cerrar sesion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              if(context.mounted){
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const IniciarSesion()),
                  (Route<dynamic> route) => false,
                );
              }
            }
          )
        ],
      ),

      //logica para cargar el directorio --> prueba /ay ns
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('artesanos')
          .where('publicado', isEqualTo: true)
          .snapshots(),

          builder: (context, snapshot) {

            if(snapshot.hasError){
              return Center(child: Text('Error al cargar: ${snapshot.error}', style: TextStyle(color: AppColors.ErrorRojo)));
            }

            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(color:AppColors.mexicanPink));
            }

            final List<Artesano> artesanos = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Artesano.fromFirestore(data, doc.id);
            }).toList();

            if(artesanos.isEmpty){
              return const Center(
                child: Text(
                  'Aún no hay artesanos publicados...',
                  style: TextStyle(fontSize: 18, color: AppColors.darkAccent),
                ),
              );
            }
            
            //mostrar tarjetitas
            return GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 0.75,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: artesanos.length,
              itemBuilder: (context, index){
                return GaleriaArtesanoCard(artesano: artesanos[index]);
              },
            );
          },
      )
    );
  }
}
