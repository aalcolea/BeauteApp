import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/appointmentModel.dart';

class AppointmentScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AppointmentScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late Future<List<Appointment>> appointments;

  late DateTime selectedDate2 = widget.selectedDate;
  @override
  void initState() {
    super.initState();
    appointments = fetchAppointments(widget.selectedDate);
  }
  Future<List<Appointment>> fetchAppointments(DateTime selectedDate) async {
    final response = await http.get(Uri.parse(
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinments'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('appointments') && data['appointments'] != null) {
        List<dynamic> appointmentsJson = data['appointments'];
        List<Appointment> allAppointments = appointmentsJson
            .map((json) => Appointment.fromJson(json))
            .toList();
        return allAppointments.where((appointment) =>
        appointment.appointmentDate != null &&
            appointment.appointmentDate!.year == selectedDate.year &&
            appointment.appointmentDate!.month == selectedDate.month &&
            appointment.appointmentDate!.day == selectedDate.day
        ).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.035),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Column(
        children: <Widget>[
          Container(
            height: 70,
            color: Colors.transparent,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                DateTime date = widget.selectedDate.add(Duration(days: index - 2));
                bool isSelected = selectedDate2.day == date.day &&
                    selectedDate2.month == date.month &&
                    selectedDate2.year == date.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate2 = date;
                      appointments = fetchAppointments(date);
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
                          ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(1),
                          offset: Offset(0, 2), // Sombra abajo
                          blurRadius: 10,
                        )
                      ]
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, -2), // Sombra arriba
                          blurRadius: 4,
                        )
                      ],
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
                  ),
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    List<Appointment> filteredAppointments = snapshot.data!
                        .where((a) =>
                            a.appointmentDate != null &&
                            a.appointmentDate!.year == widget.selectedDate.year &&
                            a.appointmentDate!.month == widget.selectedDate.month &&
                            a.appointmentDate!.day == widget.selectedDate.day)
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

                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 2),
                              color: Colors.white),
                          child: Row(
                            children: [
                              Container(
                                color: Colors.red,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ListTile(
                                  title: Text(
                                    clientName,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                  ),
                                  subtitle: Text(
                                    treatmentType,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: const Color(0xFF4F2263),
                                        width: 1.5),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.08),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
