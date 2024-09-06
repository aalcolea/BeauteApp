import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientInfo extends StatefulWidget {
  const ClientInfo({super.key});

  @override
  State<ClientInfo> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<ClientInfo> {

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;

  Future<void> sendWhatsMsg(
      {required String phone, required String bodymsg}) async {
    if (!await launchUrl(Uri.parse('https://wa.me/$phone?text=$bodymsg'))) {
      throw Exception('No se puede enviar mensaje a $phone');
    }
  }

  Future<void> callNumber({required String phone}) async {
    if (!await launchUrl(Uri.parse("tel://$phone"))) {
      throw Exception('No se puede llamar a $phone');
    }
  }


  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            print('estoy en clientdetails');
            visibleKeyboard = visible;
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4F2263),
          leading: IconButton(
        onPressed: () {
          setState(() {
            Navigator.of(context).pop();
          });
        },
        icon: const Icon(CupertinoIcons.back,
        color: Colors.white,),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit_calendar_sharp,
          color: Colors.white,),
        ),
      ],),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.035),
            decoration: const BoxDecoration(
              color: Color(0xFF4F2263),
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 700),
                  height: visibleKeyboard ? 0 : 130,
                  child: CircleAvatar(
                    radius: 70,
                    child: Text(
                      'MA',
                      style: TextStyle(
                          fontSize: !visibleKeyboard ? MediaQuery.of(context).size.width * 0.085 : 0),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02),
                child: Text('Mario Arjona',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                      color: Colors.white
                  ),),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.11,
                        margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.width * 0.02,
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                        ),
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              onTap: () {
                                setState(() {
                                  setState(() {
                                    String phoneCode = '+529993863556';
                                    sendWhatsMsg(phone: phoneCode, bodymsg: 'Hola, Mario. Te mando mensaje para reasignar tu cita en Beaute Clinique.\n');
                                  });
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.whatsapp,
                                  size: MediaQuery.of(context).size.width * 0.12,
                                  color: const Color(0xFF4F2263),),
                                  Text('Mensaje',
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                    color: Color(0xFF4F2263),),),
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.11,
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              onTap: () {
                                setState(() {
                                  String phoneCode = '9993863556';
                                  callNumber(phone: phoneCode);
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.call,
                                    size: MediaQuery.of(context).size.width * 0.12,
                                    color: const Color(0xFF4F2263),),
                                  Text('Llamar',
                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                      color: const Color(0xFF4F2263),),),
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.11,
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              onTap: () {
                                print('jj');
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_card,
                                    size: MediaQuery.of(context).size.width * 0.12,
                                    color: const Color(0xFF4F2263),),
                                  Text('Crear cita',
                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                      color: const Color(0xFF4F2263),),),
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03),
                    child: TextFormField(
                      decoration: InputDecoration(
                        //focus
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //unfocus
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelText: 'No. Celuar',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                        vertical: MediaQuery.of(context).size.width * 0.03),
                    child: TextFormField(
                      decoration: InputDecoration(
                        //focus
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //unfocus
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelText: 'Correo electrónico',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03),
                    child: TextFormField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        //focus
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //unfocus
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4F2263), width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelText: 'Notas',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
