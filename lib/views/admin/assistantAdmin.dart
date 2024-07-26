import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../calendar/calendarSchedule.dart';
import '../../forms/appoinmentForm.dart';
import '../../forms/clientForm.dart';
import 'notifications.dart';

class AssistantAdmin extends StatefulWidget {
  final bool docLog;
  const AssistantAdmin({super.key, required this.docLog});

  @override
  State<AssistantAdmin> createState() => _AssistantAdminState();
}

class _AssistantAdminState extends State<AssistantAdmin> {
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool scrollToDayComplete = false;
  bool isDocLog = false;
  bool _showContentToModify = false;
  bool _hideBtnsBottom = false;
  int _selectedScreen = 0;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
      });
    });
  }

  void _onshowContentToModify(bool showContentToModify) {
    _showContentToModify = showContentToModify;
  }

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
      _hideBtnsBottom = hideBtnsBottom;
    });
  }

  @override
  void initState() {
    _selectedScreen = 1;
    print('isDocLog en assistantAdmind: $isDocLog');
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
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
            Padding(
              padding: EdgeInsets.only(
                left: _selectedScreen == 4
                    ? MediaQuery.of(context).size.width * 0.0
                    : _selectedScreen == 3
                        ? MediaQuery.of(context).size.width * 0.0
                        : MediaQuery.of(context).size.width * 0.045,
                right: _selectedScreen != 4
                    ? MediaQuery.of(context).size.width * 0.025
                    : MediaQuery.of(context).size.width * 0.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: _selectedScreen == 4
                            ? true
                            : _selectedScreen == 3
                                ? true
                                : false,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedScreen = 1;
                              _hideBtnsBottom = false;
                            });
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: MediaQuery.of(context).size.width * 0.082,
                          ),
                        ),
                      ),
                      Text(
                        _selectedScreen == 1
                            ? 'Calendario'
                            : _selectedScreen == 3
                                ? 'Nuevo Cliente'
                                : _selectedScreen == 4
                                    ? 'Notificaciones'
                                    : '',
                        style: TextStyle(
                          color: const Color(0xFF4F2263),
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _selectedScreen = 4;
                            _hideBtnsBottom = true;
                          });
                        },
                        icon: Icon(
                          Icons.notifications_none_outlined,
                          size: MediaQuery.of(context).size.width * 0.095,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
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
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: _selectedScreen != 4
                      ? MediaQuery.of(context).size.width * 0.055
                      : MediaQuery.of(context).size.width * 0.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: _selectedScreen == 4
                            ? const Radius.circular(15)
                            : const Radius.circular(0),
                        topRight: _selectedScreen == 4
                            ? const Radius.circular(15)
                            : const Radius.circular(0),
                        bottomLeft: const Radius.circular(15),
                        bottomRight: const Radius.circular(15)),
                    border: _selectedScreen != 4
                        ? const Border(
                            bottom: BorderSide(
                            color: Color(0xFF4F2263),
                            width: 2.5,
                          ))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: _selectedScreen != 4
                            ? Colors.black54
                            : Colors.white,
                        blurRadius: _selectedScreen != 4 ? 10.0 : 0,
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
                  margin: EdgeInsets.only(
                    top: _selectedScreen == 1
                        ? MediaQuery.of(context).size.width * 0.06
                        : MediaQuery.of(context).size.width * 0.0,
                    bottom: MediaQuery.of(context).size.width * 0.06,
                    left: _selectedScreen != 4
                        ? MediaQuery.of(context).size.width * 0.045
                        : MediaQuery.of(context).size.width * 0.0,
                    right: _selectedScreen != 4
                        ? MediaQuery.of(context).size.width * 0.045
                        : MediaQuery.of(context).size.width * 0.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildBody(),
                ),
              ),
            ),
            Visibility(
              visible: !_hideBtnsBottom,
              child: Container(
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
                              size: MediaQuery.of(context).size.width * 0.12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F2263),
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.06),
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
                      },
                      child: Icon(
                        _selectedScreen != 2
                            ? CupertinoIcons.add
                            : CupertinoIcons.add,
                        color:
                            _selectedScreen == 2 ? Colors.white : Colors.white,
                        size: MediaQuery.of(context).size.width * 0.1,
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
                              size: MediaQuery.of(context).size.width * 0.12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFinishedAddClient(int initScreen, bool forShowBtnAfterAddclient) {
    setState(() {
      _selectedScreen = initScreen;
      _hideBtnsBottom = forShowBtnAfterAddclient;
    });

  }

  Widget _buildBody() {
    switch (_selectedScreen) {
      case 1:
        return AgendaSchedule(
            isDoctorLog: isDocLog, showContentToModify: _onshowContentToModify);
      case 3:
        return ClientForm(
            onHideBtnsBottom: _onHideBtnsBottom,
            onFinishedAddClient: _onFinishedAddClient);
      case 4:
        return NotificationsScreen();
      default:
        return Container();
    }
  }
}
