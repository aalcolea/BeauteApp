import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PinEntryScreen extends StatefulWidget {
  final int userId;
  final bool docLog;
  final void Function(
    bool,
  ) onCloseScreeen;

  const PinEntryScreen(
      {super.key,
      required this.userId,
      required this.docLog,
      required this.onCloseScreeen});

  @override
  PinEntryScreenState createState() => PinEntryScreenState();
}

class PinEntryScreenState extends State<PinEntryScreen> {
  final pinController = TextEditingController();
  bool isDocLog = false;
  final textfield = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isDocLog = widget.docLog;
  }

  void authenticate() async {
    try {
      String jsonBody;
      if (widget.userId == 3) {
        jsonBody = json.encode({
          'email': 'dulce@test.com',
          'password': pinController.text,
        });
      } else {
        jsonBody = json.encode({
          'email': 'doctor${widget.userId}@test.com',
          'password': pinController.text,
        });
      }

      var response = await http.post(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        await prefs.setInt('user_id', data['user']['id']);
        print(data['user']['id']);
        if (isDocLog == true) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/drScreen',
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/assistantScreen',
            (Route<dynamic> route) => false,
          );
        }
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
      print("Error $e");
    }
  }

  String enteredPin = '';
  bool pinVisible = false;

  Widget numBtn(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.085,
              right: MediaQuery.of(context).size.width * 0.085,
              top: 10,
              bottom: 10),
          //const EdgeInsets.all(20),
          backgroundColor: const Color(0xFFA0A0A0).withOpacity(0.70),
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

  onNumberTapped(number) {
    setState(() {
      if (enteredPin.length < 6) {
        textfield.text += number;
        enteredPin += number.toString();
        pinController.text = enteredPin;
        enteredPin.length >= 6 ? authenticate() : print(enteredPin);
      }
    });
  }

  onCancelText() {
    setState(() {
      if (enteredPin.isNotEmpty) {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        textfield.text = enteredPin;
      }
    });
  }

  Widget inputField() {
    return Container(
      color: const Color(0xFFA0A0A0).withOpacity(0.7),
      height: 100,
      alignment: Alignment.bottomCenter,
      child: TextFormField(
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        controller: textfield,
      ),
    );
  }

  Widget keyField(numK, desc, col, blur) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusColor: Colors.white,
          splashColor: Colors.white,
          onTap: () => onNumberTapped(numK),
          child: Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0),
            width: MediaQuery.of(context).size.width * 0.182,
            height: MediaQuery.of(context).size.width * 0.182,
            decoration: BoxDecoration(
              color: col,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        numK,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.074,
                            color: Colors.white),
                      ),
                      Text(
                        desc,
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.0325,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget backSpace() {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.07),
      alignment: Alignment.centerRight,
      //mainAxisAlignment: MainAxisAlignment.end,
      child: TextButton(
        onPressed: textfield.text.isNotEmpty
            ? () {
                onCancelText();
              }
            : () {
                widget.onCloseScreeen(true);
              },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Text(
          textfield.text.isNotEmpty ? 'Eliminar' : 'Cancelar',
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.0485),
        ),
      ),
    );
  }

  Widget gridView() {
    return Container(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.16,
            right: MediaQuery.of(context).size.width * 0.16,
            top: MediaQuery.of(context).size.width * 0.03),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: MediaQuery.of(context).size.width * 0.06,
          mainAxisSpacing: MediaQuery.of(context).size.width * 0.06,
          crossAxisCount: 3,
          shrinkWrap: true,
          children: [
            keyField('1', '', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '2', 'A B C', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '3', 'D E F', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '4', 'G H I', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '5', 'J K L', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '6', 'M N Ñ', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '7', 'O P Q', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '8', 'R S T', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '9', 'U V W', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            /*    keyField('', '', Colors.transparent, 0.0),
            keyField('0', 'X Y Z', const Color(0xFFA0A0A0).withOpacity(0.2),7.0),
            keyField('', '', Colors.transparent, 0.0),*/
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111).withOpacity(0.7),
            ),
            child: Column(
              children: [
                //inputField(),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                  ),
                  child: Center(
                    child: Text(
                      'Ingrese el pin',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.065,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                ///codigo para el pin
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.04,
                    top: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) {
                        return Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height * 0.014,
                              right:
                                  MediaQuery.of(context).size.height * 0.014),
                          width: pinVisible
                              ? 30
                              : MediaQuery.of(context).size.width * 0.040,
                          height: pinVisible
                              ? 40
                              : MediaQuery.of(context).size.width * 0.040,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 1.2, color: Colors.white),
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
                ),

                gridView(),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.06,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      keyField('0', 'X Y Z',
                          const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      backSpace(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
