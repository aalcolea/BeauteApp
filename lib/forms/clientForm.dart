import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({super.key});

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> createClient() async {
    try {
      var response = await http.post(
        Uri.parse(
            'https://beauteapp-dd0175830cc2.herokuapp.com/api/createClient'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'number': _numberController.text,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Cliente agregado correctamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        print('Error al crear cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 40, top: 40),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 1,
              height: 45,
              color: const Color(0xFF4F2263),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      alignment: Alignment.center,
                      child: const Text(
                        'Nuevo cliente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side:
                              const BorderSide(width: 0.1, color: Colors.black),
                        ),
                        backgroundColor: Colors.black.withOpacity(0.15)),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Nombre del cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 30, left: 10, right: 10, top: 10),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No. Celular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 30, left: 10, right: 10, top: 10),
              child: TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  hintText: 'No. Celular',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Correo electrónico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 30, left: 10, right: 10, top: 10),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Correo electrónico',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  splashFactory: InkRipple.splashFactory,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  //elevation: 10,
                  //surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Color(0xFF4F2263), width: 2),
                  ),
                  fixedSize: Size(
                    MediaQuery.of(context).size.width * 0.6,
                    MediaQuery.of(context).size.height * 0.06,
                  ),
                  backgroundColor: const Color(0xFFEFE6F7),
                  //backgroundColor: const Color(0xFFC5B6CD),
                ),
                child: const Text(
                  'Agregar Cliente',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            /*Padding(
              padding: const EdgeInsets.only(
                  bottom: 30, left: 10, right: 10, top: 10),
              child: ElevatedButton(
                onPressed: createClient,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Crear cliente'),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
