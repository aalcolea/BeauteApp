import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientForm extends StatefulWidget {
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
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/createClient'),
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
        print('Client creado correctamente');
      } else {
        print('Error al crear cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              hintText: 'nombre',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _numberController,
            decoration: InputDecoration(
              labelText: 'Numero',
              hintText: 'Numero',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              hintText: 'Email',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: createClient,
            child: Text('Crear cliente'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
