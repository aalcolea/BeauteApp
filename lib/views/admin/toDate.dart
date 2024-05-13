import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/appointmentModel.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  late Future<List<Appointment>> appointments;

  @override
  void initState() {
    super.initState();
    appointments = fetchAppointments();
  }

  Future<List<Appointment>> fetchAppointments() async {
    final response = await http.get(Uri.parse(
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinments'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('appointments') && data['appointments'] != null) {
        List<dynamic> appointmentsJson = data['appointments'];
        return appointmentsJson
            .map((json) => Appointment.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            children: [
              Text(
                "Hola Dr Sexo",
                style: TextStyle(fontSize: 40),
              )
            ],
          ),
          Container(
            height: 70, // Ajusta la altura si es necesario
            color: Colors.transparent, // Fondo de toda la barra
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                DateTime date = selectedDate.add(Duration(days: index - 2));
                bool isSelected = selectedDate.day == date.day &&
                    selectedDate.month == date.month &&
                    selectedDate.year == date.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                    child: Container(
                      width: 85,
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(
                            color: Colors.red.withOpacity(1),
                            offset: Offset(0, 2), // Sombra abajo
                            blurRadius: 10,
                          )]
                              : [BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, -2), // Sombra arriba
                            blurRadius: 4,
                          )]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            DateFormat('EEE', 'es_ES').format(date).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.deepPurple : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: isSelected ? 18 : 14, // Tamaño más grande si está seleccionado
                            ),
                          ),
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              color: isSelected ? Colors.deepPurple : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: isSelected ? 18 : 14, // Tamaño más grande si está seleccionado
                            ),
                          ),
                        ],
                      ),
                    )
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: FutureBuilder<List<Appointment>>(
                future: appointments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    List<Appointment> filteredAppointments = snapshot.data!
                        .where((a) =>
                            a.appointmentDate != null &&
                            a.appointmentDate!.year == selectedDate.year &&
                            a.appointmentDate!.month == selectedDate.month &&
                            a.appointmentDate!.day == selectedDate.day)
                        .toList();

                    return ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        Appointment appointment = filteredAppointments[index];
                        String time = (appointment.appointmentDate != null)
                            ? '${appointment.appointmentDate!.hour}:${appointment.appointmentDate!.minute}'
                            : 'Unknown Time';
                        String clientName =
                            appointment.clientName ?? 'Unknown Client';
                        String treatmentType =
                            appointment.treatmentType ?? 'No Treatment';

                        return ListTile(
                          title: Text(clientName),
                          subtitle: Text(treatmentType),
                          trailing: Text(time),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
