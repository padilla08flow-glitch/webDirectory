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

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _tecnicasController = TextEditingController();
  final TextEditingController _prendasController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  bool _isLoading = false;
  bool _isPublished = false;
  //String? _currentLogourl;

  @override
  void initState(){
    super.initState();
    _loadArtesanoData();
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
    super.dispose();
  }

  Future<void> _loadArtesanoData() async{
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
        _tecnicasController.text = artesano.tecnicas.join(', '); 
        _prendasController.text = artesano.prendas.join(', ');
        _isPublished = artesano.publicado;


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

  Future<void> _saveChanges() async {
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
        'ultimaEdicion': FieldValue.serverTimestamp(),
        });

        if(mounted){
          _showSnackBar('Perfil actualizado exitosamente.', isError: false);
          Navigator.of(context).pop();
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
  }){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: labeltext,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.softPink.withAlpha(112), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.mexicanPink, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
        ),
        style: const TextStyle(color: AppColors.darkAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil de Artesano', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.mexicanPink,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.mexicanPink))
        :SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: AppColors.softPink,
                    child: Icon(Icons.storefront_outlined, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Text('Información General', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color:AppColors.darkAccent)),
                const Divider(color: AppColors.softPink),
                
                _buildTextField(
                  controller: _nombreController,
                  labeltext: 'Nombre del Artesano o Tienda',
                  validator: (value) => value!.isEmpty ? 'El nombre es requerido.' : null,
                ),

                _buildTextField(
                  controller: _descripcionController, 
                  labeltext: 'Descripción (Acerca de nosotros)',
                  maxLines: 4,
                  hintText: 'Describe tu trabajo.',
                ),

                _buildTextField(
                  controller: _regionController,
                  labeltext: 'Región o Pueblo de Origen',
                  validator: (value) => value!.isEmpty ? 'La región es requerida.' : null,
                ),
                _buildTextField(
                  controller: _telefonoController, 
                  labeltext: 'Número de Teléfono',
                  keyboardType: TextInputType.phone,
                  hintText: 'Ej. +52 234 121 3467',
                ),

                _buildTextField(
                  controller: _tecnicasController, 
                  labeltext: 'Técnica(s) Principal(es)',
                  hintText: 'Separar por comas (ej). Telar de cintura...',
                  validator: (value) => value!.isEmpty ? 'Al menos una técnica es requerida.' : null,
                ),
                _buildTextField(
                  controller: _prendasController, 
                  labeltext: 'Prenda(s) / Producto(s)',
                  hintText: 'Separar por comas... Huipiles, Blusas, Juyeria...',
                  validator: (value) => value!.isEmpty ? 'Al menos un producto es requerido.' : null,
                ),

                const SizedBox(height: 20),
                Text('Redes Sociales', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.darkAccent)),
                const Divider(color: AppColors.softPink),
                
                _buildTextField(
                  controller: _facebookController,
                  labeltext: 'Facebook (URL o Nombre de Usuario)',
                  keyboardType: TextInputType.url,
                ),
                _buildTextField(
                  controller: _instagramController, 
                  labeltext: 'Instagram (URL o Nombre de Usuario)',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Publicar en el Directorio', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.darkAccent)),
                    Switch(
                      value: _isPublished, 
                      onChanged: (newValue){
                        setState(() {
                          _isPublished = newValue;
                        });
                      },
                      activeColor: AppColors.mexicanPink,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.mexicanPink))
                  : ElevatedButton (
                    onPressed: _saveChanges, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mexicanPink,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }
}
