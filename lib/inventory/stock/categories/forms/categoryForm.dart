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
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
              bottom: MediaQuery.of(context).size.width * 0.085,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(

              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                      child: Text(
                        'Crear Categoria',
                        style: TextStyle(
                          color: const Color(0xFF4F2263),
                          fontSize: MediaQuery.of(context).size.width * 0.075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF4F2263),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.105,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.035,
                    bottom: MediaQuery.of(context).size.width * 0.01
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.02,
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F2263),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Nombre de la categoria:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.105,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.03),
                      hintText: 'Nombre de la categoria...',
                      hintStyle: TextStyle(
                        color: Color(0xFF4F2263).withOpacity(0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF4F2263), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width * 0.10,
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.035,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F2263),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10)
                        ),
                      ),
                      child: Text(
                        'Cargar imagen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _selectedImage != null ?
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: _requestPermission,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF4F2263), width: 1.5),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)
                                )
                            )
                        ),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      ),
                    )
                    : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.10,
                          child: ElevatedButton(
                            onPressed: _requestPermission,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF4F2263), width: 1.5),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)
                                    )
                                )
                            ),
                            child: Text(
                              'Seleccionar Imagen',
                              style: TextStyle(
                                color: Color(0xFF4F2263).withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                          child: Text(
                            '*No se ha seleccionado una imagen',
                            style: TextStyle(
                              color: Color(0xFF4F2263)
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: createCategory,
                    style: ElevatedButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: MediaQuery.of(context).size.width * 0.0112),
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Color(0xFF4F2263), width: 2),
                      ),
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 0.5,
                        MediaQuery.of(context).size.height * 0.07,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text('Crear categoria',
                        style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.width *
                              0.055,
                          color: const Color(0xFF4F2263),
                        )
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}