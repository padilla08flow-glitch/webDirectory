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
  //contolador --> busqueda 
  final TextEditingController _controlarBusqueda = TextEditingController();
  //se muestran si estan publicados
  final Stream<QuerySnapshot> _artesanosStream = FirebaseFirestore.instance
      .collection('artesanos')
      .where('publicado', isEqualTo: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _controlarBusqueda.addListener(_alCambiarBusqueda);
  }
  @override
  void dispose() {
    _controlarBusqueda.removeListener(_alCambiarBusqueda);
    _controlarBusqueda.dispose();
    super.dispose();
  }
  //metodo para filtrar busquedas desde barra de busqueda
  void _alCambiarBusqueda() {
    if (mounted) {
      setState(() {
        _filtroArtesanos(_controlarBusqueda.text);
      });
    }
  }

  //logica de filtrado
  void _filtroArtesanos(String query) {
    if (query.isEmpty) {
      _filterArtesanos = _allArtesanos;
      return;
    }

    final searchQuery = query.toLowerCase();
    _filterArtesanos = _allArtesanos.where((artesano){
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
            // ignore: unnecessary_null_comparison
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
    final screenSize = MediaQuery.of(context).size;
    const double maxContentWidth = 1200;
    
    final double containerWidth = screenSize.width > maxContentWidth 
        ? maxContentWidth 
        : screenSize.width;

    return Scaffold(
    
      appBar: AppBar(
        title: const Text('Directorio de Artesanos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.mexicanPink,
        automaticallyImplyLeading: false,
        actions: _appBarActions(context),
        elevation: 4.0,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: containerWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              
              //barra de busqueda
              children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(51),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3), 
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controlarBusqueda, 
                      style: const TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        hintText: 'Buscar artesanos por nombre, región, técnica o prenda...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, color: AppColors.mexicanPink, size: 24),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: AppColors.mexicanPink, width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                      ),
                    ),
                  ),
                ),
              ),
              
              //area de tarjetas
                StreamBuilder<QuerySnapshot>(
                  stream: _artesanosStream,
                  builder: (context, snapshot){
                    if (snapshot.hasError){
                      return Center(child: Text('Error al cargar: ${snapshot.error}', style: const TextStyle(color: AppColors.ErrorRojo)));
                    }
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: CircularProgressIndicator(color:AppColors.mexicanPink), 
                      ));
                    }
                    
                    //cargar datos
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
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(), 
                      padding: const EdgeInsets.only(top: 10.0),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                      ),
                      itemCount: _filterArtesanos.length,
                      itemBuilder: (context, index){
                        return GaleriaArtesanoCard(artesano: _filterArtesanos[index]);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
