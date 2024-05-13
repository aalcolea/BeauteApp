import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/getClientsService.dart';
import '../models/clientModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final DropdownDataManager dropdownDataManager = DropdownDataManager();
  Client? _selectedClient;
  var _clientTextController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final treatmentController = TextEditingController();
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
              primary: Color(0xFFC31B36),
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

  Future<void> _selectTime(BuildContext context) async {
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
      DateTime fullTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      String formattedTime = DateFormat('HH:mm:ss').format(fullTime);
      setState(() {
        _timeController.text = formattedTime;
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
      body: Form(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 28),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    child: Autocomplete<Client>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<Client>.empty();
                        }
                        return dropdownDataManager
                            .getSuggestions(textEditingValue.text);
                      },
                      displayStringForOption: (Client option) => option.name,
                      onSelected: (Client selection) {
                        _clientTextController.text = selection.name;
                        _updateSelectedClient(selection);
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        _clientTextController = fieldTextEditingController;
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                        _selectTime(context);
                      },
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                        surfaceTintColor: Colors.white,
                        splashFactory: InkRipple.splashFactory,
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.025,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: const BorderSide(
                              color: Color(0xFF4F2263), width: 2),
                        ),
                        /*fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.45,
                          MediaQuery.of(context).size.height * 0.06,
                        ),*/
                        backgroundColor: Colors.white,
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
