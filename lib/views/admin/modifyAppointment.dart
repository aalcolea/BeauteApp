import 'dart:ui';

import 'package:beaute_app/utils/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ModifyAppointment extends StatefulWidget {
  const ModifyAppointment({super.key});

  @override
  State<ModifyAppointment> createState() => _ModifyAppointmentState();
}

class _ModifyAppointmentState extends State<ModifyAppointment> {
  TextEditingController _dateController = TextEditingController();
  bool _isTimerShow = false;

  void _onTimeChoose(bool isTimerShow, TextEditingController dateController) {
    _isTimerShow = isTimerShow;
    _dateController = dateController;
  }

  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF4F2263), width: 2),
            boxShadow: [
              const BoxShadow(
                  blurRadius: 6, offset: Offset(0, 0), color: Colors.black54),
              BoxShadow(
                blurRadius: 4,
                color: Colors.white.withOpacity(0.6),
                offset: Offset(0, MediaQuery.of(context).size.width * -0.006),
              ),
              BoxShadow(
                blurRadius: 4,
                color: Colors.white.withOpacity(0.6),
                offset: Offset(MediaQuery.of(context).size.width * -0.006, 0),
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.029,
                  top: MediaQuery.of(context).size.width * 0.027),
              child: Text(
                'Paciente',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.055),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.029,
                  bottom: MediaQuery.of(context).size.width * 0.034),
              child: Text('Tratamiento',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055)),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.026),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.026),
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
                  horizontal: MediaQuery.of(context).size.width * 0.026),
              child: TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'DD/M/AAAA',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () {},
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.024),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.026),
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
                  horizontal: MediaQuery.of(context).size.width * 0.024),
              child: TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'HH:MM',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
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
                  bottom: MediaQuery.of(context).size.width * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.03,
                        right: MediaQuery.of(context).size.width * 0.02),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(color: Colors.red, width: 1),
                          ),
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.075)),

                      ///
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Stack(
                              children: [
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 4.0, sigmaY: 4.0),
                                  child: Container(
                                    color: Colors.black54.withOpacity(0.3),
                                  ),
                                ),
                                Center(
                                  child: AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                    content: Container(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                blurRadius: 3.5,
                                                offset: Offset(0, 0))
                                          ]),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '¿Seguro que desea eliminar esta cita?',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.085,
                                              color: const Color(0xFF4F2263),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.035,
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.03),
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.black,
                                                          width: 2.5,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Cancelar',
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                        color: const Color(
                                                            0xFF4F2263),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            elevation: 4,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 1),
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                            surfaceTintColor:
                                                                Colors.white,
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.05)),
                                                    onPressed: () {},
                                                    child: Text(
                                                      'Eliminar',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.048),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
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
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                                color: Color(0xFF4F2263), width: 1),
                          ),
                          backgroundColor: const Color(0xFF4F2263),
                          surfaceTintColor: const Color(0xFF4F2263),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05)),
                      onPressed: () {},
                      child: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.048),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
