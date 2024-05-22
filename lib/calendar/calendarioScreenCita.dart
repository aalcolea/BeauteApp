import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../views/admin/toDate.dart';

class CalendarioCita extends StatefulWidget {


  const CalendarioCita({Key? key}) : super(key: key);

  @override
  State<CalendarioCita> createState() => _CalendarioCitaState();
}

class _CalendarioCitaState extends State<CalendarioCita> {
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
  int initMonth = 0;
  int? currentMonth = 0;
  int? visibleYear = 0;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    initMonth = now.month;
    currentMonth = _calendarController.displayDate?.month;
    visibleYear = now.year;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.07,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFF4F2263),
                    size: 25,
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
                  style: const TextStyle(fontSize: 30, color: Color(0xFF72A5D0)),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF4F2263),
                    size: 25,
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
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.grey, width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: SfCalendar(
                  headerHeight: 0,
                  firstDayOfWeek: 1,
                  view: CalendarView.month,
                  controller: _calendarController,
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.calendarCell ||
                        details.targetElement == CalendarElement.appointment) {
                      ///aqui manda crea cita
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

                    if (isToday) {
                      return Center(
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
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
                    } else if (isToday) {
                      return Container(
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
            ),
          ),
        ],
      ),
    );
  }
}
