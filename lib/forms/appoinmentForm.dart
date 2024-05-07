import 'package:flutter/material.dart';

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  int day = 0;
  int month = 0;
  int year = 0;

  String? _selectedClient;

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
        //_dateController.text = _picked.toString().split(" ")[0];
        day = _picked.day;
        month = _picked.month;
        year = _picked.year;
        _dateController.text = "$day/$month/$year";
        print('Día seleccionado: $day');
        print('Mes seleccionado: $month');
        print('Año seleccionado: $year');
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
              primary: Color(0xFFC31B36),
              //mod el color de la bolita de seleccionar
              onPrimary: Colors.white,
              //mod el color del # en la bolita de seleccionar
              onPrimaryContainer: Colors.white,
              //mod el color del #  en el container seleccionado
              tertiary: Color(0xFFC31B36),
              //mod el color de la caja de AM o PM seleccionada
              onTertiaryContainer: Colors.white,
              // mod el color de la letra de AM o PM seleccionada
              surface: Colors.white,
              //mod el color del fondo del reloj
              onSurface:
                  Colors.black, // Color del resto #s o letras en el widget
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
    return Form(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
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
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 1,
                      height: 45,
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nueva cita',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: DropdownButtonFormField(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: <String>['Cliente 1', 'Cliente 2', 'Cliente 3']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClient = newValue;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tratamiento',
                        border: OutlineInputBorder(),
                        hintText: 'Describa el tratamiento...',
                      ),
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(),
                      child: const Text('Crear cita'),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
