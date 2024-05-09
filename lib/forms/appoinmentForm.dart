import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/getClientsService.dart';
import '../models/clientModel.dart';
import 'package:http/http.dart' as http;

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final DropdownDataManager dropdownDataManager = DropdownDataManager();
  Client? _selectedClient;
  var _clientTextController = TextEditingController();
  final  _dateController = TextEditingController();
  final  _timeController = TextEditingController();
  final  treatmentController = TextEditingController();
  int day = 0;
  int month = 0;
  int year = 0;
  @override
  void initState() {
    super.initState();
    dropdownDataManager.fetchUser();
  }
  void _updateSelectedClient(Client? client) {
    if (client != null) {
      setState(() {
        _selectedClient = client;
      });
    } else {
      setState(() {
        _selectedClient = Client(id: 0, name: _clientTextController.text, email: '', number: 0);
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

    String url = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/createAppoinment';

    print('Enviando los siguientes datos:');
    print('Client ID: ${_selectedClient?.id}');
    print('Client name: ${_clientTextController?.text}');
    print('Date: ${_dateController.text}');
    print('Time: ${_timeController.text}');
    print('Treatment: ${treatmentController.text}');

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
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Éxito'),
              content: Text('Cita creada correctamente'),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        print('Respuesta del servidor: ${response.body}');
      } else {
        print('Error al crear la cita: StatusCode: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos: $e');
    }
  }

/*termina funcion appointmentn*/
  Future<void> _selectDate(BuildContext context) async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC31B36),
            ),
          ),
          child: child!,
        );
      },
    );

    if (_picked != null) {
      setState(() {
        day = _picked.day;
        month = _picked.month;
        year = _picked.year;
        _dateController.text = "$day/$month/$year";
      });
    } else {
      setState(() {
        _dateController.text = 'Seleccione fecha';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    int _12hrsformat = 0;
    TimeOfDay? _picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        final Widget mediaQueryWrapper = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
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

        if (Localizations.localeOf(context).languageCode == 'es') {
          return Localizations.override(
            context: context,
            locale: const Locale('es', 'US'),
            child: themedPicker,
          );
        }

        return themedPicker;
      },
    );

    if (_picked != null) {
      String period = _picked.period.toString().split('.').last;
      if (_picked.hour > 12) {
        _12hrsformat = _picked.hour - 12;
      } else if (_picked.hour <= 12) {
        _12hrsformat = _picked.hour;
      }
      setState(() {
        _timeController.text = '$_12hrsformat:${_picked.minute} $period';
      });
    } else {
      setState(() {
        _timeController.text = 'Seleccione Hora';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment'),
      ),
      body: Form(
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 1,
                      height: 45,
                      color: const Color(0xFF4F2263),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              alignment: Alignment.center,
                              child: const Text(
                                'Nueva cita',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: const BorderSide(
                                      width: 0.1, color: Colors.black),
                                ),
                                backgroundColor:
                                    Colors.black.withOpacity(0.15)),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 25,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F2263),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Cliente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Autocomplete<Client>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<Client>.empty();
                        }
                        return dropdownDataManager.getSuggestions(textEditingValue.text);
                      },
                      displayStringForOption: (Client option) => option.name,
                      onSelected: (Client selection) {
                        _clientTextController.text = selection.name;
                        _updateSelectedClient(selection);
                      },
                      fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted
                          ) {
                        _clientTextController = fieldTextEditingController;
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Cliente',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (text) {
                            _updateSelectedClient(null); // Actualiza con cliente manual si es necesario
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F2263),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Fecha',
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F2263),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Hora',
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
                        _selectTime(context);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F2263),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tratamiento',
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
                      controller: treatmentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describa el tratamiento...',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                      onPressed: submitAppointment,
                      style: ElevatedButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Color(0xFF4F2263), width: 2),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.45,
                          MediaQuery.of(context).size.height * 0.06,
                        ),
                        backgroundColor: const Color(0xFFEFE6F7),
                      ),
                      child: const Text(
                        'Crear cita',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
