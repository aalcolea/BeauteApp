import 'dart:async';
import 'dart:ui';

import 'package:beaute_app/views/admin/toDate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../calendar/calendarSchedule.dart';
import '../../forms/appoinmentForm.dart';
import '../../forms/clientForm.dart';
import '../../utils/PopUpTabs/clientSuccessfullyAdded.dart';
import '../../utils/drSelectbox.dart';
import '../../utils/showToast.dart';
import '../../utils/toastWidget.dart';
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
  bool isDocLog = false;
  bool _showContentToModify = false;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
        print(visibleKeyboard);
      });
    });
  }

  void _OnshowContentToModify(bool showContentToModify){
    _showContentToModify = showContentToModify;
  }

  @override
  void initState() {
    _selectedScreen = 1;
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
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedScreen == 1
                      ? 'Calendario'
                      : _selectedScreen == 3
                          ? 'Nuevo Cliente'
                          : '',
                  style: TextStyle(
                    color: const Color(0xFF4F2263),
                    fontSize: MediaQuery.of(context).size.width * 0.09,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        size: MediaQuery.of(context).size.width * 0.095,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.input_outlined,
                        size: MediaQuery.of(context).size.width * 0.095,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.055,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    border: const Border(
                      bottom: BorderSide(
                        color: Color(0xFF4F2263),
                        width: 2.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10.0,
                        offset: Offset(
                            0, MediaQuery.of(context).size.width * 0.012),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(
                            0, MediaQuery.of(context).size.width * -0.025),
                      ),
                    ]),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.06,
                      horizontal: MediaQuery.of(context).size.width * 0.045),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildBody(),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.055),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _selectedScreen = 1;
                          });
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F2263),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.06),
                      surfaceTintColor: const Color(0xFF4F2263),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                            color: Color(0xFF4F2263), width: 2),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppointmentForm(isDoctorLog: isDocLog),
                        ),
                      );
                      //Navigator.pushNamed(context, '/citaScreen');
                    },
                    child: Icon(
                      _selectedScreen != 2
                          ? CupertinoIcons.add
                          : CupertinoIcons.add,
                      color: _selectedScreen == 2 ? Colors.white : Colors.white,
                      size: 40,
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
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

  Widget _buildBody() {
    switch (_selectedScreen) {
      case 1:
        return AgendaSchedule(isDoctorLog: isDocLog, showContentToModify: _OnshowContentToModify);
      case 3:
        return ClientForm();
      default:
        return Container();
    }
  }
}
