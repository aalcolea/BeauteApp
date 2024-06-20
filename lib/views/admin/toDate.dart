import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../forms/appoinmentForm.dart';
import '../../models/appointmentModel.dart';
import '../../utils/PopUpTabs/deleteAppointment.dart';
import '../../utils/timer.dart';

class AppointmentScreen extends StatefulWidget {
  final void Function(bool, int?) reachTop;
  final DateTime selectedDate;
  final int? expandedIndex;

  const AppointmentScreen({
    Key? key,
    required this.selectedDate,
    required this.reachTop,
    required this.expandedIndex,
  }) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool isDocLog = false;
  late Future<List<Appointment>> appointments;
  bool modalReachTop = false;
  late DateTime selectedDate2;
  TextEditingController _timerController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  bool _isTimerShow = false;
  bool modifyAppointment = false;
  int? expandedIndex;
  bool isTaped = false;
  String? dateOnly;

  @override
  void initState() {
    super.initState();
    expandedIndex = widget.expandedIndex;
    isTaped = expandedIndex != null;
    selectedDate2 = widget.selectedDate;
    initializeAppointments(widget.selectedDate);
    dateOnly = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
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

  Future<List<Appointment>> fetchAppointments(DateTime selectedDate, {int? id}) async {
    String baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinments';
    String url = id != null ? '$baseUrl/$id' : baseUrl;
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
        List<Appointment> allAppointments = appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
        return allAppointments.where((appointment) =>
        appointment.appointmentDate != null &&
            appointment.appointmentDate!.year == selectedDate.year &&
            appointment.appointmentDate!.month == selectedDate.month &&
            appointment.appointmentDate!.day == selectedDate.day).toList();
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
      //initializeAppointments();
    });
  }
  void _onTimeChoose(bool isTimerShow, TextEditingController timerController) {
    setState(() {
      _isTimerShow = isTimerShow;
      _timerController = timerController;
    });
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
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.09),
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.035),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
                    DateTime date = widget.selectedDate.add(Duration(days: index - 2));
                    bool isSelected = selectedDate2.day == date.day &&
                        selectedDate2.month == date.month &&
                        selectedDate2.year == date.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate2 = date;
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
                              offset: Offset(0, MediaQuery.of(context).size.width * 0.003),
                            ),
                            BoxShadow(
                              blurRadius: 25.0,
                              color: Colors.white,
                              offset: Offset(0, MediaQuery.of(context).size.width * 0.04),
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 5.0,
                              offset: Offset(0, MediaQuery.of(context).size.width * 0.002),
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0, MediaQuery.of(context).size.width * -0.04),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              DateFormat('EEE', 'es_ES').format(date).toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.deepPurple : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: isSelected
                                    ? MediaQuery.of(context).size.width * 0.057
                                    : MediaQuery.of(context).size.width * 0.035,
                              ),
                            ),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                color: isSelected ? Colors.deepPurple : Colors.grey,
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
                height: MediaQuery.of(context).size.width * 0.08,
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
                        return Text('No appointments found');
                      } else {
                        List<Appointment> filteredAppointments = snapshot.data!;
                        return ListView.builder(
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            Appointment appointment = filteredAppointments[index];
                            String time = (appointment.appointmentDate != null)
                                ? DateFormat('HH:mm').format(appointment.appointmentDate!)
                                : 'Hora desconocida';
                            String clientName = appointment.clientName ?? 'Cliente desconocido';
                            String treatmentType = appointment.treatmentType ?? 'Sin tratamiento';

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (expandedIndex == index) {
                                    expandedIndex = null;
                                    isTaped = false;
                                  } else {
                                    expandedIndex = index;
                                    isTaped = true;
                                  }
                                  modalReachTop = true;
                                  widget.reachTop(modalReachTop, expandedIndex);
                                });
                              },
                              child: Container(
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
                                              ? MediaQuery.of(context).size.width * 0.75
                                              : MediaQuery.of(context).size.width * 0.70,
                                          child: ListTile(
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  clientName,
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                                    color: expandedIndex == index
                                                        ? Colors.black
                                                        : !isTaped && expandedIndex != index
                                                        ? Colors.black
                                                        : const Color(0xFFC5B6CD),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Text(
                                              treatmentType,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                                color: expandedIndex == index
                                                    ? Colors.black
                                                    : !isTaped && expandedIndex != index
                                                    ? Colors.black
                                                    : const Color(0xFFC5B6CD),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: expandedIndex != index ? true : false,
                                          child: Expanded(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.2,
                                              height: MediaQuery.of(context).size.height * 0.06,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: !isTaped
                                                    ? const Color(0xFF4F2263)
                                                    : const Color(0xFFC5B6CD),
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: !isTaped
                                                      ? const Color(0xFF4F2263)
                                                      : const Color(0xFFC5B6CD),
                                                  width: 1.5,
                                                ),
                                              ),
                                              margin: EdgeInsets.only(
                                                right: expandedIndex != index
                                                    ? MediaQuery.of(context).size.width * 0.05
                                                    : 0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    time,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: MediaQuery.of(context).size.width * 0.07,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: expandedIndex == index,
                                          child: SizedBox(width: MediaQuery.of(context).size.width * 0.065),
                                        ),
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
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: expandedIndex == index ? true : false,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: MediaQuery.of(context).size.width * 0.026,
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
                                              onTap: () {},
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: MediaQuery.of(context).size.width * 0.024,
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
                                                suffixIcon: const Icon(Icons.access_time),
                                              ),
                                              readOnly: true,
                                              onTap: () {
                                                TimerFly(
                                                  onTimeChoose: _onTimeChoose,
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: MediaQuery.of(context).size.width * 0.025,
                                              bottom: MediaQuery.of(context).size.width * 0.02,
                                              right: MediaQuery.of(context).size.width * 0.025,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
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
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: MediaQuery.of(context).size.width * 0.05,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      showDeleteAppointmentDialog(context, widget, appointment.id, refreshAppointments);
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: MediaQuery.of(context).size.width * 0.085,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 4,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      side: const BorderSide(color: Color(0xFF4F2263), width: 1),
                                                    ),
                                                    backgroundColor: const Color(0xFF4F2263),
                                                    surfaceTintColor: const Color(0xFF4F2263),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.05,
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  child: Icon(
                                                    CupertinoIcons.checkmark,
                                                    color: Colors.white,
                                                    size: MediaQuery.of(context).size.width * 0.09,
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F2263),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06,
                  ),
                  surfaceTintColor: const Color(0xFF4F2263),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Color(0xFF4F2263), width: 2),
                  ),
                ),
                onPressed: () {
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
          bottom: expandedIndex == null
              ? MediaQuery.of(context).size.height * 0.47
              : MediaQuery.of(context).size.height * 0.91,
          child: Icon(
            Icons.drag_handle_sharp,
            color: Colors.grey,
            size: MediaQuery.of(context).size.width * 0.14,
          ),
        ),
      ],
    );
  }
}
