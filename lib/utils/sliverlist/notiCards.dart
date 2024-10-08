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
        Uri.parse(baseUrl + '$id' + '/' + '$date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(baseUrl + '$id');
      print(baseUrl + '$id' + '/' + '$date');
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

class NotiCards extends StatefulWidget {
  final Appointment2 appointment;

  const NotiCards({super.key, required this.appointment});

  @override
  _NotiCardsState createState() => _NotiCardsState();
}

class _NotiCardsState extends State<NotiCards> {
  late bool isRead;

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
          setState(() {});
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

  Future<void> unReadNotification(int appointmentId) async {
    const baseUrl =
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/appointments';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      } else {
        final response = await http.put(
          Uri.parse('$baseUrl/$appointmentId/unRead'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          setState(() {});
          print('Notificacion marcada como desleida');
        } else {
          throw Exception('Error al marcar la notificacion como desleida');
        }
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    isRead = widget.appointment.notificationRead!;
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
              decoration: BoxDecoration(
                color:
                    !isRead ? const Color(0xFF4F2263) : const Color(0xFFC5B6CD),
                borderRadius: const BorderRadius.only(
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
                      color: !isRead ? Colors.white : Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: isRead == false
                            ? () async {
                                try {
                                  await readNotification(
                                      widget.appointment.id!);
                                  setState(() {
                                    isRead = true;
                                  });
                                } catch (e) {
                                  print('Error: $e');
                                }
                              }
                            : () async {
                                try {
                                  await unReadNotification(
                                      widget.appointment.id!);
                                  setState(() {
                                    isRead = false;
                                  });
                                } catch (e) {
                                  print('Error: $e');
                                }
                              },
                        icon: Icon(
                          !isRead
                              ? CupertinoIcons.mail_solid
                              : Icons.markunread_mailbox_outlined,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width * 0.07,
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
              decoration: BoxDecoration(
                color: !isRead
                    ? const Color(0xFFC5B6CD)
                    : Color(0xFFC5B6CD).withOpacity(0.3),
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
                          color: !isRead ? Colors.black : Colors.white,
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
                          color: !isRead ? Colors.black : Colors.white,
                        ),
                      ),
                      Text(
                        widget.appointment.clientName ?? 'Desconocido',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: !isRead ? Colors.black : Colors.white,
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
                          color: !isRead ? Colors.black : Colors.white,
                        ),
                      ),
                      Text(
                        widget.appointment.appointmentDate != null
                            ? '${widget.appointment.appointmentDate!.hour}:${widget.appointment.appointmentDate!.minute}'
                            : 'Desconocido',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: !isRead ? Colors.black : Colors.white,
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
