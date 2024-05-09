import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/getClientsService.dart';
import '../models/clientModel.dart';

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final DropdownDataManager dropdownDataManager = DropdownDataManager();
  Client? _selectedClient;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  int day = 0;
  int month = 0;
  int year = 0;
  @override
  void initState() {
    super.initState();
    dropdownDataManager.fetchUser();
  }

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
                        setState(() {
                          _selectedClient = selection;
                          print('You just selected ${_selectedClient?.name}');
                        });
                      },
                      fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted
                          ) {
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Cliente',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describa el tratamiento...',
                      ),
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                              color: Color(0xFF4F2263), width: 2),
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
