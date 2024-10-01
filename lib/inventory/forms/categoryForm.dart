import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryForm extends StatefulWidget {
  const CategoryForm({Key? key}) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  TextEditingController nameController = TextEditingController();
  File? _selectedImage;
  final picker = ImagePicker();
  bool isLoading = false;
  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      pickImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso denegado para acceder a las imágenes')),
      );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> createCategory() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingresa el nombre de la categoría")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    const baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories';
    String? token = prefs.getString('jwt_token');

    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = nameController.text;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _selectedImage!.path));
      }

      final response = await request.send();

      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria creada exitosamente')),
        );
        Navigator.of(context).pop(true);
      }else{
        String errorMessage = 'Error al crear la categoria';
        try {
          final responseData = jsonDecode(responseBody.body);
          errorMessage = responseData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error inesperado: ${responseBody.body}';
        }

        print('errro ${errorMessage}');
      }
    } catch (e) {
      print("Error: $e");


      print('errr inesperado ${e}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Crear Categoria',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F2263),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Categoria',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                _selectedImage != null
                    ? Image.file(
                  _selectedImage!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
                    : Text('No se ha seleccionado una imagen'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: Text('Seleccionar Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF4F2263), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: createCategory,
                  child: Text('Crear Categoría'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF4F2263), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: Color(0xFF4F2263)),
            ),
          ),
        ],
      ),
    );
  }
}