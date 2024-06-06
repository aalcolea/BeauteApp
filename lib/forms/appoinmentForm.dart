import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calendar/calendarioScreenCita.dart';
import '../models/clientModel.dart';
import '../services/getClientsService.dart';
import '../styles/AppointmentStyles.dart';
import '../utils/PopUpTabs/appointmetSuccessfullyCreated.dart';
import '../utils/timer.dart';

class AppointmentForm extends StatefulWidget {
  final bool isDoctorLog;

  const AppointmentForm({
    super.key,
    required this.isDoctorLog,
  });

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
  FocusNode fieldClientNode = FocusNode();
  TextEditingController _drSelected = TextEditingController();
  bool _showdrChooseWidget = false;
  int day = 0;
  int month = 0;
  int year = 0;
  bool isTimerShow = false;
  bool isDocLog = false;
  bool saveNewClient = false;
  bool _showCalendar = false;
  int _optSelected = 0;
  bool drFieldDone = false;
  bool clientFieldDone = false;
  bool dateFieldDone = false;
  bool timeFieldDone = false;
  bool treatmentFieldDone = false;

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      _dateController.text = dateToAppointmentForm;
      _showCalendar = showCalendar;
    });
  }

  void _onAssignedDoctor(
      bool dr1sel,
      bool dr2sel,
      TextEditingController drSelected,
      int optSelected,
      bool showdrChooseWidget) {
    setState(() {
      _drSelected = drSelected;
      _optSelected = optSelected;
      _showdrChooseWidget = showdrChooseWidget;
    });
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
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

  @override
  void initState() {
    super.initState();
    isDocLog = widget.isDoctorLog;
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    dropdownDataManager.fetchUser();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    super.dispose();
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
        if (mounted) {
          showClienteSuccessfullyAdded(context, widget);
        }
        print('Respuesta del servidor: ${response.body}');
      } else {
        print(
            'Error al crear la cita: StatusCode: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      bottom: MediaQuery.of(context).size.width * 0.02),
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              size: MediaQuery.of(context).size.width * 0.082,
                            ),
                          ),
                          Text(
                            'Nueva cita',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.095,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4F2263),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.notifications_none_outlined,
                              size: MediaQuery.of(context).size.width * 0.11,
                              color: const Color(0xFF4F2263),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.home_outlined,
                              size: MediaQuery.of(context).size.width * 0.11,
                              color: const Color(0xFF4F2263),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Visibility(
                      visible: _showdrChooseWidget ? true : false,
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.19),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: visibleKeyboard
                          ? MediaQuery.of(context).size.height * 0.52
                          : _showdrChooseWidget
                              ? MediaQuery.of(context).size.height * 0.7
                              : MediaQuery.of(context).size.height * 0.88,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Visibility(
                              visible: isDocLog
                                  ? false
                                  : _showdrChooseWidget
                                      ? false
                                      : true,
                              child: TitleContainer(
                                child: Text(
                                  'Doctor: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            Visibility(
                              visible: isDocLog
                                  ? false
                                  : _showdrChooseWidget
                                      ? false
                                      : true,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.026),
                                child: TextFormField(
                                  controller: _drSelected,
                                  decoration: InputDecoration(
                                    hintText: 'Seleccione una opción...',
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.03),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle_outlined,
                                      size: MediaQuery.of(context).size.width *
                                          0.085,
                                      color: const Color(0xFF4F2263),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    setState(
                                      () {
                                        _showdrChooseWidget =
                                            _showdrChooseWidget ? false : true;
                                      },
                                    );
                                  },
                                  onEditingComplete: () {
                                    setState(() {
                                      drFieldDone = true;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !_showdrChooseWidget,
                              child: TitleContainer(
                                child: Text(
                                  'Cliente:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.02,
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.026),
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
                                  setState(() {
                                    _clientTextController.text = selection.name;
                                    _updateSelectedClient(selection);
                                    clientFieldDone = true;
                                    print(
                                        'ActivarFechaaaa $drFieldDone y $clientFieldDone');
                                    fieldClientNode.unfocus();
                                  });
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController
                                        fieldTextEditingController,
                                    FocusNode fieldFocusNode,
                                    VoidCallback onFieldSubmitted) {
                                  fieldClientNode = fieldFocusNode;
                                  _clientTextController =
                                      fieldTextEditingController;
                                  return FieldsToWrite(
                                    textInputAction: TextInputAction.done,
                                    readOnly: false,
                                    labelText: 'Cliente',
                                    suffixIcon:
                                        const Icon(CupertinoIcons.person),
                                    controller: fieldTextEditingController,
                                    fillColor: Colors.white,
                                    focusNode: fieldFocusNode,
                                    onChanged: (text) {
                                      _updateSelectedClient(null);
                                    },
                                    onEdComplete: () {
                                      setState(() {
                                        clientFieldDone = true;
                                        fieldFocusNode.unfocus();
                                        print(
                                            'ActivarFecha $drFieldDone y $clientFieldDone');
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            Visibility(
                              visible: isTimerShow
                                  ? true
                                  : _showCalendar
                                      ? false
                                      : true,
                              child: TitleContainer(
                                child: Text(
                                  'Fecha:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isTimerShow
                                  ? true
                                  : _showCalendar
                                      ? false
                                      : true,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.026),
                                child: FieldsToWrite(
                                  eneabled: drFieldDone && clientFieldDone
                                      ? true
                                      : false,
                                  readOnly: true,
                                  labelText: 'DD/M/AAAA',
                                  controller: _dateController,
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  onTap: () {
                                    setState(() {
                                      !_showCalendar
                                          ? _showCalendar = true
                                          : _showCalendar = false;
                                      print(_showCalendar);
                                    });
                                  },
                                  onEdComplete: () {
                                    dateFieldDone = true;
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _showCalendar
                                  ? false
                                  : isTimerShow
                                      ? false
                                      : true,
                              child: TitleContainer(
                                child: Text(
                                  'Hora:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !_showCalendar,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.026),
                                child: FieldsToWrite(
                                  eneabled: dateFieldDone ? true : false,
                                  labelText: 'HH:MM',
                                  readOnly: true,
                                  controller: _timeController,
                                  suffixIcon: const Icon(Icons.access_time),
                                  onTap: () {
                                    setState(() {
                                      if (isTimerShow == false) {
                                        isTimerShow = true;
                                      } else if (isTimerShow == true) {
                                        isTimerShow = false;
                                      }
                                    });
                                  },
                                  onEdComplete: () {
                                    timeFieldDone = true;
                                  },
                                ),
                              ),
                            ),

                            Visibility(
                              visible: !isTimerShow && !_showCalendar,
                              child: TitleContainer(
                                child: Text(
                                  'Tratamiento:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            ///
                            Visibility(
                              visible: !isTimerShow && !_showCalendar,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.026),
                                child: FieldsToWrite(
                                  eneabled: timeFieldDone ? true : false,
                                  labelText: 'Tratamiento',
                                  readOnly: false,
                                  controller: treatmentController,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !_showCalendar || isTimerShow,
                              child: Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    value: saveNewClient,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        saveNewClient = value ?? false;
                                      });
                                    },
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return const Color(0xFF4F2263);
                                      } else {
                                        return Colors.transparent;
                                      }
                                    }),
                                  ),
                                  Text(
                                    'Agregar nuevo cliente',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.045,
                                      color: const Color(0xFF4F2263),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Visibility(
                              visible:
                                  !isTimerShow && !_showCalendar ? true : false,
                              child: ElevatedButton(
                                onPressed: treatmentFieldDone
                                    ? submitAppointment
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.white,
                                  splashFactory: InkRipple.splashFactory,
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.0225,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: BorderSide(
                                        color: treatmentFieldDone
                                            ? const Color(0xFF4F2263)
                                            : const Color(0xFF4F2263)
                                                .withOpacity(0.3),
                                        width: 2),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Crear cita',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.06,
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
              ],
            ),

            ///timer
            if (isTimerShow)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black54.withOpacity(0.27),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.11,
              child: Visibility(
                visible: isTimerShow,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.365,
                      ),
                      TitleContainer(
                        child: Text(
                          'Hora:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FieldsPading(
                        child: FieldsToWrite(
                          fillColor: Colors.white,
                          labelText: 'HH:MM',
                          readOnly: true,
                          controller: _timeController,
                          suffixIcon: const Icon(Icons.access_time),
                          onTap: () {
                            setState(() {
                              if (isTimerShow == false) {
                                isTimerShow = true;
                              } else if (isTimerShow == true) {
                                isTimerShow = false;
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                        ),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.025,
                          left: MediaQuery.of(context).size.width * 0.038,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54, width: 0.5),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TimerFly(onTimeChoose: _onTimeChoose),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///calendario
            if (_showCalendar)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black54.withOpacity(0.27),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.11,
              child: Visibility(
                visible: _showCalendar,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      TitleContainer(
                        child: Text(
                          'Fecha:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.02,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.026),
                        child: FieldsToWrite(
                          fillColor: Colors.white,
                          readOnly: true,
                          labelText: 'DD/M/AAAA',
                          controller: _dateController,
                          suffixIcon: const Icon(Icons.calendar_today),
                          onTap: () {
                            setState(() {
                              !_showCalendar
                                  ? _showCalendar = true
                                  : _showCalendar = false;
                            });
                          },
                        ),
                      ),
                      CalendarContainer(
                        child: CalendarioCita(
                            onDayToAppointFormSelected:
                                _onDateToAppointmentForm),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///widgetChooseDr
            if (_showdrChooseWidget)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black54.withOpacity(0.27),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.11,
              child: Visibility(
                visible: _showdrChooseWidget,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                    children: [
                      TitleContainer(
                        child: Text(
                          'Doctor: ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.02,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.026),
                        child: TextFormField(
                          controller: _drSelected,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Seleccione una opción...',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
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
                                _showdrChooseWidget =
                                    _showdrChooseWidget ? false : true;
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.025),
                        child: DoctorsMenu(
                            onAssignedDoctor: _onAssignedDoctor,
                            optSelectedToRecieve: _optSelected),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
