import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../calendar/calendarSchedule.dart';
import 'package:http/http.dart' as http;
import '../../themes/colors.dart';

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
  final Function(double) onCalculateHeightCard;

  const NotiCards({super.key, required this.appointment, required this.onCalculateHeightCard});

  @override
  _NotiCardsState createState() => _NotiCardsState();
}

class _NotiCardsState extends State<NotiCards> {
  late bool isRead;
  final _keyNoti = GlobalKey<FormState>();
  String hour = '';

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

  String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  bool isToday(DateTime appointmentDate) {
    DateTime now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    isRead = widget.appointment.notificationRead!;
    hour = formatTime(widget.appointment.appointmentDate!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCalculateHeightCard(_keyNoti.currentContext!.size!.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: _keyNoti,
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
                  color: !isRead
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.3),
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
                    const Spacer(),
                    Visibility(
                      visible: true,
                      child: Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.width * 0.01
                      ),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white
                      ),
                      child: Text( widget.appointment.doctorId == 1 ? 'Doctor 1' : 'Doctor 2',
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: isRead ? Colors.black.withOpacity(0.3) : Colors.black),),
                    ),),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: isRead == false
                              ? () async {
                                  try {
                                    await readNotification(widget.appointment.id!);
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
                            isRead ? Icons.mark_email_read_outlined : Icons.markunread_mailbox_sharp,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.07,
                          ))
                      ])

                    ])),
            Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                decoration: BoxDecoration(
                  color: !isRead
                      ? AppColors.primaryColor.withOpacity(0.3)
                      : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
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
                            isToday(widget.appointment.appointmentDate!) ? 'Prepárate para tu cita de hoy.' : 'Prepárate para tu cita de mañana.',
                          style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: !isRead ? Colors.black : Colors.white.withOpacity(0.75),
                        ))
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Paciente: ',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: !isRead
                                ? Colors.black
                                : Colors.white.withOpacity(0.75),
                          ),
                        ),
                        Text(
                          widget.appointment.clientName ?? 'Desconocido',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: !isRead
                                ? Colors.black
                                : Colors.white.withOpacity(0.75),
                        ))
                  ]),
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
                              ? hour
                              : 'Desconocido',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: !isRead ? Colors.black : Colors.white,
                        ))
                  ])
                ]))
          ]))
    ]);
  }
}
