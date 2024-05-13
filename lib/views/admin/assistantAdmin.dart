import 'dart:async';

import 'package:beaute_app/views/admin/toDate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../calendar/calendarSchedule.dart';
import '../../forms/clientForm.dart';
import '../../utils/drSelectbox.dart';
import 'drAdmin.dart';

class AssistantAdmin extends StatefulWidget {
  const AssistantAdmin({super.key});
  @override
  State<AssistantAdmin> createState() => _AssistantAdminState();
}

int _selectedScreen = 0;

class _AssistantAdminState extends State<AssistantAdmin> {
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool scrollToDayComplete = false;


  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
        print(visibleKeyboard);
      });
    });
  }

  @override
  void initState() {
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    print(visibleKeyboard);
    super.initState();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //modifica el container del calendario
        padding: EdgeInsets.only(
            right: 15,
            left: 15,
            bottom: MediaQuery.of(context).size.height * 0,
            top: 25),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calendario',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.09),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.input_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4F2263),
                    width: 2,
                  ),
                ),
                child: const AgendaSchedule(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.065),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          showModalBottomSheet(
                              isScrollControlled: scrollToDayComplete,
                              context: context,
                              builder: (builder) {
                                return AppointmentScreen();
                              });
                          //Navigator.pushNamed(context, '/toDate');
                          _selectedScreen = 1;
                          setState(() {});
                          print(_selectedScreen);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _selectedScreen != 1
                                ? CupertinoIcons.calendar
                                : CupertinoIcons.calendar,
                            color: _selectedScreen == 1
                                ? const Color(0xFF4F2263)
                                : const Color(0xFF4F2263).withOpacity(0.2),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.pushNamed(context, '/citaScreen');
                          _selectedScreen = 2;
                          setState(() {});
                          print(_selectedScreen);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedScreen == 2
                                ? const Color(0xFF4F2263)
                                : const Color(0xFF4F2263),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _selectedScreen == 2
                                  ? Colors.black.withOpacity(0.12)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _selectedScreen != 2
                                ? CupertinoIcons.add
                                : CupertinoIcons.add,
                            color: _selectedScreen == 2
                                ? Colors.white
                                : Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                contentPadding: EdgeInsets.zero,
                                content: const ClientForm(),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              );
                            },
                          );

                          _selectedScreen = 3;
                          setState(() {});
                          print(_selectedScreen);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _selectedScreen == 3
                                ? Icons.person_add_alt_outlined
                                : Icons.person_add_alt_outlined,
                            color: _selectedScreen == 3
                                ? const Color(0xFF4F2263)
                                : const Color(0xFF4F2263).withOpacity(0.2),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
