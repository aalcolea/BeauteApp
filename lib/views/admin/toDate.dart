import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final void Function(bool, int?, String, String, bool, String) reachTop;
  final bool isDocLog;
  final DateTime selectedDate;
  final int? expandedIndex;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final bool btnToReachTop;
  final String dateLookandFill;

  const AppointmentScreen(
      {Key? key,
      required this.selectedDate,
      required this.reachTop,
      required this.expandedIndex,
      required this.isDocLog,
      this.firtsIndexTouchHour,
      this.firtsIndexTouchDate,
      required this.btnToReachTop,
      required this.dateLookandFill})
      : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with SingleTickerProviderStateMixin{

  late AnimationController _animationController;
  late Animation<double> movRight;
  late Animation<double> scaleIcon;
  late Animation<double> opacityIcon;
  bool isDocLog = false;
  late Future<List<Appointment>> appointments;
  late bool modalReachTop;

  //late DateTime selectedDate2;
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
  int isSelectedHelper = 7;
  String _dateLookandFill = '';
  double offsetX = 0.0;
  int movIndex = 0;
  bool dragStatus = false; //false = start
  late int? _oldIndex;

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
      appointments = fetchAppointments(dateTimeToinitModal);
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
  late DateTime dateTimeToinitModal;

  @override
  void initState() {
    super.initState();
    _oldIndex = null;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1260));
    movRight = Tween(begin: 0.0, end: -100.0,).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.addListener((){
      if(_animationController.status == AnimationStatus.completed){
        _animationController.stop();
      }
    });
    opacityIcon = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.25, curve: Curves.easeInOut )));
    scaleIcon = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    positionBtnIcon = widget.btnToReachTop;
    isDocLog = widget.isDocLog;
    expandedIndex = widget.expandedIndex;
    isTaped = expandedIndex != null;

    if (widget.dateLookandFill.length > 4) {
      dateOnly = widget.dateLookandFill;
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    } else {
      dateOnly = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    }
    initializeAppointments(dateTimeToinitModal);
    if (widget.firtsIndexTouchHour != null) {
      _timerController.text = widget.firtsIndexTouchHour!;
      antiqueHour = widget.firtsIndexTouchHour!;
    }
    if (widget.firtsIndexTouchDate != null) {
      _dateController.text = widget.firtsIndexTouchDate!;
      antiqueDate = widget.firtsIndexTouchDate!;
    }
    _animationController.addListener((){
      setState(() {
        //print('lister ${_animationController.status}');
      });
    });
  }

  String slideDirection = 'No slide detected';
  int statusAnimation = 0;

  void slideDetector(details, index){
    //1 indica que termino la animacion, 2 que se hizo un reverse y 3 que se hizo reset
    if (details.delta.dx < -5) {
        if(statusAnimation == 0 && _oldIndex == null){
          setState(() {
            _oldIndex = index;
            _animationController.forward().then((_){
              statusAnimation = 1;
              print('1fts izqSlide $statusAnimation');
              print('1fts_oldindex $_oldIndex');
              print('---------------');
            });
          });
        }
        if(statusAnimation == 1 && _oldIndex != index){
            _animationController.reverse().then((_){
              statusAnimation = 2;
              _oldIndex = index;
              if(_animationController.status == AnimationStatus.dismissed){
                _animationController.forward().then((_){
                  statusAnimation = 1;
                });
              }
            print('bug');
            print('just index $index');
            print('2scd izqSlide $statusAnimation');
            print('2scd_oldindex $_oldIndex');
            print('***************');
          });
        }
      ///
    } else if (details.delta.dx > 5) {
      setState(() {
        if(statusAnimation == 1 ){
          _animationController.reverse().then((_){
              statusAnimation = 2;
              if(statusAnimation == 2){
                _animationController.reset();
                statusAnimation = 0;
                _oldIndex = null;
                print('1fts derSlider $statusAnimation');
                print('1fts _oldIndex $_oldIndex');
                print('///////////');
              }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timerController.dispose();
    _dateController.dispose();
    timerControllertoShow.dispose();
    keyboardVisibilitySubscription.cancel();
    _animationController.stop();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorforShadow = Colors.grey.withOpacity(0.5);
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

    List<BoxShadow> normallyShadowLookandFill = [
      BoxShadow(
        color: colorforShadow,
        spreadRadius: 0,
        blurRadius: 0,
        offset: Offset(
            0,
            MediaQuery.of(context).size.width * 0.007), // Desplazamiento hacia abajo (sombra inferior)
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

            ///white
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.08,
                color: Colors.white,

                child: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.02,
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                color: Colors.grey.withOpacity(0.6),
                                width: isSelectedHelper == 0 ? 1.5 : 3.5),
                            bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.6),
                                width: isSelectedHelper == 0 ? 1.5 : 1.5)),
                        boxShadow: isSelectedHelper == 0
                            ? normallyShadowLookandFill
                            : null,
                      ),
                    ),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = constraints.maxWidth / 5;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              DateTime date = widget.selectedDate.add(Duration(days: index - 2));
                              bool isSelected = dateTimeToinitModal.day == date.day &&
                                      dateTimeToinitModal.month == date.month &&
                                      dateTimeToinitModal.year == date.year;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedHelper = index;
                                    dateTimeToinitModal = date;
                                    dateOnly = DateFormat('yyyy-MM-dd')
                                        .format(dateTimeToinitModal);
                                    dateTimeToinitModal =
                                        DateTime.parse(dateOnly!);
                                    initializeAppointments(dateTimeToinitModal);
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.width * 0.01),
                                  width: itemWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(0),
                                    border: index <= 5
                                        ? Border(
                                            left: BorderSide(
                                              color: Colors.grey.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                            top: BorderSide(
                                              color: Colors.grey.withOpacity(0.6),
                                              width: isSelected == true ? 1 : 3.5,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.grey.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? normallyShadowLookandFill
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        DateFormat('EEE', 'es_ES').format(date).toUpperCase(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSelected
                                              ? MediaQuery.of(context).size.width * 0.057
                                              : MediaQuery.of(context).size.width * 0.038,
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
                                              : MediaQuery.of(context).size.width * 0.036,
                                            ))
                                      ])));
                        });
                  })),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.02,
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                              color: Colors.grey.withOpacity(0.6),
                              width: isSelectedHelper == 4 ? 1.5 : 3.5),
                          bottom: BorderSide(
                            width: 1.5,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                          left: BorderSide(
                            width: 1.5,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        boxShadow: isSelectedHelper == 4
                            ? normallyShadowLookandFill
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.03,
              ),
              ///
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
                              return const Text('No se han encontrado appoinments');
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

                                    ///este gesture detector le pertenece a al container qye muesta info y sirve para la animacion de borrar
                                    return GestureDetector(
                                      /*onPanUpdate: (details) {
                                        setState(() {
                                          movIndex = index;
                                          slideDetector(details, movIndex);
                                        });
                                      },*/
                                      onHorizontalDragUpdate: (dragDetails){
                                        setState(() {
                                          movIndex = index;
                                          slideDetector(dragDetails, movIndex);
                                        });
                                      },

                                      onHorizontalDragStart: (startDetails){
                                        setState(() {
                                          dragStatus = false;
                                        });
                                      },

                                      onHorizontalDragEnd: (endDetails){
                                        dragStatus = true;
                                      },
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
                                            _timerController.text = DateFormat('HH:mm').format(appointmetsToModify.appointmentDate!);
                                            DateTime formattedTime24hrs =
                                            DateFormat('HH:mm').parse(_timerController.text);
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
                                            _dateLookandFill = dateOnly!;
                                            expandedIndex = index;
                                            isTaped = true;
                                            positionBtnIcon = true;
                                            modalReachTop = true;
                                            widget.reachTop(
                                                modalReachTop,
                                                expandedIndex,
                                                _timerController.text,
                                                _dateController.text,
                                                positionBtnIcon,
                                                _dateLookandFill);
                                          });
                                        }
                                      },
                                      ///AQUI
                                      ///container donde esta la info de la cita
                                      child: AnimatedBuilder(
                                        animation: _animationController,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: MediaQuery.of(context).size.height * 0,
                                                left: MediaQuery.of(context).size.width * 0.02,
                                                right: MediaQuery.of(context).size.width * 0.02,
                                                bottom: MediaQuery.of(context).size.width * 0.035,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: expandedIndex == index
                                                      ? const Color(0xFF4F2263)
                                                      : !isTaped && expandedIndex != index
                                                      ? const Color(0xFF4F2263)
                                                      : const Color(0xFFC5B6CD),
                                                  width: 3.5,
                                                ),
                                                color: Colors.white,
                                                boxShadow: normallyShadow,
                                              ),
                                              child: Container(
                                                  child: Column(
                                                      children: [
                                                        Row(
                                                            crossAxisAlignment: expandedIndex == index
                                                                ? CrossAxisAlignment.start
                                                                : CrossAxisAlignment.center,
                                                            children: [
                                                              SizedBox(
                                                                  width: expandedIndex == index
                                                                      ? MediaQuery.of(context).size.width * 0.75
                                                                      : MediaQuery.of(context).size.width * 0.70,

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
                                                                                MediaQuery.of(context).size.width * 0.05,
                                                                                color: expandedIndex == index
                                                                                    ? const Color(0xFF4F2263) : !isTaped && expandedIndex != index
                                                                                    ? const Color(0xFF4F2263)
                                                                                    : const Color(0xFFC5B6CD),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                                ' $clientName',
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                  MediaQuery.of(context).size.width * 0.05,
                                                                                  color: expandedIndex == index
                                                                                      ? Colors.black
                                                                                      : !isTaped && expandedIndex != index
                                                                                      ? Colors.black
                                                                                      : const Color(0xFFC5B6CD),
                                                                                ))
                                                                          ]),
                                                                      subtitle: Text(
                                                                          treatmentType,
                                                                          style: TextStyle(
                                                                            fontSize: MediaQuery.of(context).size.width * 0.05,
                                                                            color: expandedIndex == index
                                                                                ? Colors.black
                                                                                : !isTaped && expandedIndex != index
                                                                                ? Colors.black
                                                                                : const Color(0xFFC5B6CD),
                                                                          )))),

                                                              ///cuadrado morado en donde se muestra la hora
                                                              Visibility(
                                                                  visible: expandedIndex != index
                                                                      ? true
                                                                      : false,
                                                                  child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.22,
                                                                      height: MediaQuery.of(context).size.height * 0.0675,
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
                                                                            ? MediaQuery.of(context).size.width * 0.0 : 0,
                                                                      ),
                                                                      child: RichText(
                                                                          textAlign: TextAlign.center,
                                                                          text: TextSpan(
                                                                              style: TextStyle(
                                                                                fontSize: MediaQuery.of(context).size.width * 0.06,
                                                                                color: Colors.white,
                                                                              ),
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: '${timeParts[0]}\n', // "01:00"
                                                                                ),
                                                                                TextSpan(
                                                                                    text: timeParts[1], // "PM"
                                                                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045,
                                                                                    ))
                                                                              ])))),
                                                              ///termina card
                                                              Visibility(
                                                                visible: expandedIndex == index,
                                                                child: SizedBox(
                                                                    width: MediaQuery.of(context).size.width * 0.065),
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
                                                                            size: MediaQuery.of(context).size.width * 0.09,
                                                                            color: const Color(0xFF4F2263),
                                                                          ))))
                                                            ]),
                                                        Visibility(
                                                            visible: expandedIndex == index
                                                                ? true
                                                                : false,
                                                            child: Column(children: [
                                                              Container(
                                                                padding: EdgeInsets.symmetric(vertical: 8,
                                                                  horizontal: MediaQuery.of(context).size.width * .026,
                                                                ),
                                                                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.026,
                                                                ),
                                                                alignment:
                                                                Alignment.centerLeft,
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFF4F2263),
                                                                  borderRadius: BorderRadius.circular(
                                                                      10),
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
                                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: MediaQuery.of(context).size.width * 0.026,
                                                                ),
                                                                child: TextFormField(
                                                                  controller: _dateController,
                                                                  decoration: InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                      horizontal: MediaQuery.of(context).size.width * 0.03,
                                                                    ),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(10.0),
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
                                                                padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 8,
                                                                  horizontal: MediaQuery.of(context).size.width * 0.024,
                                                                ),
                                                                margin: EdgeInsets.symmetric(
                                                                  horizontal: MediaQuery.of(context).size.width * 0.026,
                                                                ),
                                                                alignment: Alignment.centerLeft,
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFF4F2263),
                                                                  borderRadius: BorderRadius.circular(10),
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
                                                                padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 8, horizontal: MediaQuery.of(context).size.width * 0.024,
                                                                ),
                                                                child: TextFormField(
                                                                  controller: _timerController,
                                                                  decoration: InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                      horizontal: MediaQuery.of(context).size.width * 0.03,
                                                                    ),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(10.0),
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
                                                                    top: MediaQuery.of(
                                                                        context).size.width * 0.025,
                                                                    bottom: MediaQuery.of(context).size.width * 0.02,
                                                                    right: MediaQuery.of(context).size.width * 0.025,
                                                                  ),
                                                                  child: Row(mainAxisAlignment: MainAxisAlignment.end,
                                                                      children: [
                                                                        Padding( padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width * 0.05,
                                                                          right: MediaQuery.of(context).size.width * 0.02,
                                                                        ),
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              elevation: 4,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                                side: const BorderSide(color: Colors.red, width: 1),
                                                                              ),
                                                                              backgroundColor: Colors.white,
                                                                              surfaceTintColor: Colors
                                                                                  .white,
                                                                              padding:
                                                                              EdgeInsets
                                                                                  .symmetric(
                                                                                horizontal: MediaQuery.of(context)
                                                                                    .size
                                                                                    .width *
                                                                                    0.05,
                                                                              ),
                                                                            ),
                                                                            onPressed: () {
                                                                              showDeleteAppointmentDialog(
                                                                                  context, widget, appointment.id,
                                                                                  refreshAppointments,
                                                                                  isDocLog);
                                                                            },
                                                                            child: Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red,
                                                                              size: MediaQuery.of(context).size.width * 0.085,
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        ///boton para modificar
                                                                        ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            elevation: 4,
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10.0),
                                                                              side: const BorderSide(
                                                                                  color: Color(0xFF4F2263),
                                                                                  width: 1),
                                                                            ),
                                                                            backgroundColor: const Color(0xFF4F2263),
                                                                            surfaceTintColor: const Color(0xFF4F2263),
                                                                            padding: EdgeInsets.symmetric(
                                                                              horizontal: MediaQuery.of(context).size.width * 0.05,
                                                                            ),
                                                                          ),
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              showDialog(
                                                                                barrierDismissible: false,
                                                                                context: context, builder:
                                                                                  (builder) {
                                                                                return ConfirmationDialog(
                                                                                  appointment: appointment,
                                                                                  dateController: _dateController,
                                                                                  timeController: _timerController,
                                                                                  fetchAppointments: fetchAppointments,
                                                                                );
                                                                              },
                                                                              ).then(
                                                                                      (result) {
                                                                                    //anadir
                                                                                    if (result == true) {
                                                                                      expandedIndex = null;
                                                                                      isTaped = false;
                                                                                      setState(
                                                                                              () {
                                                                                            //fetchAppointments(widget.selectedDate);
                                                                                            fetchAppointments(dateTimeToinitModal);
                                                                                            //late DateTime dateSelected = widget.selectedDate;
                                                                                            late DateTime dateSelected = dateTimeToinitModal;
                                                                                            //DateTime date = widget.selectedDate;
                                                                                            DateTime date = dateTimeToinitModal;
                                                                                            dateSelected = date;dateOnly = DateFormat('yyyy-MM-dd').format(dateSelected);
                                                                                            initializeAppointments(dateSelected);
                                                                                          });
                                                                                    } else {
                                                                                      _timerController.text = antiqueHour;
                                                                                      _dateController.text = antiqueDate;
                                                                                    }
                                                                                  });
                                                                            });
                                                                          },
                                                                          child: Icon(
                                                                            CupertinoIcons.checkmark,
                                                                            color: Colors.white,
                                                                            size: MediaQuery.of(context).size.width * 0.09,
                                                                          ),
                                                                        )
                                                                      ]))
                                                            ]))
                                                      ])),
                                            ),
                                            //
                                             Visibility(
                                               visible: _oldIndex != null && _oldIndex == index ? true: false,
                                               child: Transform.scale(
                                                 scale: _oldIndex != null && _oldIndex == index ? scaleIcon.value : 0,// scaleIcon.value,
                                                 child: Opacity(opacity:_oldIndex != null && _oldIndex == index ? opacityIcon.value : 0,
                                                     child: IconButton(
                                                       padding: EdgeInsets.zero,
                                                       onPressed: (){},
                                                       icon: Icon(Icons.delete,
                                                         color: Colors.red,
                                                         size: MediaQuery.of(context).size.width * 0.12,),
                                                     ))
                                             ),)
                                          ],
                                        ),
                                          ///
                                          builder: (context, infoContainer){
                                            return Transform.translate(offset: Offset(_oldIndex != null && _oldIndex == index ? movRight.value : 0, 0), child: infoContainer);
                                          }
                                          ///
                                      ),
                                    );
                                  });
                            }
                          }))),




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
                  dateOnly =
                      DateFormat('yyyy-MM-dd').format(dateTimeToinitModal);
                  Navigator.push(context, MaterialPageRoute(
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

        ///btn expandir
        Positioned(
          left: MediaQuery.of(context).size.width * 0.445,
          bottom: positionBtnIcon == false
              ? screenWidth! < 370
                  ? MediaQuery.of(context).size.height * 0.467
                  : MediaQuery.of(context).size.height * 0.475 //0.467
              : positionBtnIcon == true
                  ? screenWidth! < 370
                      ? MediaQuery.of(context).size.height * 0.905
                      : MediaQuery.of(context).size.height * 0.912
                  : null,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _dateLookandFill = dateOnly!;
                print('_dateLookandFill $_dateLookandFill');
                if (positionBtnIcon == false) {
                  positionBtnIcon = true;
                  modalReachTop = true;
                  widget.reachTop(
                      modalReachTop,
                      expandedIndex,
                      _timerController.text,
                      _dateController.text,
                      positionBtnIcon,
                      _dateLookandFill);
                } else {
                  positionBtnIcon = false;
                  modalReachTop = false;
                  widget.reachTop(
                      modalReachTop,
                      expandedIndex,
                      _timerController.text,
                      _dateController.text,
                      positionBtnIcon,
                      _dateLookandFill);
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
                      )
                    ],
                  ))))
    ]);
  }
}
