import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/PopUpTabs/clientSuccessfullyAdded.dart';

class NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Verificar si el nuevo texto comienza con un espacio
    if (newValue.text.startsWith(' ')) {
      // Si comienza con un espacio, no permitimos la actualización y devolvemos el valor anterior
      return oldValue;
    }

    // Verificar si el texto anterior termina con un espacio y el nuevo texto no
    // Esto indica que el usuario está intentando eliminar un espacio final
    if (oldValue.text.endsWith(' ') &&
        !newValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        oldValue.text.length > 1) {
      // Permitimos la eliminación del espacio final
      return newValue;
    }
    return FilteringTextInputFormatter.allow(
      RegExp(r'[a-zA-ZñÑ0-9\s]'), // Expresión regular que permite letras y espacios
    ).formatEditUpdate(oldValue, newValue);
  }
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // No permitir que el texto comience con un espacio
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }

    // Permitir borrar un espacio intermedio
    if (oldValue.text.endsWith(' ') &&
        !newValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        oldValue.text.length > 1) {
      return newValue;
    }

    // Aplicar filtros de caracteres permitidos y denegados
    String filteredText = newValue.text;

    // Filtrar los caracteres permitidos
    filteredText = RegExp(r'[a-zA-Z0-9._%-@]')
        .allMatches(filteredText)
        .map((match) => match.group(0))
        .join();

    // Negar los caracteres no permitidos
    filteredText = filteredText.replaceAll(RegExp(r'[<>?:;/+%]'), '');

    return TextEditingValue(
      text: filteredText,
      selection: newValue.selection.copyWith(
        baseOffset: filteredText.length,
        extentOffset: filteredText.length,
      ),
    );
  }
}

class ClientForm extends StatefulWidget {
  final void Function(
    bool,
  ) onHideBtnsBottom;
  final void Function(
    int,
    bool,
  ) onFinishedAddClient;

  const ClientForm(
      {super.key,
      required this.onHideBtnsBottom,
      required this.onFinishedAddClient});

  @override
  ClientFormState createState() => ClientFormState();
}

class ClientFormState extends State<ClientForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool hideBtnsBottom = false;
  late FocusNode focusNodeClient;
  late FocusNode focusNodeCel;
  late FocusNode focusNodeEmail;
  bool errorInit = false;
  double? screenWidth;
  double? screenHeight;

  //final RegExp letterRegex = RegExp(r'^[a-zA-Z]+$');

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
        !visibleKeyboard ? widget.onHideBtnsBottom(false) : null;
      });
    });
  }

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

      print(response.statusCode);

      if (response.statusCode == 201) {
        if (mounted) {
          hideKeyBoard();
          showClienteSuccessfullyAdded(context, widget, () {
            widget.onFinishedAddClient(1, false);
          });
        }
      } else {
        print('Error al crear cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar datos: $e');
    }
  }

  void changeFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void initState() {
    hideKeyBoard();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    focusNodeClient = FocusNode();
    focusNodeCel = FocusNode();
    focusNodeEmail = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNodeClient.dispose();
    focusNodeCel.dispose();
    focusNodeEmail.dispose();
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: visibleKeyboard
                ? MediaQuery.of(context).size.height * 0.47
                : null,
            child: SingleChildScrollView(
              physics:  const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenWidth! < 370
                            ? MediaQuery.of(context).size.width * 0.01
                            : MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.02),
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0,
                        vertical: MediaQuery.of(context).size.width * 0.025),
                    alignment: Alignment.centerLeft,
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.045,
                        top: 0),
                    child: TextFormField(
                      inputFormatters: [
                        NameInputFormatter(),
                      ],
                      focusNode: focusNodeClient,
                      controller: _nameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth! < 370
                                ? MediaQuery.of(context).size.width * 0.02
                                : MediaQuery.of(context).size.width * 0.0325,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                        hintText: 'Nombre completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onTap: () {
                        !visibleKeyboard
                            ? widget.onHideBtnsBottom(!visibleKeyboard)
                            : null;
                      },
                      onEditingComplete: () =>
                          changeFocus(context, focusNodeClient, focusNodeCel),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenWidth! < 370
                            ? MediaQuery.of(context).size.width * 0.01
                            : MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.02),
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0),
                    alignment: Alignment.centerLeft,
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.045,
                        top: MediaQuery.of(context).size.width * 0.0225),
                    child: TextFormField(
                      focusNode: focusNodeCel,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],
                      controller: _numberController,
                      decoration: InputDecoration(
                        errorText: errorInit
                            ? 'El número debe ser de 10 dígitos'
                            : null,
                        hintText: 'No. Celular',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth! < 370
                                ? MediaQuery.of(context).size.width * 0.02
                                : MediaQuery.of(context).size.width * 0.0325,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onTap: () {
                        !visibleKeyboard
                            ? widget.onHideBtnsBottom(!visibleKeyboard)
                            : null;
                      },
                      onEditingComplete: () =>
                          changeFocus(context, focusNodeCel, focusNodeEmail),
                      onChanged: (celnumber) {
                        setState(() {
                          if (celnumber.length != 10) {
                            errorInit = true;
                          } else {
                            errorInit = false;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenWidth! < 370
                            ? MediaQuery.of(context).size.width * 0.01
                            : MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.02),
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0),
                    alignment: Alignment.centerLeft,
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
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.045,
                        top: MediaQuery.of(context).size.width * 0.0225),
                    child: TextFormField(
                      inputFormatters: [
                        EmailInputFormatter(),
                      ],
                      focusNode: focusNodeEmail,
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth! < 370
                                ? MediaQuery.of(context).size.width * 0.02
                                : MediaQuery.of(context).size.width * 0.0325,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: 'Correo electrónico',
                      ),
                      onTap: () {
                        !visibleKeyboard
                            ? widget.onHideBtnsBottom(!visibleKeyboard)
                            : null;
                      },
                      onEditingComplete: () => focusNodeEmail.unfocus(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: !visibleKeyboard
                            ? MediaQuery.of(context).size.width * 0.2
                            : MediaQuery.of(context).size.width * 0.0),
                    child: ElevatedButton(
                      onPressed: errorInit
                          ? null
                          : () {
                              createClient();
                            },
                      style: ElevatedButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.01,
                            vertical:
                                MediaQuery.of(context).size.width * 0.0112),
                        surfaceTintColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                              color: Color(0xFF4F2263), width: 2),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.6,
                          MediaQuery.of(context).size.height * 0.075,
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Agregar Cliente',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.055,
                          color: const Color(0xFF4F2263),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
