import 'dart:async';
import 'package:beaute_app/forms/appoinmentForm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientInfo extends StatefulWidget {
  final bool isDoctorLog;
  final String name;
  final int phone;
  final String email;

  const ClientInfo({super.key, required this.isDoctorLog, required this.name, required this.phone, required this.email});

  @override
  State<ClientInfo> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<ClientInfo> {
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  late bool isDocLog;
  String name = '';
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool editInfo = false;

  String? oldNameValue;
  String? oldPhone;
  String? oldEmail;

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
    isDocLog = widget.isDoctorLog;
    name = widget.name;
    nameController.text = widget.name;
    emailController.text = widget.email;
    phoneController.text = widget.phone.toString();
    checkKeyboardVisibility();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilitySubscription.cancel();
    //emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: !editInfo ? null : 100,
        backgroundColor: const Color(0xFF4F2263),
        leading: !editInfo
            ? IconButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                icon: const Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                ),
              )
            : TextButton(
                onPressed: () {
                  setState(() {
                    emailController.text = oldEmail!;
                    nameController.text = oldNameValue!;
                    phoneController.text = oldPhone!;
                    editInfo = false;
                  });
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.045),
                )),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    editInfo == false ? editInfo = true : editInfo = false;
                    oldEmail = emailController.text;
                    oldNameValue = nameController.text;
                    oldPhone = phoneController.text;
                  });
                },
                child: Text(
                  !editInfo ? 'Editar' : 'Guardar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.045),
                ),
              ),
            ],
          )
        ],
      ),
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
                  duration: const Duration(milliseconds: 420),
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
                child: TextFormField(
                  readOnly: !editInfo,
                  textAlign: TextAlign.center,
                  controller: nameController,
                  decoration: InputDecoration(
                    filled: editInfo,
                    fillColor: Colors.grey.withOpacity(0.4),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)
                    ),

                  ),
                  style: TextStyle(
                      color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.065,
                  )
                )),
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
                                    String phoneCode = '+52${phoneController.text}';
                                    sendWhatsMsg(phone: phoneCode, bodymsg: 'Hola, $name. Te mando mensaje para reasignar tu cita en Beaute Clinique.\n');
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
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              onTap: () {
                                setState(() {
                                  callNumber(phone: phoneController.text);
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
                                setState(() {
                                  Navigator.push(context,
                                    CupertinoPageRoute(
                                      builder: (context) => AppointmentForm(isDoctorLog: isDocLog, nameClient: name),
                                    ),
                                  );
                                });
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
                      controller: phoneController,
                      readOnly: !editInfo,
                      decoration: InputDecoration(
                        filled: editInfo,
                        fillColor: Colors.grey.withOpacity(0.135),
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
                      readOnly: !editInfo,
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: editInfo,
                        fillColor: Colors.grey.withOpacity(0.135),
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
                  const Visibility(
                      child: Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Row(
                          children: [
                            Text('Cita proxima el dia 26 de noviembre de 2024'),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Text('Cantidad de citas de $name: 30'),
                      ],
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
