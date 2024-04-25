import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PinEntryScreen extends StatefulWidget {
  final int userId;

  const PinEntryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  PinEntryScreenState createState() => PinEntryScreenState();
}

class PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController pinController = TextEditingController();

  void authenticate() async {
    try {
      var response = await http.post(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/login'),
        //Uri.parse('http://192.168.1.220:8080/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'doctor${widget.userId}@test.com',
          'password': pinController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        Navigator.pushReplacementNamed(context, '/agenda');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Credenciales inválidas'),
            actions: <Widget>[
              TextButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingrese PIN')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: authenticate,
            child: Text('Ingresar'),
          ),
        ],
      ),
    );
  }
}
