import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
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

class PinEntryScreenState extends State<PinEntryScreen> with SingleTickerProviderStateMixin {
  late AnimationController aniController;
  late Animation<double> shake;
  bool isDocLog = false;
  final textfield = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isDocLog = widget.docLog;
    aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    //shake = Tween(begin: 0.0, end: 2.0).animate(CurvedAnimation(parent: aniController, curve: Curves.easeOut));
    shake = Tween(begin: 0.0, end: 2.0).animate(CurvedAnimation(parent: aniController, curve: Curves.easeOut));
  }

  void authenticate() async {
    try {
      String jsonBody;
      if (widget.userId == 3) {
        jsonBody = json.encode({
          'email': 'dulce@test.com',
          'password': enteredPin,
          'fcm_token': await FirebaseMessaging.instance.getToken(),
        });
      } else {
        jsonBody = json.encode({
          'email': 'doctor${widget.userId}@test.com',
          'password': enteredPin,
          'fcm_token': await FirebaseMessaging.instance.getToken(),
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
        setState(() {
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
          enteredPin = '';
        });

      }
    } catch (e) {
      print("Error $e");
    }
  }
  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token != null) {
      var response = await http.post(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('jwt_token');
        await prefs.remove('user_id');
          Navigator.pushNamedAndRemoveUntil(
            context, '/', (Route<dynamic> route) => false,
          );


      } else {
        print('Error al cerrar sesión: ${response.body}');
      }
    }
  }

  String enteredPin = '';
  bool pinVisible = false;

  onNumberTapped(number) {
    setState(() {
      if (enteredPin.length < 4) {
        textfield.text += number;
        enteredPin += number.toString();
        enteredPin.length >= 4 ? authenticate() : null;
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
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
            width: MediaQuery.of(context).size.width * 0.182,
            height: MediaQuery.of(context).size.width * 0.182,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        //padding: EdgeInsets.zero,
                        //color: Colors.red,
                          child: Text(
                            numK,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              inherit: false,
                              fontSize: MediaQuery.of(context).size.width * 0.09,
                              color: Colors.white,
                            ),
                          ),

                      ),
                      Container(
                        //color: Colors.black,
                        child: Text(
                          textAlign: TextAlign.start,
                          desc,
                          style: TextStyle(
                            inherit: false,
                              fontSize:
                              MediaQuery.of(context).size.width * 0.025,
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                      )
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
        onPressed: enteredPin.isNotEmpty
            ? () {
                onCancelText();
              }
            : () {
                widget.onCloseScreeen(true);
              },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child:
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.085),
          child: Text(
            enteredPin.isNotEmpty ? 'Eliminar' : 'Cancelar',
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.0475),
          ),
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
                '6', 'M N O', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '7', 'P Q R S', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '8', 'T U V', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            keyField(
                '9', 'W X Y Z', const Color(0xFFA0A0A0).withOpacity(0.2), 7.0),
            /*    keyField('', '', Colors.transparent, 0.0),
            keyField('0', 'X Y Z', const Color(0xFFA0A0A0).withOpacity(0.2),7.0),
            keyField('', '', Colors.transparent, 0.0),*/
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Ingrese el pin',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.065,
                        color: Colors.white,
                      ),
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
                              right: MediaQuery.of(context).size.height * 0.014),
                          width: pinVisible
                              ? 30
                              : MediaQuery.of(context).size.width * 0.03,
                          height: pinVisible
                              ? 40
                              : MediaQuery.of(context).size.width * 0.03,
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
                ///termina para el pin

                gridView(),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.055,//0 para iphone
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      keyField('0', '',
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
      );
  }
}
