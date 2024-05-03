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
    'M',
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
  late int initMonth;
  late int? currentMonth;

  CalendarController _calendarSfCController = CalendarController();
  late int? visibleYear;

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              color: const Color(0xFF66BEC8),
              //const Color(0xFF381460).withOpacity(0.3),
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      currentMonth != null
                          ? '${getMonthName(currentMonth!)} $visibleYear'
                          : '${getMonthName(initMonth)} $visibleYear',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 30, color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
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
                        color: const Color(0xFF66BEC8).withOpacity(0.5),
                        border: Border.all(width: 1, color: Colors.black54),
                      ),
                      child: Center(
                        child: Text(
                          _weekDaysInSpanish[index],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
                todayHighlightColor: const Color(0xFFDEA6CB),
                cellBorderColor: Colors.black54,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
