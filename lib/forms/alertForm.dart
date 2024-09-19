import 'dart:async';
import 'dart:io';

import 'package:beaute_app/forms/clientForm.dart';
import 'package:beaute_app/styles/AppointmentStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../services/getClientsService.dart';
class AlertForm extends StatefulWidget {

  final bool isDoctorLog;
  const AlertForm({super.key, required this.isDoctorLog});

  @override
  State<AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends State<AlertForm> {

  double? screenWidth;
  double? screenHeight;
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  late FocusNode focusNodeClient;
  late FocusNode focusNodeCel;
  late FocusNode focusNodeEmail;
  bool _showdrChooseWidget = false;
  TextEditingController? _drSelected = TextEditingController();
  int? doctor_id_body = 0;
  int _optSelected = 0;
  bool isDocLog = false;
  bool drFieldDone = false;
  final DropdownDataManager dropdownDataManager = DropdownDataManager();

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
          });
        });
  }

  void _onAssignedDoctor(
      bool dr1sel,
      bool dr2sel,
      TextEditingController drSelected,
      int optSelected,
      bool showdrChooseWidget) {
    setState(() {
      _drSelected = drSelected;
      if (_drSelected!.text == 'Doctor1') {
        doctor_id_body = 1;
      } else {
        doctor_id_body = 2;
      }
      _optSelected = optSelected;
      _showdrChooseWidget = showdrChooseWidget;
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
    hideKeyBoard();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    focusNodeClient = FocusNode();
    focusNodeCel = FocusNode();
    focusNodeEmail = FocusNode();
    super.initState();
    dropdownDataManager.fetchUser();
    isDocLog = widget.isDoctorLog;
  }

  @override
  void dispose() {
    focusNodeClient.dispose();
    focusNodeCel.dispose();
    focusNodeEmail.dispose();
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03,
                    right: MediaQuery.of(context).size.width * 0.03,
                    top: visibleKeyboard ? screenWidth! < 391.0 ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.width * 0.05 : screenWidth! < 391.0 ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.45),
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mandar alerta',
                            style: TextStyle(
                              fontSize:
                              MediaQuery.of(context).size.width * 0.08,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4F2263),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth! < 391.0 ? 70 : 95,
                          ),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              icon: const Icon(Icons.close, color: const Color(0xFF4F2263))
                          ),
                        ],
                      ),
                      Container(
                        height: visibleKeyboard
                            ? (screenWidth! < 391
                            ? MediaQuery.of(context).size.height * 0.46
                            : MediaQuery.of(context).size.height * 0.5)
                            : screenWidth! < 391.0 ? MediaQuery.of(context).size.height * 0.535
                            : MediaQuery.of(context).size.height * 0.6,
                        child: SingleChildScrollView(
                          physics:  const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                children: [
                                  Visibility(
                                    visible: _showdrChooseWidget ? true : false,
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.19,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: visibleKeyboard
                                        ? MediaQuery.of(context).size.height * 0.52
                                        : _showdrChooseWidget
                                            ? MediaQuery.of(context).size.height * 0.7
                                            : MediaQuery.of(context).size.height * 0.88,
                                    color: Colors.white,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Visibility(
                                            visible: isDocLog
                                                ? false
                                                : _showdrChooseWidget
                                                  ? false
                                                  : true,
                                            child: TitleContainer(
                                              child: Text(
                                                'Doctor: ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: isDocLog
                                                ? false
                                                : _showdrChooseWidget
                                                  ? false
                                                  : true,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: MediaQuery.of(context).size.width * 0.02,
                                                horizontal: MediaQuery.of(context).size.width * 0.01,
                                              ),
                                              child: TextFormField(
                                                controller: _drSelected,
                                                decoration: InputDecoration(
                                                  hintText: 'Seleccione una opción...',
                                                  contentPadding: EdgeInsets.symmetric(
                                                    horizontal: MediaQuery.of(context).size.width * 0.03,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  suffixIcon: Icon(
                                                    Icons.arrow_drop_down_circle_outlined,
                                                    size: MediaQuery.of(context).size.width * 0.085,
                                                    color: const Color(0xFF4F2263),
                                                  ),
                                                ),
                                                readOnly: true,
                                                onTap: () {
                                                  setState(() {
                                                    _showdrChooseWidget = _showdrChooseWidget
                                                        ? false
                                                        : true;
                                                  });
                                                },
                                                onEditingComplete: () {
                                                  setState(() {
                                                    drFieldDone = true;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: true,
                                            child: DoctorsMenu(onAssignedDoctor: _onAssignedDoctor, optSelectedToRecieve: _optSelected),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ]
                ),
              )
            ],
          ),
        );
  }
}
