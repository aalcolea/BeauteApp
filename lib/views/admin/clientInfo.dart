import 'dart:async';
import 'dart:convert';
import 'package:beaute_app/forms/appoinmentForm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../utils/PopUpTabs/deleteClientDialog.dart';
import '../../utils/showToast.dart';
import '../../utils/toastWidget.dart';

class ClientInfo extends StatefulWidget {
  final bool isDoctorLog;
  final String name;
  final int phone;
  final String email;
  final int id;

  const ClientInfo({super.key, required this.id, required this.isDoctorLog, required this.name, required this.phone, required this.email});

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
  TextEditingController phoneControllerToView = TextEditingController();
  TextEditingController emailControllerToView = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool editInfo = false;
  int maxLines = 2;

  String? oldNameValue;
  String? oldPhone;
  String? oldEmail;

  final storage = const FlutterSecureStorage();
  bool isButtonEnabled = false;

  void updateUserInfo() async {
    final url = Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/editUserInfo/${widget.id}');
    final token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': nameController.text,
          'number':phoneController.text,
          'email': emailController.text,
        }),
      );
      print('antes del toast');
        if (response.statusCode == 200) {
          showOverlay(
            context,
            const CustomToast(
              message: 'Datos actualizados correctamente',
            ),
          );
          isButtonEnabled = false;
        } else {
          CustomToast(
              message: "Error al actualizar los datos: ${response.body}");
          print("Error al actualizar los datos: ${response.body}");
        }

    } catch (e) {
      CustomToast(message: "Error al hacer la solicitud: $e");
      print("Error al hacer la solicitud: $e");
    }
  }

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
            visibleKeyboard = visible;
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }
  Future<void> deleteClient(int id) async{
    const baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/deleteClient/';
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if(response.statusCode == 200){
        print('Cliente eleminado con exito');
      }else{
        print('Response: ${response.body}');
      }
    }catch(e){
      print('Error: $e');
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
          phoneController.text = '\n${phoneController.text}';
          emailController.text = '\n${emailController.text}';
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilitySubscription.cancel();
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
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
                    /*emailController.text = oldEmail!;
                    nameController.text = oldNameValue!;
                    phoneController.text = oldPhone!;*/
                    maxLines = 2;
                    editInfo = false;
                    phoneController.text = '\n${phoneController.text}';
                    emailController.text = '\n${emailController.text}';
                    print('phoneController ${phoneController.text}');
                    emailController.text = oldEmail!;
                    nameController.text = oldNameValue!;
                    phoneController.text = oldPhone!;
                    print('emailController ${emailController.text}');
                    print('nameController ${nameController.text}');
                    print('phoneController ${phoneController.text}');

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
                onPressed: editInfo == false
                    ? () {
                        setState(() {
                          editInfo = true;
                          oldEmail = emailController.text;
                          oldNameValue = nameController.text;
                          oldPhone = phoneController.text;
                          maxLines = 1;
                          phoneController.text = phoneController.text.trim();
                          emailController.text = emailController.text.trim();
                        });
                      }
                    : () {
                        setState(() {

                          maxLines = 2;
                          editInfo = false;
                          phoneController.text = '\n${phoneController.text}';
                          emailController.text = '\n${emailController.text}';
                          print('guardar');
                          oldPhone == phoneController.text && oldEmail == emailController.text && oldNameValue == nameController.text ?
                          null : updateUserInfo();
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
                Row(
                    children: [
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          decoration: BoxDecoration(
                            border: !editInfo
                                ? null
                                : Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: TextFormField(
                                  readOnly: !editInfo,
                                  textAlign: TextAlign.center,
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    filled: editInfo,
                                    fillColor: const Color(0xFF410C58),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width *
                                            0.065,
                                  )))))
                ]),
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
                              onTap: !editInfo ? () {
                                setState(() {
                                  setState(() {
                                    String phoneCode = '+52${phoneController.text.trim()}';
                                    sendWhatsMsg(phone: phoneCode, bodymsg: 'Hola, $name. Te mando mensaje para reasignar tu cita en Beaute Clinique.\n');
                                  });
                                });
                              } : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.whatsapp,
                                  size: MediaQuery.of(context).size.width * 0.12,
                                  color: editInfo ? Color(0xFF4F2263).withOpacity(0.3) : Color(0xFF4F2263),),
                                  Text('Mensaje',
                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                    color: editInfo ? Color(0xFF4F2263).withOpacity(0.3) : Color(0xFF4F2263),),),
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
                              onTap: !editInfo ? () {
                                setState(() {
                                  callNumber(phone: phoneController.text);
                                });
                              }: null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.call,
                                    size: MediaQuery.of(context).size.width * 0.12,
                                    color: editInfo ? Color(0xFF4F2263).withOpacity(0.3) : Color(0xFF4F2263),),
                                  Text('Llamar',
                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                      color: editInfo ? Color(0xFF4F2263).withOpacity(0.3) : Color(0xFF4F2263),),),
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
                              onTap: editInfo == false ? () {
                                setState(() {
                                  Navigator.push(context,
                                    CupertinoPageRoute(
                                      builder: (context) => AppointmentForm(isDoctorLog: isDocLog, nameClient: name, idScreenInfo: widget.id,),
                                    ),
                                  );
                                });
                              } : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_card,
                                    size: MediaQuery.of(context).size.width * 0.12,
                                    color: editInfo ? Color(0xFF4F2263).withOpacity(0.3) : Color(0xFF4F2263)),
                                  Text('Crear cita',
                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                      color: editInfo ? Color(0xFF4F2263).withOpacity(0.3) : Color(0xFF4F2263)),),
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
                          vertical: MediaQuery.of(context).size.width * 0.03),
                        padding: EdgeInsets.only(left: editInfo ? 0:  MediaQuery.of(context).size.width * 0.03, top: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,
                        bottom: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                            border: editInfo ? null : Border.all(color: Colors.black)
                        ),
                            child: !editInfo ? RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'No. Celular',
                                    style: TextStyle(color: Color(0xFF4F2263),
                                    fontSize: 22), // Color para "No. Celular"
                                  ),
                                  TextSpan(
                                    text: phoneController.text,
                                    style: TextStyle(color: Color(0xFF4F2263).withOpacity(0.3),
                                    fontSize: 20), // Color para el texto del controlador
                                  ),
                                ],
                              ),
                            ) : TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              maxLines: maxLines,
                              controller: phoneController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                disabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4F2263), width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                //unfocus
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4F2263), width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4F2263), width: 1),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelText: 'No. Celuar',
                              ),
                              style: TextStyle(fontSize: 20),
                            ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03,
                              vertical: MediaQuery.of(context).size.width * 0.03),
                          padding: EdgeInsets.only(left: editInfo ? 0:  MediaQuery.of(context).size.width * 0.03, top: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,
                            bottom: editInfo ? 0 : MediaQuery.of(context).size.width * 0.03,),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              border: editInfo ? null : Border.all(color: Colors.black)
                          ),
                          child: !editInfo ? RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Correo electronico',
                                  style: TextStyle(color: Color(0xFF4F2263),
                                      fontSize: 22), // Color para "No. Celular"
                                ),
                                TextSpan(
                                  text: emailController.text,
                                  style: TextStyle(color: Color(0xFF4F2263).withOpacity(0.3),
                                      fontSize: 20), // Color para el texto del controlador
                                ),
                              ],
                            ),
                          ) : TextFormField(
                            maxLines: maxLines,
                            controller: emailController,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF4F2263), width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              //unfocus
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF4F2263), width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF4F2263), width: 1),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              labelText: 'Correo electronico',
                            ),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
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
                  ElevatedButton.icon(
                    onPressed: () {
                      showDeleteConfirmationDialog(context, () {
                        deleteClient(widget.id);
                        showOverlay(
                          context,
                          const CustomToast(
                            message: 'Cliente eliminado correctamente',
                          ),
                        );
                        Navigator.of(context).pop();
                      });
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Eliminar'),
                  )
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
