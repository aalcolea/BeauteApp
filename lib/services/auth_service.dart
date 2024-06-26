import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PinEntryScreen extends StatefulWidget {
  final int userId;

  const PinEntryScreen({super.key, required this.userId});

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
        Navigator.pushReplacementNamed(context, '/drScreen');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Credenciales inválidas'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("hola $e");
    }
  }

  String enteredPin = '';
  bool pinVisible = false;

  Widget numBtn(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.065,
              right: MediaQuery.of(context).size.width * 0.065,
              top: 10,
              bottom: 10),
          //const EdgeInsets.all(20),
          backgroundColor: const Color(0xFFA0A0A0).withOpacity(0.7),
        ),
        onPressed: () {
          setState(() {
            if (enteredPin.length < 6) {
              enteredPin += number.toString();
              pinController.text = enteredPin;
              enteredPin.length >= 6 ? authenticate() : print(enteredPin);
            }
          });
        },
        child: Text(
          number.toString(),
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.042,
              color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imgLog/bgPinentry.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height *
                    0.18), //pading entre ingrese pin y borde superior
            color: Colors.transparent,
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              physics: const BouncingScrollPhysics(),
              children: [
                const Center(
                  child: Text(
                    'Ingrese el pin',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),

                ///codigo para el pin
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.height * 0.014,
                            right: MediaQuery.of(context).size.height * 0.014),
                        width: pinVisible
                            ? 30
                            : MediaQuery.of(context).size.width * 0.048,
                        height: pinVisible
                            ? 40
                            : MediaQuery.of(context).size.width * 0.048,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(width: 3, color: Colors.white),
                          color: index < enteredPin.length
                              ? pinVisible
                                  ? Colors.black54
                                  : Colors.white
                              : Colors.transparent,
                        ),
                        child: pinVisible && index < enteredPin.length
                            ? Center(
                                child: Text(
                                enteredPin[index],
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ))
                            : null,
                      );
                    },
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      pinVisible = !pinVisible;
                    });
                  },
                  icon: Icon(
                    pinVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                    height: pinVisible
                        ? MediaQuery.of(context).size.height * 0.02
                        : MediaQuery.of(context).size.height * 0.02),

                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.042),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        3,
                        (index) => numBtn(1 + 3 * i + index),
                      ).toList(),
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.085),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(''), //SizedBox(),
                        ),
                      ),
                      Expanded(
                        child: numBtn(0),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height * 0.03,
                              top: MediaQuery.of(context).size.height * 0.015),
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                if (enteredPin.isNotEmpty) {
                                  enteredPin = enteredPin.substring(
                                      0, enteredPin.length - 1);
                                }
                              });
                            },
                            child: Icon(
                              Icons.backspace_outlined,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.height * 0.065,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      enteredPin = '';
                      Navigator.of(context).pop(context);
                    });
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),

      /*Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: authenticate,
            child: const Text('Ingresar'),
          ),
        ],
      ),*/
    );
  }
}
