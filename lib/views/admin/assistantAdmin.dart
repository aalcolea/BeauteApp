import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:beaute_app/views/admin/clientDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../calendar/calendarSchedule.dart';
import '../../forms/appoinmentForm.dart';
import '../../forms/clientForm.dart';
import '../../utils/PopUpTabs/closeConfirm.dart';
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
  bool _cancelConfirm = false;
  double? screenWidth;
  double? screenHeight;
  late bool platform; //0 IOS 1 Androide

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void initState() {
    _selectedScreen = 1;
    keyboardVisibilityController = KeyboardVisibilityController();
    Platform.isIOS ? platform = false : platform = true;
    checkKeyboardVisibility();

    super.initState();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  void _onCancelConfirm(bool cancelConfirm) {
    setState(() {
      _cancelConfirm = cancelConfirm;
    });
  }

  onBackPressed(didPop) {
    if (!didPop) {
      setState(() {
        _selectedScreen == 3
            ? _selectedScreen = 1
            : showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertCloseDialog(
                    onCancelConfirm: _onCancelConfirm,
                  );
                },
              ).then((_) {
                if (_cancelConfirm == true) {
                  if (_cancelConfirm) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      SystemNavigator.pop();
                    });
                  }
                }
              });
      });

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onBackPressed(didPop);
      },
      child: Scaffold(
        body: Container(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: _selectedScreen == 3
                        ? MediaQuery.of(context).size.width * 0.045
                        : MediaQuery.of(context).size.width * 0.045,
                    right: MediaQuery.of(context).size.width * 0.025,
                    bottom: MediaQuery.of(context).size.width * 0.005),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: false,//_selectedScreen != 1,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedScreen = 1;
                                  _hideBtnsBottom = false;
                                });
                              },
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                CupertinoIcons.back,
                                size: MediaQuery.of(context).size.width * 0.08,
                                color: const Color(0xFF4F2263),
                              )),
                        ),
                        Text(
                          _selectedScreen == 1
                              ? 'Calendario'
                              : _selectedScreen == 3
                                  ? 'Clientes'
                                  : _selectedScreen == 4
                                      ? 'Notificaciones'
                                      : '',
                          style: TextStyle(
                            color: const Color(0xFF4F2263),
                            fontSize: screenWidth! < 370.00
                                ? MediaQuery.of(context).size.width * 0.078
                                : MediaQuery.of(context).size.width * 0.082,
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
                              if (_selectedScreen != 4) {
                                _selectedScreen = 4;
                                _hideBtnsBottom = true;
                              } else {
                                _selectedScreen = 1;
                                _hideBtnsBottom = false;
                              }
                            });
                          },
                          icon: Icon(
                            CupertinoIcons.calendar_today,
                            size: MediaQuery.of(context).size.width * 0.095,
                            color: const Color(0xFF4F2263),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: Icon(
                            Icons.input_outlined,
                            size: MediaQuery.of(context).size.width * 0.095,
                            color: const Color(0xFF4F2263),
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
                        ? MediaQuery.of(context).size.width * 0.04
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
                          ? MediaQuery.of(context).size.width * 0.03
                          : MediaQuery.of(context).size.width * 0.0,
                      bottom: _selectedScreen == 4 ? MediaQuery.of(context).size.width * 0.02 : MediaQuery.of(context).size.width * 0.04,
                      left: _selectedScreen != 4 && _selectedScreen != 3
                          ? MediaQuery.of(context).size.width * 0.045
                          : MediaQuery.of(context).size.width * 0.0,
                      right: _selectedScreen != 4 && _selectedScreen != 3
                          ? MediaQuery.of(context).size.width * 0.045
                          : MediaQuery.of(context).size.width * 0.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      bottom: screenWidth! < 391
                          ? MediaQuery.of(context).size.width * 0.055
                          : MediaQuery.of(context).size.width * 0.02),
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
                          color: _selectedScreen == 2
                              ? Colors.white
                              : Colors.white,
                          size: MediaQuery.of(context).size.width * 0.1,
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                if (mounted) {
                                  _selectedScreen = 3;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _selectedScreen == 3 ?
                                CupertinoIcons.person_fill :CupertinoIcons.person,
                                color: _selectedScreen == 3
                                    ? const Color(0xFF4F2263)
                                    : const Color(0xFF4F2263).withOpacity(0.2),
                                size: MediaQuery.of(context).size.width * 0.11,
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
      ));
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
        return const ClientDetials();
      case 4:
        return const NotificationsScreen(doctorId: 3);
      case 5:
        return ClientForm(
            onHideBtnsBottom: _onHideBtnsBottom,
            onFinishedAddClient: _onFinishedAddClient);
      default:
        return Container();
    }
  }
}
