import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../views/admin/toDate.dart';

class AgendaSchedule extends StatefulWidget {
  final bool isDoctorLog;
  final void Function(
    bool,
  ) showContentToModify;

  const AgendaSchedule(
      {Key? key, required this.isDoctorLog, required this.showContentToModify})
      : super(key: key);

  @override
  State<AgendaSchedule> createState() => _AgendaScheduleState();
}

class _AgendaScheduleState extends State<AgendaSchedule> {
  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  CalendarController _calendarController = CalendarController();
  List<Appointment2> _appointments = [];
  int initMonth = 0;
  int? currentMonth = 0;
  int? visibleYear = 0;
  DateTime now = DateTime.now();
  bool _VarmodalReachTop = false;
  bool _isTaped = false;
  int? _expandedIndex;
  bool docLog = false;

  @override
  void initState() {
    super.initState();
    docLog = widget.isDoctorLog;
    initMonth = now.month;
    currentMonth = _calendarController.displayDate?.month;
    visibleYear = now.year;
    _loadAppointments();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarController;
    super.dispose();
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

  void _showModaltoDate(
      BuildContext context, CalendarTapDetails details, bool varmodalReachTop) {
    showModalBottomSheet(
      backgroundColor: !_VarmodalReachTop
          ? Colors.transparent
          : Colors.black54.withOpacity(0.3),
      isScrollControlled: _VarmodalReachTop,
      showDragHandle: false,
      barrierColor: Colors.black54,
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: AppointmentScreen(
              isDocLog: docLog,
              expandedIndex: _expandedIndex,
              selectedDate: details.date!,
              reachTop: (bool reachTop, int? expandedIndex) {
                setState(() {
                  if (!_VarmodalReachTop) {
                    Navigator.pop(context);
                    _VarmodalReachTop = true;
                    _expandedIndex = expandedIndex;
                    _showModaltoDate(context, details, _VarmodalReachTop);
                  } else {
                    _expandedIndex = null;
                    _VarmodalReachTop = reachTop;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.035),
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.07,
            decoration: BoxDecoration(
              color: const Color(0xFF4F2263),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.1,
                  ),
                  onPressed: () {
                    int previousMonth = currentMonth! - 1;
                    int previousYear = visibleYear!;
                    if (previousMonth < 1) {
                      previousMonth = 12;
                      previousYear--;
                    }
                    _calendarController.displayDate =
                        DateTime(previousYear, previousMonth, 1);
                  },
                ),
                Text(
                  currentMonth != null
                      ? '${getMonthName(currentMonth!)} $visibleYear'
                      : '${getMonthName(initMonth)} $visibleYear',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.09,
                      color: Colors.white),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.1,
                  ),
                  onPressed: () {
                    int nextMonth = currentMonth! + 1;
                    int nextYear = visibleYear!;
                    if (nextMonth > 12) {
                      nextMonth = 1;
                      nextYear++;
                    }
                    _calendarController.displayDate =
                        DateTime(nextYear, nextMonth, 1);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey, width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SfCalendar(
                  headerHeight: 0,
                  firstDayOfWeek: 1,
                  view: CalendarView.month,
                  controller: _calendarController,
                  dataSource: MeetingDataSource(_appointments),

                  ///modal
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.calendarCell ||
                        details.targetElement == CalendarElement.appointment) {
                      _VarmodalReachTop = false;
                      _showModaltoDate(context, details, _VarmodalReachTop);
                    }
                  },
                  onViewChanged: (ViewChangedDetails details) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      int? visibleMonthController =
                          _calendarController.displayDate?.month;
                      currentMonth = visibleMonthController;
                      int? visibleYearController =
                          _calendarController.displayDate?.year;
                      visibleYear = visibleYearController;
                      setState(() {});
                    });
                  },
                  initialDisplayDate: DateTime.now(),
                  monthCellBuilder:
                      (BuildContext context, MonthCellDetails details) {
                    final bool isToday =
                        details.date.month == DateTime.now().month &&
                            details.date.day == DateTime.now().day &&
                            details.date.year == DateTime.now().year;

                    final bool isInCurrentMonth =
                        details.date.month == currentMonth &&
                            details.date.year == visibleYear;

                    final bool hasEvent = _appointments.any((Appointment2
                            appointment) =>
                        appointment.appointmentDate != null &&
                        details.date.day == appointment.appointmentDate!.day &&
                        details.date.month ==
                            appointment.appointmentDate!.month &&
                        details.date.year == appointment.appointmentDate!.year);

                    if (isToday && hasEvent) {
                      return Center(
                        child: Container(
                          width: null,
                          height: null,
                          decoration: BoxDecoration(
                            color: hasEvent ? Colors.purple[100] : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: hasEvent ? Colors.purple : Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              details.date.day.toString(),
                              style: const TextStyle(
                                color: Color(0xFF4F2263),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (isToday) {
                      return Container(
                        width: null,
                        height: null,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            details.date.day.toString(),
                            style: TextStyle(
                              color: const Color(0xFF4F2263),
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.07,
                            ),
                          ),
                        ),
                      );
                    } else if (hasEvent) {
                      return Container(
                        width: null,
                        height: null,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasEvent ? Colors.purple[100] : Colors.white,
                          border: Border.all(
                              color: hasEvent ? Colors.purple : Colors.grey),
                        ),
                        child: Text(
                          details.date.day.toString(),
                          style: TextStyle(
                            color: hasEvent ? Colors.white : Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Container(
                          width: null,
                          //MediaQuery.of(context).size.width * 0.2,
                          height: null,
                          //MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              details.date.day.toString(),
                              style: TextStyle(
                                color: isInCurrentMonth
                                    ? const Color(0xFF72A5D0)
                                    : const Color(0xFFC5B6CD),
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.055,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
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
      appointmentDate: json['appointment_date'] != null
          ? DateTime.parse(json['appointment_date'])
          : null,
      treatmentType: json['treatment_type'] as String?,
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String?,
      clientName: json['client_name'] as String?,
    );
  }
}
