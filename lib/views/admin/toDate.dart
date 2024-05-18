import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../forms/appoinmentForm.dart';
import '../../models/appointmentModel.dart';
import 'modifyAppointment.dart';

class AppointmentScreen extends StatefulWidget {
  final void Function(
    bool,
  ) reachTop;
  final DateTime selectedDate;

  const AppointmentScreen(
      {Key? key, required this.selectedDate, required this.reachTop})
      : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool isDocLog = false;
  late Future<List<Appointment>> appointments;
  bool modalReachTop = true;
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
        List<Appointment> allAppointments =
            appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
        return allAppointments
            .where((appointment) =>
                appointment.appointmentDate != null &&
                appointment.appointmentDate!.year == selectedDate.year &&
                appointment.appointmentDate!.month == selectedDate.month &&
                appointment.appointmentDate!.day == selectedDate.day)
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
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.035),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Column(
        children: <Widget>[
          ///estos son los cuadrados donde salen los dias
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                DateTime date =
                    widget.selectedDate.add(Duration(days: index - 2));
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

                  /// este es el cotainer de cada uno de los dias
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      //color: isSelected ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      boxShadow: !isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 5.0,
                                offset: Offset(0,
                                    MediaQuery.of(context).size.width * 0.003),
                              ),
                              BoxShadow(
                                blurRadius: 25.0,
                                color: Colors.white,
                                offset: Offset(0,
                                    MediaQuery.of(context).size.width * 0.04),
                              ),
                            ]
                          : [
                              ///sombra del que esta seleccionado
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 5.0,
                                offset: Offset(0,
                                    MediaQuery.of(context).size.width * 0.002),
                              ),
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(0,
                                    MediaQuery.of(context).size.width * -0.04),
                              ),
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
                            fontSize: isSelected
                                ? MediaQuery.of(context).size.width * 0.057
                                : MediaQuery.of(context).size.width * 0.035,
                          ),
                        ),
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            color: isSelected ? Colors.deepPurple : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: isSelected
                                ? MediaQuery.of(context).size.width * 0.051
                                : MediaQuery.of(context).size.width *
                                    0.033, // Tamaño más grande si está seleccionado
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            //espacio entre las citas y la fila de dias
            height: MediaQuery.of(context).size.width * 0.08,
          ),
          Expanded(
            ///este container es de lo que esta debajo de los dias
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
                            a.appointmentDate!.year ==
                                widget.selectedDate.year &&
                            a.appointmentDate!.month ==
                                widget.selectedDate.month &&
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

                        ///este container agrupa al texto y a la hora
                        return InkWell(
                          onTap: () {
                            print('tapped on $clientName');
                            setState(() {
                              widget.reachTop(modalReachTop);
                            });
                            showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    contentPadding: EdgeInsets.zero,
                                    content: ModifyAppointment(),
                                  );
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0,
                              left: MediaQuery.of(context).size.width * 0.02,
                              right: MediaQuery.of(context).size.width * 0.02,
                              bottom: MediaQuery.of(context).size.width * 0.035,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: const Color(0xFF4F2263), width: 1.5),
                                color: Colors.white,
                                boxShadow: [
                                  const BoxShadow(
                                    blurRadius: 3,
                                    offset: Offset(0, 0),
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(
                                        0,
                                        MediaQuery.of(context).size.width *
                                            -0.02),
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(
                                        MediaQuery.of(context).size.width *
                                            -0.02,
                                        0),
                                  ),
                                ]),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: ListTile(
                                    title: Text(
                                      clientName,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05),
                                    ),
                                    subtitle: Text(
                                      treatmentType,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  ///este container es de la hora
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4F2263),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: const Color(0xFF4F2263),
                                          width: 1.5),
                                    ),
                                    margin: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.06),
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F2263),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06),
              surfaceTintColor: const Color(0xFF4F2263),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Color(0xFF4F2263), width: 2),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentForm(isDoctorLog: isDocLog),
                ),
              );
              //Navigator.pushNamed(context, '/citaScreen');
            },
            child: Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.09,
            ),
          ),
        ],
      ),
    );
  }
}
