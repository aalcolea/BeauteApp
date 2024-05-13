import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../views/admin/toDate.dart';

class AgendaSchedule extends StatefulWidget {
  const AgendaSchedule({Key? key}) : super(key: key);

  @override
  State<AgendaSchedule> createState() => _AgendaScheduleState();
}

class _AgendaScheduleState extends State<AgendaSchedule> {
  CalendarController _calendarController = CalendarController();
  List<Appointment2> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final appointments = await fetchAppointments();
    setState(() {
      _appointments = appointments;
    });
  }
  Future<List<Appointment2>> fetchAppointments() async {
    final response = await http.get(Uri.parse(
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinments'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['appointments'];
      print(jsonDecode(response.body)['appointments']);
      return data.map((json) => Appointment2.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              controller: _calendarController,
              dataSource: MeetingDataSource(_appointments),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell ||
                    details.targetElement == CalendarElement.appointment) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(selectedDate: details.date!),
                    ),
                  );
                }
              },
              initialDisplayDate: DateTime.now(),
              monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                final bool hasEvent = _appointments.any((Appointment2 appointment) =>
                appointment.appointmentDate != null &&
                    details.date.day == appointment.appointmentDate!.day &&
                    details.date.month == appointment.appointmentDate!.month &&
                    details.date.year == appointment.appointmentDate!.year);
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasEvent ? Colors.purple[100] : Colors.white,
                    border: Border.all(color: hasEvent ? Colors.purple : Colors.grey),
                  ),
                  child: Text(
                    details.date.day.toString(),
                    style: TextStyle(color: hasEvent ? Colors.white : Colors.black),
                  ),
                );
              },
            )
            ,
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment2> source) {
    appointments = source;
  }
}


class Appointment2 {
  final int? id;
  final int? clientId;
  final int? createdBy;
  final int? doctorId;
  final DateTime? appointmentDate;
  final String? treatmentType;
  final String? paymentMethod;
  final String? status;
  final String? clientName;

  Appointment2({
    this.id,
    this.clientId,
    this.createdBy,
    this.doctorId,
    this.appointmentDate,
    this.treatmentType,
    this.paymentMethod,
    this.status,
    this.clientName,
  });

  factory Appointment2.fromJson(Map<String, dynamic> json) {
    return Appointment2(
      id: json['id'] as int?,
      clientId: json['client_id'] as int?,
      createdBy: json['created_by'] as int?,
      doctorId: json['doctor_id'] as int?,
      appointmentDate: json['appointment_date'] != null ? DateTime.parse(json['appointment_date']) : null,
      treatmentType: json['treatment_type'] as String?,
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String?,
      clientName: json['client_name'] as String?,
    );
  }
}

