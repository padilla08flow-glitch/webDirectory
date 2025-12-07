// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_directorio/Artesano.dart';
import 'package:web_directorio/AppColors.dart';

//clase para seguir editando los datos del artesano 
//se publican al registrarse 
//pero necesitan seguir siendo editables 

class EditarPerfilArtesano extends StatefulWidget{
    final String artesanoUid;
    const EditarPerfilArtesano({super.key, required this.artesanoUid});

    @override 
    State<EditarPerfilArtesano> createState() => _EditarPerfilArtesanoState();
}

class _EditarPerfilArtesanoState extends State<EditarPerfilArtesano> {
  final _formKey = GlobalKey<FormState>();

  //controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _tecnicasController = TextEditingController();
  final TextEditingController _prendasController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _ubicacionTallerController = TextEditingController();

  bool _isLoading = false;
  bool _isPublished = false;
  String? _currentEmail;

  @override
  void initState(){
    super.initState();
    _cargarDatosArtesano();
  }
  @override
  void dispose(){
    _nombreController.dispose();
    _descripcionController.dispose();
    _regionController.dispose();
    _telefonoController.dispose();
    _tecnicasController.dispose();
    _prendasController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _ubicacionTallerController.dispose();
    super.dispose();
  }

  //logica para cargar datos
  Future<void> _cargarDatosArtesano() async{
    setState(() { _isLoading = true;});
    try{
      final docSnapshot = await FirebaseFirestore.instance
      .collection('artesanos')
      .doc(widget.artesanoUid)
      .get();

      if(docSnapshot.exists && docSnapshot.data() != null){
        final data = docSnapshot.data()!;
        final artesano = Artesano.fromFirestore(data, docSnapshot.id);

        _nombreController.text = artesano.nombre;
        _descripcionController.text = artesano.descripcion;
        _regionController.text = artesano.region;
        _telefonoController.text = artesano.telefono;
        _currentEmail = artesano.email;
        _tecnicasController.text = artesano.tecnicas.join(', '); 
        _prendasController.text = artesano.prendas.join(', ');
        _isPublished = artesano.publicado;
        //_ubicacionTallerController.text = artesano.ubicacionTaller;
        
        if(data['ubicacionTaller'] is Map){
          _ubicacionTallerController.text = data['ubicacionTaller']['maps'] ?? '';
        }

        if(data['redesSociales'] is Map){
          _facebookController.text = data['redesSociales']['facebook'] ?? '';
          _instagramController.text = data['redesSociales']['instagram'] ?? '';
        }

      }else {
        _showSnackBar('No se encontraron los datos del Artesano', isError: true);
      }
    }catch(e) {
      _showSnackBar('Error al cargar los datos: $e', isError:true);
    } finally {
      if(mounted){
        setState(() { _isLoading = false; });
      }
    }
  }

  //logica para guardar los datos
  Future<void> _guardarCambios() async {
    if(!_formKey.currentState!.validate()){
      return;
    }
    setState(() { _isLoading = true; });

    try{
      final docRef = FirebaseFirestore.instance.collection('artesanos').doc(widget.artesanoUid);
      final List<String> tecnicasList = _tecnicasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
      final List<String> prendasList = _prendasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

        await docRef.update({
        'nombreArtesano': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'regionOrigen': _regionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'tecnicas': tecnicasList.isEmpty ? ['Sin definir'] : tecnicasList,
        'prendas': prendasList.isEmpty ? ['Sin definir'] : prendasList,
        'publicado': _isPublished,
        'redesSociales': {
          'facebook': _facebookController.text.trim(),
          'instagram': _instagramController.text.trim(),
        },
        'ubicacionTaller': _ubicacionTallerController.text.trim(),
        'ultimaEdicion': FieldValue.serverTimestamp(),
        });

        if(mounted){
          _showSnackBar('Perfil actualizado exitosamente.', isError: false);
          Navigator.of(context).pop(); //volver
        }
    }catch (e){
      _showSnackBar('Error al guardar los cambios $e', isError: true);
      print('Error al guardar cambios: $e');
    }finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.ErrorRojo : AppColors.verdeCierto,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labeltext,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: labeltext,
          hintText: hintText,
          prefixIcon: prefixIcon != null? Icon(prefixIcon, color: AppColors.mexicanPink.withAlpha(178)) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.softPink.withAlpha(112), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.mexicanPink, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
        ),
        style: const TextStyle(color: AppColors.darkAccent),
      ),
    );
  }
  
  Widget _buildSidebarPanel({double width = 300}){
    return Container(
      width: width,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      //estado de publicacion
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Estado de Publicación', style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: AppColors.darkAccent
          )),
          
          const Divider(color: AppColors.softPink, thickness: 1.5, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isPublished ? 'Visible en Directorio' : 'Perfil Oculto', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _isPublished ? AppColors.verdeCierto : AppColors.ErrorRojo,
                )
              ),
              Switch.adaptive(
                value: _isPublished, 
                onChanged: (newValue){
                  setState(() {
                    _isPublished = newValue;
                  });
                },
                activeColor: AppColors.mexicanPink,
                activeTrackColor: AppColors.softPink,
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          //Redes sociales
          Text('Redes Sociales', style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: AppColors.darkAccent
          )),
          const Divider(color: AppColors.softPink, thickness: 1.5, height: 25),
          
          _buildTextField(
           controller: _facebookController,
            labeltext: 'Facebook... Link de perfil URL',
            keyboardType: TextInputType.url,
            prefixIcon: Icons.facebook,
          ),
          _buildTextField(
            controller: _instagramController, 
            labeltext: 'Instagram... Link de perfil',
            keyboardType: TextInputType.url,
            prefixIcon: Icons.camera_alt_outlined,
          ),
          _buildTextField(
            controller: _ubicacionTallerController,
            labeltext: 'Ubicación del Taller (Link o Dirección)',
            keyboardType: TextInputType.url,
            hintText: 'Ej. https://goo.gl/maps/... ',
            prefixIcon: Icons.map_outlined,
          ),
          
          //contacto
          const SizedBox(height: 10),
          Text('Infromación de Contacto', style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,color: AppColors.darkAccent
          )),
          const Divider(color: AppColors.softPink, thickness: 1.5, height: 25),
          
          _buildTextField(
            controller: _telefonoController, 
            labeltext: 'Número de Teléfono',
            keyboardType: TextInputType.phone,
            hintText: 'Ej. +52 234 121 3467',
            validator: (value) => value!.isEmpty ? 'El teléfono es requerido.' : null,
            prefixIcon: Icons.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildMainPanel(){
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información General', style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: AppColors.darkAccent
          )),
          const Divider(color: AppColors.softPink, thickness: 1.5, height: 25),
          
          //nombre
          _buildTextField(
            controller: _nombreController,
            labeltext: 'Nombre del Artesano o Taller',
            validator: (value) => value!.isEmpty ? 'El nombre es requerido.' : null,
            prefixIcon: Icons.storefront,
          ),
            
          //Región / Ubicacion
          _buildTextField(
            controller: _regionController,
            labeltext: 'Región o Pueblo de Origen',
            validator: (value) => value!.isEmpty ? 'La región es requerida.' : null,
            prefixIcon: Icons.location_on,
          ),
          //descripcion
          _buildTextField(
            controller: _descripcionController, 
            labeltext: 'Descripción',
            maxLines: 5,
            hintText: 'Describe tu trabajo.',
            prefixIcon: Icons.description,
          ),
          //tecnicas
          _buildTextField(
            controller: _tecnicasController, 
            labeltext: 'Técnica(s) Principal(es)',
            hintText: 'Separar por comas... Telar de cintura, Bordado...',
            validator: (value) => value!.isEmpty ? 'Al menos una técnica es requerida.' : null,
            prefixIcon: Icons.design_services,
          ),
          //prendas
          _buildTextField(
            controller: _prendasController, 
            labeltext: 'Prenda(s) / Producto(s)',
            hintText: 'Separar por comas... Huipiles, Blusas...',
            validator: (value) => value!.isEmpty ? 'Al menos un producto es requerido.' : null,
            prefixIcon: Icons.checkroom,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F7),
      appBar: AppBar(
        title: const Text('Editar Perfil de Artesano', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.mexicanPink,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.mexicanPink))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: AppColors.softPink,
                          child: Icon(Icons.storefront_outlined, size: 60, color: AppColors.mexicanPink),
                        ),
                      ),

                      const SizedBox(height: 30),
                      LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 800) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: _buildMainPanel(),
                                    ),
                                    const SizedBox(width: 20),

                                    Flexible(
                                      flex: 1,
                                      child: _buildSidebarPanel(),
                                    ),
                                  ],
                                );

                              } else {

                                return Column(
                                  children: [
                                    _buildMainPanel(),
                                    const SizedBox(height: 10),
                                    _buildSidebarPanel(width: double.infinity),
                                  ],
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 30),
                          // boton de Guardar
                          _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.mexicanPink))
                            : ElevatedButton (
                                onPressed: _guardarCambios, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mexicanPink,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 8,
                                ),
                                child: const Text(
                                  'GUARDAR CAMBIOS',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                                ),
                              ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
              ),
            ),
        ),
      
    );
  }
}
