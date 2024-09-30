import 'dart:convert';
import 'package:beaute_app/utils/listenerApptm.dart';
import 'package:beaute_app/views/admin/toDate/apptmInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../calendar/calendarioScreenCita.dart';
import '../models/appointmentModel.dart';
import '../utils/PopUpTabs/deleteAppointment.dart';
import '../utils/PopUpTabs/saveAppointment.dart';
import '../utils/timer.dart';

class ToDateContainer extends StatefulWidget {
  final Listenerapptm? listenerapptm;
  final void Function(bool, int?, String, String, bool, String) reachTop;
  final String? firtsIndexTouchHour;
  final String? firtsIndexTouchDate;
  final String dateLookandFill;
  final DateTime selectedDate;
  final int? expandedIndexToCharge;
  const ToDateContainer({super.key, required this.reachTop, this.firtsIndexTouchHour, this.firtsIndexTouchDate, required this.dateLookandFill, required this.selectedDate, this.expandedIndexToCharge, this.listenerapptm});

  @override
  State<ToDateContainer> createState() => _ToDateContainerState();
}

class _ToDateContainerState extends State<ToDateContainer> with TickerProviderStateMixin {
  List<SlidableController> slidableControllers = [];
  //
  bool isDocLog = false;
  late Future<List<Appointment>> appointments;
  late bool modalReachTop;
  late DateTime dateTimeToinitModal;
  late int index;
  late Appointment appointment;
  String _dateLookandFill = '';

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
  bool visibleKeyboard = false;
  String _firtsIndexTouchHour = '';
  bool isCalendarShow = false;
  bool isHourCorrect = false;
  int _selectedIndexAmPm = 0;
  bool positionBtnIcon = false;
  int isSelectedHelper = 7;
  double offsetX = 0.0;
  int movIndex = 0;
  bool dragStatus = false; //false = start
  int? _oldIndex;
  bool isDragX = false;
  int itemDragX = 0;

  //final void Function(bool, int?, String, String, bool, String) reachTop;

  void reachTop (bool modalReachTop , int? _expandedIndex, String _timerController, String _dateController, bool positionBtnIcon, String _dateLookandFill){
      expandedIndex = _expandedIndex;
      widget.reachTop(
          modalReachTop,
          expandedIndex,
          _timerController,
          _dateController,
          positionBtnIcon,
          _dateLookandFill);
  }
  void _initializateApptm (bool inititializate, DateTime date){
    if(inititializate = true){
        initializeAppointments(date);
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

  @override
  void initState() {
    // TODO: implement initState
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
   initializeAppointments(dateTimeToinitModal);
   widget.listenerapptm!.registrarObservador((newValue, newDate, newId){
     setState(() {
       if(newValue == true){
         initializeAppointments(newDate);
       }
     });
   });
   for (int i = 0; i < 10; i++) {
     final controller = SlidableController(this);
     controller.animation.addListener(() {
       double dragRatio = controller.ratio;
       dragRatio != 0 ? isDragX = true : false;
       if(dragRatio != 0){
         setState(() {
           isDragX = true;
           itemDragX = i;
         });

       }else{
         setState(() {
           isDragX = false;
         });
       }
     });
     slidableControllers.add(controller);
   }
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in slidableControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          alignment: Alignment.center,
        color: Colors.white,
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
                      Appointment appointment = filteredAppointments[index];
                      String time = (appointment.appointmentDate != null)
                          ? DateFormat('hh:mm a')
                          .format(appointment.appointmentDate!)
                          : 'Hora desconocida';
                      List<String> timeParts = time.split(' ');
                      String clientName = appointment.clientName ?? 'Cliente desconocido';
                      String treatmentType = appointment.treatmentType ?? 'Sin tratamiento';
                      ///este gesture detector le pertenece a al container qye muesta info y sirve para la animacion de borrar
                      return Container(
                        color: Colors.transparent,
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0,
                            left: MediaQuery.of(context).size.width * 0.02,
                            right: MediaQuery.of(context).size.width * 0.02,
                            bottom: MediaQuery.of(context).size.width * 0.02,
                          ),
                          child: Slidable(
                            controller: slidableControllers[index],
                            key: ValueKey(index),
                            startActionPane: null,
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                dismissible: DismissiblePane(
                                  confirmDismiss: () async {
                                    bool result = await showDeleteAppointmentDialog(
                                      context,
                                      widget,
                                      appointment.id,
                                      refreshAppointments,
                                      isDocLog,
                                    );
                                    if(result){
                                      refreshAppointments();
                                      return true;

                                    }else {
                                      slidableControllers[index].close();
                                      return false;
                                    }
                                  },
                                  onDismissed: () {
                                  },
                                ),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                        bool result = await showDeleteAppointmentDialog(
                                          context,
                                          widget,
                                          appointment.id,
                                          refreshAppointments,
                                          isDocLog,
                                        );
                                        if (result) {
                                          refreshAppointments();
                                        }
                                      },
                                    backgroundColor: const Color(0xFFBC1313),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Eliminar',
                                  ),
                                ],
                              ),
                              child: ApptmInfo(clientName: clientName, treatmentType: treatmentType, index: index, dateLookandFill: _dateLookandFill,
                                reachTop: reachTop, appointment: appointment, timeParts: timeParts, selectedDate: widget.selectedDate,
                                firtsIndexTouchHour: widget.firtsIndexTouchHour, firtsIndexTouchDate: widget.firtsIndexTouchDate,
                              listenerapptm: widget.listenerapptm, filteredAppointments: filteredAppointments,
                              expandedIndexToCharge: expandedIndex, initializateApptm: _initializateApptm,)));
                    });
              }
            }));
  }
}
