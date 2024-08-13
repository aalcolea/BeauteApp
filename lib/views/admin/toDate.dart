import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../calendar/calendarioScreenCita.dart';
import '../../forms/appoinmentForm.dart';
import '../../models/appointmentModel.dart';
import '../../styles/AppointmentStyles.dart';
import '../../utils/PopUpTabs/deleteAppointment.dart';
import '../../utils/PopUpTabs/saveAppointment.dart';
import '../../utils/timer.dart';

class AppointmentScreen extends StatefulWidget {
  final void Function(bool, int?, String, String, bool) reachTop;
  final bool isDocLog;
  final DateTime selectedDate;
  final int? expandedIndex;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final bool btnToReachTop;

  const AppointmentScreen(
      {Key? key,
      required this.selectedDate,
      required this.reachTop,
      required this.expandedIndex,
      required this.isDocLog,
      this.firtsIndexTouchHour,
      this.firtsIndexTouchDate,
      required this.btnToReachTop})
      : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool isDocLog = false;
  late Future<List<Appointment>> appointments;
  late bool modalReachTop;

  late DateTime selectedDate2;
  TextEditingController _timerController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String antiqueHour = '';
  String antiqueDate = '';
  bool _isTimerShow = false;
  bool modifyAppointment = false;
  int? expandedIndex;
  bool isTaped = false;
  String? dateOnly;
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  String _firtsIndexTouchHour = '`';
  bool isCalendarShow = false;
  bool isHourCorrect = false;
  int _selectedIndexAmPm = 0;
  bool positionBtnIcon = false;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
        print(visibleKeyboard);
      });
    });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> initializeAppointments(DateTime date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId != null) {
        setState(() {
          appointments = fetchAppointments(date, id: userId);
        });
      } else {
        setState(() {
          appointments = fetchAppointments(date);
        });
      }
    } catch (e) {
      setState(() {
        appointments = Future.error("Error retrieving user ID: $e");
      });
    }
  }

  Future<List<Appointment>> fetchAppointments(DateTime selectedDate,
      {int? id}) async {
    String baseUrl =
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinments';
    String baseUrl2 =
        'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinmentsAssit';
    String url = id != null ? '$baseUrl/$id' : baseUrl2;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

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
      throw Exception('Vefique conexión a internet');
    }
  }

  Future<void> refreshAppointments() async {
    setState(() {
      appointments = fetchAppointments(widget.selectedDate);
    });
  }

  void _onTimeChoose(bool isTimerShow, TextEditingController timerController,
      int SelectedIndexAmPm) {
    setState(() {
      _isTimerShow = isTimerShow;
      _timerController = timerController;
      _selectedIndexAmPm = SelectedIndexAmPm;
      String toCompare = timerController.text;
      List<String> timeToCompare = toCompare.split(':');
      int hourToCompareConvert = int.parse(timeToCompare[0]);
      int minuteToCompareConvert = int.parse(timeToCompare[1]);
      DateTime dateTimeNow = DateTime.now();
      DateTime selectedDateT =
          DateFormat('yyyy-MM-dd').parse(_dateController.text);

      DateTime selectedDateTimeToCompare = DateTime(
          selectedDateT.year,
          selectedDateT.month,
          selectedDateT.day,
          hourToCompareConvert,
          minuteToCompareConvert);

      if (selectedDateT.year == dateTimeNow.year &&
          selectedDateT.month == dateTimeNow.month &&
          selectedDateT.day == dateTimeNow.day &&
          selectedDateTimeToCompare.isBefore(dateTimeNow)) {
        isHourCorrect = false;
        _timerController.text = 'Seleccione hora válida';
        timerControllertoShow.text = 'Seleccione hora válida';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pueden seleccionar horarios pasados'),
          ),
        );
      } else {
        isHourCorrect = true;
        _timerController = timerController;
        String toShow = _timerController.text;
        DateTime formattedTime24hrs = DateFormat('HH:mm').parse(toShow);
        String formattedTime12hrs =
            DateFormat('hh:mm a').format(formattedTime24hrs);
        _timerController.text = formattedTime12hrs;
      }
    });
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      _dateController.text = dateToAppointmentForm;
      isCalendarShow = showCalendar;
    });
  }

  double? screenWidth;
  double? screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  late DateTime dateTime;
  late String formattedTime;

  @override
  void initState() {
    super.initState();

    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    print(' antiqueHour $antiqueHour');
    positionBtnIcon = widget.btnToReachTop;
    selectedDate2 = widget.selectedDate;
    isDocLog = widget.isDocLog;
    expandedIndex = widget.expandedIndex;
    isTaped = expandedIndex != null;
    selectedDate2 = widget.selectedDate;
    initializeAppointments(widget.selectedDate);
    dateOnly = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    if (widget.firtsIndexTouchHour != null) {
      _timerController.text = widget.firtsIndexTouchHour!;
      antiqueHour = widget.firtsIndexTouchHour!;
    }
    if (widget.firtsIndexTouchDate != null) {
      _dateController.text = widget.firtsIndexTouchDate!;
      antiqueDate = widget.firtsIndexTouchDate!;
    }
/*
    widget.firtsIndexTouchHour != null
        ? _timerController.text = widget.firtsIndexTouchHour!
        : null;
    widget.firtsIndexTouchHour != null
        ? antiqueHour = widget.firtsIndexTouchHour!
        : null;
*/

/*    widget.firtsIndexTouchDate != null
        ? _dateController.text = widget.firtsIndexTouchDate!
        : null;*/
  }

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    _dateController.dispose();
    timerControllertoShow.dispose();
    keyboardVisibilitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<BoxShadow> normallyShadow = [
      const BoxShadow(
        color: Colors.black54,
        blurRadius: 3,
        offset: Offset(0, 0),
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0, MediaQuery.of(context).size.width * -0.02),
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(MediaQuery.of(context).size.width * -0.02, 0),
      ),
    ];

    return Stack(
      children: [
        Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.09),
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.035),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
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
                          dateOnly =
                              DateFormat('yyyy-MM-dd').format(selectedDate2);
                          initializeAppointments(date);
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                    offset: Offset(
                                        0,
                                        MediaQuery.of(context).size.width *
                                            0.003),
                                  ),
                                  BoxShadow(
                                    blurRadius: 25.0,
                                    color: Colors.white,
                                    offset: Offset(
                                        0,
                                        MediaQuery.of(context).size.width *
                                            0.04),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 5.0,
                                    offset: Offset(
                                        0,
                                        MediaQuery.of(context).size.width *
                                            0.002),
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(
                                        0,
                                        MediaQuery.of(context).size.width *
                                            -0.04),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              DateFormat('EEE', 'es_ES')
                                  .format(date)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: isSelected
                                    ? MediaQuery.of(context).size.width * 0.057
                                    : MediaQuery.of(context).size.width * 0.035,
                              ),
                            ),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: isSelected
                                    ? MediaQuery.of(context).size.width * 0.051
                                    : MediaQuery.of(context).size.width * 0.033,
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
                height: MediaQuery.of(context).size.width * 0.03,
              ),
              Expanded(
                child: Container(
                  color: isTaped ? Colors.white : Colors.white,
                  child: FutureBuilder<List<Appointment>>(
                    future: appointments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No se han encontrado appoinments');
                      } else {
                        List<Appointment> filteredAppointments = snapshot.data!;
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            Appointment appointment =
                                filteredAppointments[index];
                            String time = (appointment.appointmentDate != null)
                                ? DateFormat('hh:mm a')
                                    .format(appointment.appointmentDate!)
                                : 'Hora desconocida';
                            List<String> timeParts = time.split(' ');

                            String clientName =
                                appointment.clientName ?? 'Cliente desconocido';
                            String treatmentType =
                                appointment.treatmentType ?? 'Sin tratamiento';

                            return InkWell(
                              onTap: () {
                                if (expandedIndex == index) {
                                  setState(() {
                                    expandedIndex = null;
                                    isTaped = false;
                                  });
                                } else {
                                  setState(() {
                                    ///
                                    Appointment appointmetsToModify =
                                        filteredAppointments[index];
                                    _timerController.text = DateFormat('HH:mm')
                                        .format(appointmetsToModify
                                            .appointmentDate!);
                                    DateTime formattedTime24hrs =
                                        DateFormat('HH:mm')
                                            .parse(_timerController.text);
                                    String formattedTime12hrs =
                                        DateFormat('h:mm a')
                                            .format(formattedTime24hrs);
                                    _timerController.text = formattedTime12hrs;
                                    _dateController.text =
                                        DateFormat('yyyy-MM-dd').format(
                                            appointmetsToModify
                                                .appointmentDate!);
                                    print(
                                        'appointmetsToModify ${_dateController.text}');

                                    ///
                                    expandedIndex = index;
                                    isTaped = true;
                                    positionBtnIcon = true;
                                    modalReachTop = true;
                                    widget.reachTop(
                                        modalReachTop,
                                        expandedIndex,
                                        _timerController.text,
                                        _dateController.text,
                                        positionBtnIcon);
                                  });
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * 0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.02,
                                  right:
                                      MediaQuery.of(context).size.width * 0.02,
                                  bottom:
                                      MediaQuery.of(context).size.width * 0.035,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: expandedIndex == index
                                        ? const Color(0xFF4F2263)
                                        : !isTaped && expandedIndex != index
                                            ? const Color(0xFF4F2263)
                                            : const Color(0xFFC5B6CD),
                                    width: 1.5,
                                  ),
                                  color: expandedIndex == index
                                      ? Colors.white
                                      : !isTaped && expandedIndex != index
                                          ? Colors.white
                                          : Colors.white,
                                  boxShadow: normallyShadow,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: expandedIndex == index
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: expandedIndex == index
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.75
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.70,

                                          /// Fila de Nombre del doctor Nombre del paciente
                                          child: ListTile(
                                            title: Row(
                                              children: [
                                                Text(
                                                  appointment.doctorId == 1
                                                      ? 'Dr 1'
                                                      : 'Dr 2',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    color: expandedIndex ==
                                                            index
                                                        ? const Color(
                                                            0xFF4F2263)
                                                        : !isTaped &&
                                                                expandedIndex !=
                                                                    index
                                                            ? const Color(
                                                                0xFF4F2263)
                                                            : const Color(
                                                                0xFFC5B6CD),
                                                  ),
                                                ),
                                                Text(
                                                  ' $clientName',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    color: expandedIndex ==
                                                            index
                                                        ? Colors.black
                                                        : !isTaped &&
                                                                expandedIndex !=
                                                                    index
                                                            ? Colors.black
                                                            : const Color(
                                                                0xFFC5B6CD),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            /*],
                                            ),*/
                                            subtitle: Text(
                                              treatmentType,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                color: expandedIndex == index
                                                    ? Colors.black
                                                    : !isTaped &&
                                                            expandedIndex !=
                                                                index
                                                        ? Colors.black
                                                        : const Color(
                                                            0xFFC5B6CD),
                                              ),
                                            ),
                                          ),
                                        ),

                                        ///cuadrado morado en donde se muestra la hora
                                        Visibility(
                                          visible: expandedIndex != index
                                              ? true
                                              : false,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.22,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.0825,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: !isTaped
                                                  ? const Color(0xFF4F2263)
                                                  : const Color(0xFFC5B6CD),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: !isTaped
                                                    ? const Color(0xFF4F2263)
                                                    : const Color(0xFFC5B6CD),
                                                width: 1.5,
                                              ),
                                            ),
                                            margin: EdgeInsets.only(
                                              right: expandedIndex != index
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.0
                                                  : 0,
                                            ),
                                            child: RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.06,
                                                  color: Colors.white,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        timeParts[0], // "01:00"
                                                  ),
                                                  const TextSpan(
                                                    text: '\n', // Nueva línea
                                                  ),
                                                  TextSpan(
                                                    text: timeParts[1], // "PM"
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.045,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        ///termina card
                                        Visibility(
                                          visible: expandedIndex == index,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.065),
                                        ),
                                        Visibility(
                                          visible: expandedIndex == index
                                              ? true
                                              : false,
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            color: Colors.transparent,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                setState(() {
                                                  expandedIndex = null;
                                                  isTaped = false;
                                                });
                                              },
                                              icon: Icon(
                                                CupertinoIcons.minus,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.09,
                                                color: const Color(0xFF4F2263),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible:
                                          expandedIndex == index ? true : false,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.026,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.026,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4F2263),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Fecha:',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.026,
                                            ),
                                            child: TextFormField(
                                              controller: _dateController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.03,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                labelText: 'DD/M/AAAA',
                                                suffixIcon: const Icon(
                                                    Icons.calendar_today),
                                              ),
                                              readOnly: true,
                                              onTap: () {
                                                setState(() {
                                                  isCalendarShow = true;
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.024,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.026,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4F2263),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Hora:',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.024,
                                            ),
                                            child: TextFormField(
                                              controller: _timerController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.03,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                labelText: 'HH:MM',
                                                suffixIcon: const Icon(
                                                    Icons.access_time),
                                              ),
                                              readOnly: true,
                                              onTap: () {
                                                setState(() {
                                                  _isTimerShow == false
                                                      ? _isTimerShow = true
                                                      : _isTimerShow = false;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.025,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.025,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.05,
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02,
                                                  ),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 4,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        side: const BorderSide(
                                                            color: Colors.red,
                                                            width: 1),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.05,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      showDeleteAppointmentDialog(
                                                          context,
                                                          widget,
                                                          appointment.id,
                                                          refreshAppointments,
                                                          isDocLog);
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.085,
                                                    ),
                                                  ),
                                                ),

                                                ///boton para modificar
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 4,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      side: const BorderSide(
                                                          color:
                                                              Color(0xFF4F2263),
                                                          width: 1),
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFF4F2263),
                                                    surfaceTintColor:
                                                        const Color(0xFF4F2263),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (builder) {
                                                          return ConfirmationDialog(
                                                            appointment:
                                                                appointment,
                                                            dateController:
                                                                _dateController,
                                                            timeController:
                                                                _timerController,
                                                            fetchAppointments:
                                                                fetchAppointments,
                                                          );
                                                        },
                                                      ).then((result) {
                                                        if (result == true) {
                                                          expandedIndex = null;
                                                          isTaped = false;
                                                          refreshAppointments();
                                                        } else {
                                                          _timerController
                                                                  .text =
                                                              antiqueHour;
                                                          _dateController.text =
                                                              antiqueDate;
                                                        }
                                                      });
                                                    });
                                                    },
                                                  child: Icon(
                                                    CupertinoIcons.checkmark,
                                                    color: Colors.white,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.09,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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

              ///boton para agregar cita
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F2263),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.0,
                  ),
                  surfaceTintColor: const Color(0xFF4F2263),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Color(0xFF4F2263), width: 2),
                  ),
                ),
                onPressed: () {
                  dateOnly = DateFormat('yyyy-MM-dd').format(selectedDate2);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentForm(
                        isDoctorLog: isDocLog,
                        dateFromCalendarSchedule: dateOnly,
                      ),
                    ),
                  );
                },
                child: Icon(
                  CupertinoIcons.add,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.09,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.43,
          bottom: positionBtnIcon == false
              ? MediaQuery.of(context).size.height * 0.467
              : positionBtnIcon == true
                  ? MediaQuery.of(context).size.height * 0.905
                  : null,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                if (positionBtnIcon == false) {
                  positionBtnIcon = true;
                  modalReachTop = true;
                  widget.reachTop(
                      modalReachTop,
                      expandedIndex,
                      _timerController.text,
                      _dateController.text,
                      positionBtnIcon);
                } else {
                  positionBtnIcon = false;
                  modalReachTop = false;
                  widget.reachTop(
                      modalReachTop,
                      expandedIndex,
                      _timerController.text,
                      _dateController.text,
                      positionBtnIcon);
                }
              });
            },
            icon: Icon(
              !positionBtnIcon
                  ? CupertinoIcons.chevron_compact_up
                  : CupertinoIcons.chevron_compact_down,
              color: Colors.grey,
              size: MediaQuery.of(context).size.width * 0.11,
            ),
          ),
        ),

        ///Calendario
        if (isCalendarShow)
          GestureDetector(
            onTap: () {
              setState(() {
                isCalendarShow = false;
              });
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black54.withOpacity(0.27),
              ),
            ),
          ),

        Positioned(
          top: screenWidth! < 370.00
              ? MediaQuery.of(context).size.height * 0.0525
              : MediaQuery.of(context).size.height *
                  0.0265, //pantalla peq 0.0525
          child: Visibility(
            visible: isCalendarShow,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: MediaQuery.of(context).size.width * 0.026,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                    ),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F2263),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Fecha:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: FieldsToWrite(
                      fillColor: Colors.white,
                      readOnly: true,
                      labelText: 'DD/M/AAAA',
                      controller: _dateController,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () {
                        setState(() {
                          !isCalendarShow
                              ? isCalendarShow = true
                              : isCalendarShow = false;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.018),
                    child: CalendarContainer(
                      child: CalendarioCita(
                          onDayToAppointFormSelected: _onDateToAppointmentForm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        ///timer
        if (_isTimerShow)
          GestureDetector(
            onTap: () {
              setState(() {
                _isTimerShow = false;
              });
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black54.withOpacity(0.27),
              ),
            ),
          ),

        Positioned(
          top: screenWidth! < 370.00
              ? MediaQuery.of(context).size.height * 0.01
              : MediaQuery.of(context).size.height * 0.035,
          child: Visibility(
            visible: _isTimerShow,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 1,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.365,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: MediaQuery.of(context).size.width * 0.026,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                    ),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F2263),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Hora:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0365,
                        vertical: MediaQuery.of(context).size.width * 0.02),
                    child: FieldsToWrite(
                      fillColor: Colors.white,
                      labelText: 'HH:MM',
                      readOnly: true,
                      controller: _timerController,
                      suffixIcon: const Icon(Icons.access_time),
                      onTap: () {
                        setState(() {
                          if (_isTimerShow == false) {
                            _isTimerShow = true;
                          } else if (_isTimerShow == true) {
                            _isTimerShow = false;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.0365,
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.width * 0.025,
                      left: MediaQuery.of(context).size.width * 0.038,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 0.5),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TimerFly(onTimeChoose: _onTimeChoose),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
