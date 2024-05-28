import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TimerFly extends StatefulWidget {
  final void Function(
    bool,
    TextEditingController,
  ) onTimeChoose;

  TimerFly({super.key, required this.onTimeChoose});

  @override
  State<TimerFly> createState() => _TimerFlyState();
}

class _TimerFlyState extends State<TimerFly> {
  final ScrollController hourcontroller =
      FixedExtentScrollController(initialItem: 12);
  final ScrollController minsController =
      FixedExtentScrollController(initialItem: 0);
  final ScrollController AmPmController =
      FixedExtentScrollController(initialItem: 0);
  final timeController = TextEditingController();

  int selectedIndexAmPm = 0;
  int selectedIndexMins = 0;
  int selectedIndexHours = 0;
  int hour = 0;
  int minuts = 0;

  // 0 = AM, 1 = PM
  bool _isTimerShow = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              ///hrs
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                width: MediaQuery.of(context).size.width * 0.30,
                child: ListWheelScrollView.useDelegate(
                  controller: hourcontroller,
                  useMagnifier: true,
                  perspective: 0.005,
                  diameterRatio: 1.4,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      selectedIndexHours = value;
                      print(selectedIndexHours);
                    });
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(12, (index) {
                      final Color colorforhours = index == selectedIndexHours
                          ? const Color(0xFF4F2263)
                          : Colors.grey;

                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFF4F2263),
                              width: 2,
                            ),
                          ),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            index == 0 ? '12' : index.toString(),
                            style: TextStyle(
                              fontSize: 40,
                              color: colorforhours,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 40,
                  color: Color(0xFF4F2263),
                ),
              ),

              ///mins

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.30,
                child: ListWheelScrollView.useDelegate(
                  onSelectedItemChanged: (value) {
                    setState(() {
                      selectedIndexMins = value;
                      print(selectedIndexMins);
                    });
                  },
                  controller: minsController,
                  perspective: 0.005,
                  diameterRatio: 1.4,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50,
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(60, (index) {
                      final Color colorformins = index == selectedIndexMins
                          ? const Color(0xFF4F2263)
                          : Colors.grey;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFF4F2263),
                                width: 2,
                              ),
                            ),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              index < 10 ? '0$index' : index.toString(),
                              style: TextStyle(
                                fontSize: 40,
                                color: colorformins,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              ///am/pm
              Container(
                margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.02,
                    left: MediaQuery.of(context).size.width * 0.02),
                width: MediaQuery.of(context).size.width * 0.26,
                child: ListWheelScrollView.useDelegate(
                  controller: AmPmController,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      selectedIndexAmPm = value;
                      print(selectedIndexAmPm);
                    });
                  },
                  perspective: 0.005,
                  diameterRatio: 1.4,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50,
                  childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 2,
                      builder: (context, index) {
                        final Color colorforitems = index == selectedIndexAmPm
                            ? const Color(0xFF4F2263)
                            : Colors.grey;
                        final String text = index == 0 ? 'p.m' : 'a.m';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFF4F2263),
                                    width: 2,
                                  ),
                                ),
                                color: Colors.white),
                            child: Center(
                                child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 40,
                                color: colorforitems,
                              ),
                            )),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * 0.04,
          ),
          child: ElevatedButton(
            onPressed: () {
              DateTime now = DateTime.now();
              selectedIndexAmPm == 1
                  ? selectedIndexHours == 0
                      ? hour = 24
                      : hour = selectedIndexHours
                  : selectedIndexAmPm == 0
                      ? selectedIndexHours == 0
                          ? hour = 12
                          : hour = selectedIndexHours + 12
                      : print('holafly');
              print(hour);

              DateTime fullTime = DateTime(
                  now.year, now.month, now.day, hour, selectedIndexMins);
              String formattedTime = DateFormat('HH:mm:ss').format(fullTime);
              setState(() {
                timeController.text = formattedTime;
              });

              widget.onTimeChoose(
                _isTimerShow,
                timeController,
              );
            },

            /*if (picked != null) {
                 DateTime now = DateTime.now();
                      DateTime fullTime =
                      DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                      String formattedTime = DateFormat('HH:mm:ss').format(fullTime);
                      setState(() {
                      _timeController.text = formattedTime;
                     });
                      } else {
                      setState(() {
                      _timeController.text = 'Seleccione Hora';
                      });
                      }
                    }*/
            style: ElevatedButton.styleFrom(
              elevation: 7,
              surfaceTintColor: Colors.white,
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0xFF4F2263), width: 2),
              ),
              backgroundColor: const Color(0xFF4F2263),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
