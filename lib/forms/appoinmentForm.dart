import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clientModel.dart';
import '../services/getClientsService.dart';
import '../utils/timer.dart';

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final DropdownDataManager dropdownDataManager = DropdownDataManager();
  Client? _selectedClient;
  var _clientTextController = TextEditingController();
  final _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  final treatmentController = TextEditingController();
  final drSelected = TextEditingController();
  bool drChooseWidget = false;
  int day = 0;
  int month = 0;
  int year = 0;
  bool dr1sel = false;
  bool dr2sel = false;
  bool isTimerShow = false;

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
        print("MODAL");
        print(visibleKeyboard);
      });
    });
  }

  void _onTimeChoose(bool _isTimerShow, TextEditingController selectedTime) {
    setState(() {
      isTimerShow = _isTimerShow;
      _timeController = selectedTime;
    });
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    dropdownDataManager.fetchUser();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  void _updateSelectedClient(Client? client) {
    if (client != null) {
      setState(() {
        _selectedClient = client;
      });
    } else {
      setState(() {
        _selectedClient = Client(
            id: 0, name: _clientTextController.text, email: '', number: 0);
      });
    }
  }

/*considerar mandar funcion appoinment a otro widget*/
  Future<void> submitAppointment() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    if (token == null) {
      print("No token found");
      return;
    }

    String url =
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/createAppoinment';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'client_id': _selectedClient?.id.toString(),
          'date': _dateController.text,
          'time': _timeController.text,
          'treatment': treatmentController.text,
          'name': _clientTextController.text,
        }),
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    color: Colors.black54.withOpacity(0.3),
                  ),
                ),
                Center(
                  child: AlertDialog(
                    backgroundColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    content: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.095),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(blurRadius: 3.5, offset: Offset(0, 0))
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '¡Cita creada!',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.085,
                              color: const Color(0xFF4F2263),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.035,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.03),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Inicio',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  color: const Color(0xFF4F2263),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        print('Respuesta del servidor: ${response.body}');
      } else {
        print(
            'Error al crear la cita: StatusCode: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos: $e');
    }
  }

/*termina funcion appointmentn*/
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F2263),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    } else {
      setState(() {
        _dateController.text = 'Seleccione fecha';
      });
    }
  }

  /*Future<void> _saveTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        final Widget mediaQueryWrapper = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
        final themedPicker = Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F2263),
              onPrimary: Colors.white,
              onPrimaryContainer: Colors.white,
              tertiary: Color(0xFF4F2263),
              onTertiaryContainer: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: mediaQueryWrapper,
        );
        return themedPicker;
      },
    );

    if (picked != null) {
      DateTime now = DateTime.now();
      DateTime fullTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      String formattedTime = DateFormat('HH:mm:ss').format(fullTime);
      setState(() {
        _timeController.text = formattedTime;
      });
    } else {
      setState(() {
        _timeController.text = 'Seleccione Hora';
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Nueva cita',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F2263),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          size: 40,
                          color: Color(0xFF4F2263),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.home_outlined,
                          size: 40,
                          color: Color(0xFF4F2263),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: visibleKeyboard
                  ? MediaQuery.of(context).size.height * 0.52
                  : null,
              color: Colors.white,
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F2263),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Doctor: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10, bottom: 4),
                          child: TextFormField(
                            controller: drSelected,
                            decoration: InputDecoration(
                              hintText: 'Seleccione una opción...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                size: MediaQuery.of(context).size.width * 0.085,
                                color: const Color(0xFF4F2263),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              setState(
                                () {
                                  drChooseWidget =
                                      drChooseWidget ? false : true;
                                },
                              );
                            },
                          ),
                        ),

                        ///
                        Visibility(
                          visible: drChooseWidget,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black54, width: 0.5),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        dr1sel = true;
                                        dr2sel = false;
                                        drSelected.text = 'Doctor1';
                                        drChooseWidget = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: dr1sel
                                              ? const Color(0xFF4F2263)
                                              : Colors.white,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10))),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            child: Icon(
                                              CupertinoIcons
                                                  .person_crop_circle_fill,
                                              color: dr1sel
                                                  ? Colors.white
                                                  : const Color(0xFF4F2263),
                                            ),
                                          ),
                                          Text(
                                            'Doctor 1',
                                            style: TextStyle(
                                                color: dr1sel
                                                    ? Colors.white
                                                    : const Color(0xFF4F2263),
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.054),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),

                                  ///
                                  Container(
                                    color: Colors.black54,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.0009,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        dr2sel = true;
                                        dr1sel = false;
                                        drSelected.text = 'Doctor2';
                                        drChooseWidget = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: dr2sel
                                              ? const Color(0xFF4F2263)
                                              : Colors.white,
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight:
                                                  Radius.circular(10))),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            child: Icon(
                                              CupertinoIcons
                                                  .person_crop_circle_fill,
                                              color: dr2sel
                                                  ? Colors.white
                                                  : const Color(0xFF4F2263),
                                            ),
                                          ),
                                          Text(
                                            'Doctor 2',
                                            style: TextStyle(
                                                color: dr2sel
                                                    ? Colors.white
                                                    : const Color(0xFF4F2263),
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.054),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !drChooseWidget,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F2263),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Cliente:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 8),
                          child: Autocomplete<Client>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<Client>.empty();
                              }
                              return dropdownDataManager
                                  .getSuggestions(textEditingValue.text);
                            },
                            displayStringForOption: (Client option) =>
                                option.name,
                            onSelected: (Client selection) {
                              _clientTextController.text = selection.name;
                              _updateSelectedClient(selection);
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController
                                    fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              _clientTextController =
                                  fieldTextEditingController;
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Cliente',
                                  border: OutlineInputBorder(),
                                  //filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (text) {
                                  _updateSelectedClient(
                                      null); // Actualiza con cliente manual si es necesario
                                },
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: !isTimerShow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F2263),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Fecha:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !isTimerShow,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'DD/M/AAAA',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F2263),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Hora:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: TextFormField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              labelText: 'HH:MM',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () {
                              setState(() {
                                if (isTimerShow == false) {
                                  isTimerShow = true;
                                } else if (isTimerShow == true) {
                                  isTimerShow = false;
                                }
                              });

                              //_selectTime(context);
                            },
                          ),
                        ),

                        ///timer
                        Visibility(
                          visible: isTimerShow,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black54, width: 0.5),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TimerFly(onTimeChoose: _onTimeChoose),
                          ),
                        ),
                        Visibility(
                          visible: !isTimerShow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F2263),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              'Tratamiento:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !isTimerShow,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: TextFormField(
                              controller: treatmentController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Describa el tratamiento...',
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !isTimerShow,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ElevatedButton(
                              onPressed: submitAppointment,
                              style: ElevatedButton.styleFrom(
                                surfaceTintColor: Colors.white,
                                splashFactory: InkRipple.splashFactory,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.025,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: const BorderSide(
                                      color: Color(0xFF4F2263), width: 2),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Crear cita',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
