import 'package:beaute_app/models/notificationsForAssistant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../calendar/calendarSchedule.dart';
import '../../utils/paintToNotifications.dart';
import '../../utils/sliverlist/notiCards.dart';

class NotificationsScreen extends StatefulWidget {
  final int doctorId;

  const NotificationsScreen({super.key, required this.doctorId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  double? screenWidth;
  double? screenHeight;

  late Future<List<Appointment2>> _todayAppointments;
  late Future<List<Appointment2>> _yesterdayAppointments;
  late Future<List<Appointment2>> _dayBeforeYesterdayAppointments;

  @override
  void initState() {
    super.initState();
    _todayAppointments = fetchAppointmentsByDate(widget.doctorId, DateTime.now().toString());
    _yesterdayAppointments = fetchAppointmentsByDate(widget.doctorId, DateTime.now().subtract(Duration(days: 1)).toString());
    _dayBeforeYesterdayAppointments = fetchAppointmentsByDate(widget.doctorId, DateTime.now().subtract(Duration(days: 2)).toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      width: MediaQuery.of(context).size.width,
      height: null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: screenWidth! < 370.00
                      ? MediaQuery.of(context).size.height * 0.027
                      : MediaQuery.of(context).size.height * 0.0255,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF4F2263),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth! < 370.00
                          ? MediaQuery.of(context).size.width * 0.75
                          : MediaQuery.of(context).size.width * 0.775,
                    ),
                    CustomPaint(
                      painter: TrianglePainter(),
                      size: Size(MediaQuery.of(context).size.width * 0.1,
                          MediaQuery.of(context).size.width * 0.065),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSection('HOY', _todayAppointments),
                          _buildSection('AYER', _yesterdayAppointments),
                          _buildSection('ANTIER', _dayBeforeYesterdayAppointments),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<List<Appointment2>> appointmentsFuture) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.0035,
          decoration: const BoxDecoration(
            color: Color(0xFF4F2263),
          ),
        ),
        FutureBuilder<List<Appointment2>>(
          future: appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No hay citas');
            } else {
              return Column(
                children: snapshot.data!.map((appointment) {
                  return NotiCards(appointment: appointment);
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}