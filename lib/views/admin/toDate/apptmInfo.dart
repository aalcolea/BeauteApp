import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../calendar/calendarioScreenCita.dart';
import '../../../models/appointmentModel.dart';
import '../../../utils/PopUpTabs/deleteAppointment.dart';
import '../../../utils/PopUpTabs/saveAppointment.dart';
import '../../../utils/listenerApptm.dart';
import '../../../utils/timer.dart';


class ApptmInfo extends StatefulWidget {
  final Listenerapptm? listenerapptm;
  final List<String> timeParts;
  final List<Appointment> filteredAppointments;
  final Appointment appointment;
  final String clientName;
  final String treatmentType;
  final int index;
  final String dateLookandFill;
  final DateTime selectedDate;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final int? expandedIndexToCharge;
  final void Function(bool, int?, String, String, bool, String) reachTop;
  final Function (bool, DateTime) initializateApptm;
  const ApptmInfo({super.key, required this.clientName, required this.treatmentType, required this.index, required this.dateLookandFill, required this.reachTop,
    required this.appointment, required this.timeParts, this.firtsIndexTouchHour, this.firtsIndexTouchDate, this.expandedIndexToCharge,
    required this.selectedDate, this.listenerapptm, required this.filteredAppointments, required this.initializateApptm});

  @override
  State<ApptmInfo> createState() => _ApptmInfoState();
}

class _ApptmInfoState extends State<ApptmInfo> {

  late Future<List<Appointment>> appointments;
  late List<Appointment> filteredAppointments;
  String _dateLookandFill = '';
  String _dateLookandFillAfterSave = '';
  String? dateOnly;
  String antiqueHour = '';
  String antiqueDate = '';
  late DateTime dateTimeToinitModal;
  bool isHourCorrect = false;
  int _selectedIndexAmPm = 0;

  //
  int? expandedIndex;
  bool isTaped = false;
  late int index;
  late bool modalReachTop;
  int? _oldIndex;
  bool isDragX = false;
  int itemDragX = 0;
  bool positionBtnIcon = false;
  bool _isTimerShow = false;
  bool isCalendarShow = false;
  bool isDocLog = false;
  //
  TextEditingController _timerController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  //

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      _dateController.text = dateToAppointmentForm;
      isCalendarShow = showCalendar;
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

  Future<void> refreshAppointments() async {
    setState(() {
      appointments = fetchAppointments(dateTimeToinitModal);
    });
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

  @override
  void initState() {
    // TODO: implement initState
    index = widget.index;
    _oldIndex = null;
    expandedIndex = widget.expandedIndexToCharge;
    isTaped = expandedIndex != null;
    if (widget.firtsIndexTouchHour != null) {
      _timerController.text = widget.firtsIndexTouchHour!;
      antiqueHour = widget.firtsIndexTouchHour!;
    }
    if (widget.firtsIndexTouchDate != null) {
      _dateController.text = widget.firtsIndexTouchDate!;
      antiqueDate = widget.firtsIndexTouchDate!;
    }
    if (widget.dateLookandFill.length > 4) {
      dateOnly = widget.dateLookandFill;
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    } else {
      dateOnly = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      dateTimeToinitModal = DateTime.parse(dateOnly!);
    }
    widget.listenerapptm!.registrarObservador((newValue, newDate, newId){
        if(newValue == true){
          String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
          _dateLookandFillAfterSave = formattedDate;
        }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (expandedIndex == index) {
            setState(() {
              expandedIndex = null;
              isTaped = false;
            });
          } else {
            setState(() {
              Appointment appointmetsToModify = widget.filteredAppointments[index];
              _timerController.text = DateFormat('HH:mm').format(appointmetsToModify.appointmentDate!);
              DateTime formattedTime24hrs = DateFormat('HH:mm').parse(_timerController.text);
              String formattedTime12hrs = DateFormat('h:mm a').format(formattedTime24hrs);
              _timerController.text = formattedTime12hrs;_dateController.text = DateFormat('yyyy-MM-dd').format(appointmetsToModify.appointmentDate!);
              _dateLookandFill = dateOnly!;
              expandedIndex = index;
              isTaped = true;
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
        ///container donde esta la info de la cita
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: itemDragX == index && isDragX == true ? const Radius.circular(0): const Radius.circular(15),
                bottomRight: itemDragX == index && isDragX == true ? const Radius.circular(0): const Radius.circular(15),
                topLeft: const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
              ),
              border: _oldIndex != index ? Border.all(
                color: expandedIndex == index
                    ? const Color(0xFF4F2263)
                    : !isTaped && expandedIndex != index
                    ? const Color(0xFF4F2263)
                    : const Color(0xFFC5B6CD),
                width: 1.5,
              ) : const Border(
                left: BorderSide(color: Color(0xFF4F2263), width: 1.5),
                top: BorderSide(color: Color(0xFF4F2263), width: 1.5),
                bottom: BorderSide(color: Color(0xFF4F2263), width: 1.5),
                right: BorderSide(color: Color(0xFF4F2263), width: 1.5), //change
              ),
              color: Colors.white,
              //boxShadow: normallyShadow,
            ),
            alignment: Alignment.center,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      crossAxisAlignment: expandedIndex == index
                          ? CrossAxisAlignment.center
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
                                        widget.appointment.doctorId == 1 ? 'Dr 1' : 'Dr 2',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                          MediaQuery.of(context).size.width * 0.05,
                                          color: expandedIndex == index ? const Color(0xFF4F2263) : !isTaped && expandedIndex != index
                                              ? const Color(0xFF4F2263) : const Color(0xFFC5B6CD),
                                        ),
                                      ),
                                      Text(
                                          ' ${widget.clientName}',
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
                                    widget.treatmentType,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                      color: expandedIndex == index ? Colors.black : !isTaped && expandedIndex != index ? Colors.black : const Color(0xFFC5B6CD),
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
                                  color: !isTaped ? const Color(0xFF4F2263) : const Color(0xFFC5B6CD),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: !isTaped ? const Color(0xFF4F2263) : const Color(0xFFC5B6CD),
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
                                            text: '${widget.timeParts[0]}\n', // "01:00"
                                          ),
                                          TextSpan(
                                              text: widget.timeParts[1], // "PM"
                                              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045,
                                              ))
                                        ])))),
                        ///termina card
                        Visibility(
                            visible: expandedIndex == index ? true : false,
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
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: MediaQuery.of(context).size.width * 0.026,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width, // o un ancho específico
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
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () {
                                setState(() {
                                  isCalendarShow == true ? isCalendarShow = false : isCalendarShow = true;
                                });
                              },
                            ),
                          ),
                        ),
                        AnimatedContainer(duration: const Duration(milliseconds: 85),
                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          margin: EdgeInsets.only(bottom: isCalendarShow ? MediaQuery.of(context).size.width * 0.02 : 0),
                          height: isCalendarShow ? 300 : 0,
                          decoration: const BoxDecoration(
                              color: Colors.white
                          ),
                          clipBehavior: Clip.hardEdge, // Recort
                          child: CalendarioCita(onDayToAppointFormSelected: _onDateToAppointmentForm),
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
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
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
                            )
                        ),

                        AnimatedContainer(duration: const Duration(milliseconds: 85),
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
                          margin: EdgeInsets.only(bottom: _isTimerShow ? MediaQuery.of(context).size.width * 0.02 : 0),
                          height: _isTimerShow ? 250 : 0,
                          decoration: const BoxDecoration(
                              color: Colors.white
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: TimerFly(onTimeChoose: _onTimeChoose),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(
                                  context).size.width * 0.025,
                              bottom: MediaQuery.of(context).size.width * 0.02,
                              right: MediaQuery.of(context).size.width * 0.025,
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                                        surfaceTintColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05,
                                        ),
                                      ),
                                      onPressed: () {
                                        showDeleteAppointmentDialog(
                                            context, widget, widget.appointment.id,
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
                                        showDialog(barrierDismissible: false, context: context, builder: (builder) {
                                          return ConfirmationDialog(
                                            appointment: widget.appointment,
                                            dateController: _dateController,
                                            timeController: _timerController,
                                            fetchAppointments: fetchAppointments,
                                          );
                                        },).then((result) {
                                              if (result == true) {
                                                setState(() {
                                                  modalReachTop = true;
                                                  expandedIndex = null;
                                                  isTaped = false;
                                                  positionBtnIcon = true;
                                                  _dateLookandFill = dateOnly!;
                                                  fetchAppointments(dateTimeToinitModal);
                                                  late DateTime dateSelected = dateTimeToinitModal;
                                                  DateTime date = dateTimeToinitModal;
                                                  dateSelected = date;
                                                  dateOnly = DateFormat('yyyy-MM-dd').format(dateSelected);
                                                  widget.reachTop(
                                                      modalReachTop,
                                                      expandedIndex,
                                                      _timerController.text,
                                                      _dateController.text,
                                                      positionBtnIcon,
                                                      _dateLookandFillAfterSave);
                                                  widget.initializateApptm(true, dateSelected);
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
                ])));
  }
}
