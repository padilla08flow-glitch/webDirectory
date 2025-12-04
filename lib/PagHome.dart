// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_directorio/Artesano.dart';
import 'package:web_directorio/GaleriaArtesanoCard.dart';
import 'package:web_directorio/IniciarSesion.dart'; 
import 'package:web_directorio/EditarPerfilArtesano.dart';
import 'AppColors.dart'; 

class PagHome extends StatefulWidget {
  const PagHome({super.key});

  @override
  State<PagHome> createState() => _PagHomeState();
}

class _PagHomeState extends State<PagHome> {

  List<Artesano> _allArtesanos = [];
  List<Artesano> _filterArtesanos = [];
  final TextEditingController _controlarBusqueda = TextEditingController();
  final Stream<QuerySnapshot> _artesanosStream = FirebaseFirestore.instance
      .collection('artesanos')
      .where('publicado', isEqualTo: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _controlarBusqueda.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controlarBusqueda.removeListener(_onSearchChanged);
    _controlarBusqueda.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _filtroArtesanos(_controlarBusqueda.text);
      });
    }
  }

  void _filtroArtesanos(String query) {
    if (query.isEmpty) {
      _filterArtesanos = _allArtesanos;
      return;
    }

    final searchQuery = query.toLowerCase();
    _filterArtesanos = _allArtesanos.where((artesano) {
      final nombre = artesano.nombre.toLowerCase();
      final region = artesano.region.toLowerCase();
      final tecnicas = artesano.tecnicas.join(' ').toLowerCase(); 
      final prendas = artesano.prendas.join(' ').toLowerCase();

      return nombre.contains(searchQuery) || 
             region.contains(searchQuery) ||
             tecnicas.contains(searchQuery) ||
             prendas.contains(searchQuery);

    }).toList();
  }

  List<Widget> _appBarActions(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isArtesano = currentUser != null;

    if (isArtesano){
      return [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          tooltip: 'Editar mi Perfil',
          onPressed: (){
            if (currentUser != null){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditarPerfilArtesano(artesanoUid: currentUser.uid),
                ),
              );
            }
          },
        ),
        // para Cerrar Sesion
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Cerrar Sesión',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const IniciarSesion()),
                (Route<dynamic> route) => false,
              );
            }
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.login, color: Colors.white),
          tooltip: 'Iniciar Sesión',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const IniciarSesion()),
            );
          },
        )
      ];
    }
  }

  //interfaz
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Artesanos', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.mexicanPink,
        automaticallyImplyLeading: false,
        actions: _appBarActions(context),
      ),
      
      body: Column(
        children: [
          //metodo de busqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controlarBusqueda, 
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, región, técnica o prenda...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),

          //actualizar la lista
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _artesanosStream,
              builder: (context, snapshot){
                if (snapshot.hasError){
                  return Center(child: Text('Error al cargar: ${snapshot.error}', style: const TextStyle(color: AppColors.ErrorRojo)));
                }
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.mexicanPink));
                }

                final List<Artesano> fetchedArtesanos = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Artesano.fromFirestore(data, doc.id);
                }).toList();

                if(_allArtesanos.length != fetchedArtesanos.length || 
                    _allArtesanos.isEmpty) {
                  _allArtesanos = fetchedArtesanos;
                  _filtroArtesanos(_controlarBusqueda.text); 
                }
                
                // resultados que coinciden
                if(_filterArtesanos.isEmpty) {
                  if (_controlarBusqueda.text.isNotEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron artesanos con esos criterios de búsqueda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: AppColors.darkAccent),
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      'Aún no hay artesanos publicados...',
                      style: TextStyle(fontSize: 18, color: AppColors.darkAccent),
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _filterArtesanos.length,
                  itemBuilder: (context, index){
                    return GaleriaArtesanoCard(artesano: _filterArtesanos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
