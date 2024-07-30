import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../calendar/calendarSchedule.dart';
import '../../models/notificationsForAssistant.dart';
import 'package:http/http.dart' as http;

Future<List<Appointment2>> fetchAppointmentsByDate(int id, String date) async {
  const baseUrl =
      'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppointmentsByDate/';
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception('No token found');
    } else {
      final response = await http.get(
        Uri.parse('$baseUrl$id/$date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print(jsonDecode(response.body)['appointments']);
        List<dynamic> data = jsonDecode(response.body)['appointments'];
        return data.map((json) => Appointment2.fromJson(json)).toList();
      } else {
        throw Exception('Fallo al cargar appointments');
      }
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

Future<void> readNotification(int appointmentId) async {
  const baseUrl =
      'https://beauteapp-dd0175830cc2.herokuapp.com/api/appointments';
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception('No token found');
    } else {
      final response = await http.put(
        Uri.parse('$baseUrl/$appointmentId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print('Notificacion marcada como leida');
      } else {
        throw Exception('Error al marcar la notificacion como leida');
      }
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

class NotiCards extends StatefulWidget {
  final Appointment2 appointment;

  const NotiCards({super.key, required this.appointment});

  @override
  _NotiCardsState createState() => _NotiCardsState();
}

class _NotiCardsState extends State<NotiCards> {
  bool isRead = false;

  @override
  void initState() {
    super.initState();
    isRead = widget.appointment.notificationRead ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.0025),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01),
              decoration: const BoxDecoration(
                color: Color(0xFF4F2263),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '¡Cita próxima!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          setState(() async {
                            try {
                              await readNotification(widget.appointment.id!);
                              setState(() {
                                isRead = true;
                              });
                            } catch (e) {
                              print('Error: $e');
                            }
                          });
                        },
                        icon: Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width * 0.085,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.05,
                        height: MediaQuery.of(context).size.width * 0.05,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRead ? Colors.green : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              decoration: const BoxDecoration(
                color: Color(0xFFC5B6CD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Prepárate para tu cita de hoy.',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      Text(
                        widget.appointment.clientName ?? 'Desconocido',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Hora: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      Text(
                        widget.appointment.appointmentDate != null
                            ? '${widget.appointment.appointmentDate!.hour}:${widget.appointment.appointmentDate!.minute}'
                            : 'Desconocido',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
