import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AgendaSchedule extends StatefulWidget {
  const AgendaSchedule({super.key});

  @override
  State<AgendaSchedule> createState() => _AgendaScheduleState();
}

class _AgendaScheduleState extends State<AgendaSchedule> {
  final List<String> _weekDaysInSpanish = [
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

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

  DateTime now = DateTime.now();
  int initMonth = 0;
  int? currentMonth = 0;

  final CalendarController _calendarSfCController = CalendarController();
  bool monthView = true;
  bool weekView = false;

  int? visibleYear = 0;

  @override
  void initState() {
    initMonth = now.month;
    currentMonth = _calendarSfCController.displayDate?.month;
    visibleYear = now.year;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarSfCController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: monthView,
          child: Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
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
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              int previousMonth = currentMonth! - 1;
                              int previousYear = visibleYear!;
                              if (previousMonth < 1) {
                                previousMonth = 12;
                                previousYear--;
                              }

                              _calendarSfCController.displayDate =
                                  DateTime(previousYear, previousMonth, 1);
                            },
                          ),
                          Text(
                            currentMonth != null
                                ? '${getMonthName(currentMonth!)} $visibleYear'
                                : '${getMonthName(initMonth)} $visibleYear',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 32, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              int nextMonth = currentMonth! + 1;
                              int nextYear = visibleYear!;
                              if (nextMonth > 12) {
                                nextMonth = 1;
                                nextYear++;
                              }
                              _calendarSfCController.displayDate =
                                  DateTime(nextYear, nextMonth, 1);
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        7,
                        (index) {
                          return Expanded(
                            child: Container(
                              width: null,
                              height: null,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: 0.2, color: Colors.black54),
                              ),
                              child: Center(
                                child: Text(
                                  _weekDaysInSpanish[index],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF4F2263),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: SfCalendar(
                        view: CalendarView.month,
                        headerHeight: 0,
                        initialDisplayDate: DateTime.now(),
                        viewHeaderHeight: 0,
                        firstDayOfWeek: 1,
                        controller: _calendarSfCController,
                        todayHighlightColor: Colors.white,
                        dataSource: MeetingDataSource(getAppointments()),

                        ///
                        onViewChanged: (ViewChangedDetails details) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            int? visibleMonthController =
                                _calendarSfCController.displayDate?.month;
                            currentMonth = visibleMonthController;
                            int? visibleYearController =
                                _calendarSfCController.displayDate?.year;
                            visibleYear = visibleYearController;
                            setState(() {});
                          });
                        },

                        ///
                        onTap: (CalendarTapDetails details) {
                          if (details.targetElement ==
                              CalendarElement.calendarCell) {
                            setState(() {
                              weekView = true;
                              //monthView = false;
                            });

                            print('true');
                          }
                        },
                        monthCellBuilder:
                            (BuildContext context, MonthCellDetails details) {
                          final bool isToday =
                              details.date.month == DateTime.now().month &&
                                  details.date.day == DateTime.now().day &&
                                  details.date.year == DateTime.now().year;

                          final bool isInCurrentMonth =
                              details.date.month == currentMonth &&
                                  details.date.year == visibleYear;

                          if (isToday) {
                            return Center(
                              child: Container(
                                width: 45,
                                height: 45,
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
                                    style: const TextStyle(
                                      color: Color(0xFF4F2263),
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Container(
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
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List<Appointment> getAppointments() {
  List<Appointment> meetings = <Appointment>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));

  meetings.add(Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: 'Facial',
      color: Colors.blueAccent));
  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
