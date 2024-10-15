import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:beaute_app/agenda/forms/clientForm.dart';
import 'package:beaute_app/regEx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../calendar/calendarioScreenCita.dart';
import '../models/clientModel.dart';
import '../services/getClientsService.dart';
import '../styles/AppointmentStyles.dart';
import '../themes/colors.dart';
import '../utils/PopUpTabs/addNewClientandAppointment.dart';
import '../utils/PopUpTabs/appointmetSuccessfullyCreated.dart';
import '../utils/PopUpTabs/closeAppointmentScreen.dart';
import '../utils/timer.dart';


class AppointmentForm extends StatefulWidget {
  final bool docLog;
  final String? dateFromCalendarSchedule;
  final String? nameClient;
  final int? idScreenInfo;

  const AppointmentForm({
    super.key,
    required this.docLog,
    this.dateFromCalendarSchedule,
    this.nameClient,
    this.idScreenInfo,
  });

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final GlobalKey<ClientFormState> myWidgetKey = GlobalKey<ClientFormState>();
  final DropdownDataManager dropdownDataManager = DropdownDataManager();
  Client? _selectedClient;
  var _clientTextController = TextEditingController();
  final _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController timerControllertoShow = TextEditingController();
  final treatmentController = TextEditingController();
  FocusNode fieldClientNode = FocusNode();
  TextEditingController? _drSelected = TextEditingController();
  bool _showdrChooseWidget = false;
  int day = 0;
  int month = 0;
  int year = 0;
  bool isTimerShow = false;
  bool isDocLog = false;
  bool saveNewClient = false;
  bool _showCalendar = false;
  int _optSelected = 0;
  bool drFieldDone = false;
  bool clientFieldDone = false;
  bool dateFieldDone = false;
  bool timeFieldDone = false;
  bool treatmentFieldDone = false;
  bool? clientInDB;
  int? number;
  bool isHourCorrect = false;
  TextEditingController emailController = TextEditingController();
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool _cancelConfirm = false;
  late BuildContext dialogforappointment;
  String nameToCompare = '';
  bool amPm = false;
  int? doctor_id_body = 0;
  bool platform = false; //ios False androide True
  String toTime = '';
  int? newClientID;
  bool showBlurr = false;
  //
  String nameDr1 = 'Doctor1';
  String nameDr2 = 'Doctor2';
  String nameDr3 = 'Doctor3';//etc

  Future<void> createClient() async {
    try {
      var response = await http.post(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/createClient'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _clientTextController.text,
          'number': number,
          'email': emailController.text,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          newClientID = data['client']['id'];
        });
      } else {
        print('Error al crear cliente: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar datos: $e');
    }
  }

  Future<void> addClientAndSubmitAppointment() async {
    setState(() {
      showBlurr = true;
    });
    bool? confirmed = await showAddClientAndAppointment();
    if (confirmed == true) {
      await createClient();
      if (newClientID != null) {
        print('Test alcance IDnew $newClientID');
        submitAppointment();
      } else {
        print('Error: ID del cliente no está disponible.');
      }
    } else {
      return;
    }
  }
  Future<bool?> showAddClientAndAppointment() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          alignment: visibleKeyboard ? Alignment.topCenter : Alignment.center,
          children: [
            Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: AddClientAndAppointment(
                        clientNamefromAppointmetForm: _clientTextController.text,
                        onSendDataToAppointmentForm: _onRecieveDataToAppointmentForm,
                        onConfirm: _onConfirm),
                  )),
          ],
        );
      },
    ).then((value){
      setState(() {
        showBlurr = false;
      });
      return value;
    });
  }

  void _onCancelConfirm(bool cancelConfirm, BuildContext dialogContext) {
    setState(() {
      _cancelConfirm = cancelConfirm;
      dialogforappointment = dialogContext;
    });
  }

  void _onRecieveDataToAppointmentForm(
      String _name, String _email, int celnumber, bool blurr) {
    setState(() {
      _clientTextController.text = _name;
      emailController.text = _email;
      number = celnumber;
      showBlurr = blurr;
    });
  }

  void _onConfirm() {}

  onBackPressed(didPop) {
    if (!didPop) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return AlertCloseAppointmentScreen(
            onCancelConfirm: _onCancelConfirm,
          );
        },
      ).then((_) {
        if (_cancelConfirm == true) {
          if (_cancelConfirm) {
            Navigator.of(context).pop();
          }
        }
      });
      return;
    }
  }

  void _onAssignedDoctor(
      bool dr1sel,
      bool dr2sel,
      TextEditingController drSelected,
      int optSelected,
      bool showdrChooseWidget) {
    setState(() {
      _drSelected = drSelected;
      if (_drSelected!.text == nameDr1) {
        doctor_id_body = 1;
      } else {
        doctor_id_body = 2;
      }//si hay mas drs habra que hacer un swicht o if else
      _optSelected = optSelected;
      _showdrChooseWidget = showdrChooseWidget;
    });
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        visibleKeyboard = visible;
      });
    });
  }

  void _onTimeChoose(bool _isTimerShow, TextEditingController selectedTime,
      int selectedIndexAmPm) {
    setState(() {
      isTimerShow = _isTimerShow;
      String toCompare = selectedTime.text;
      List<String> timeToCompare = toCompare.split(':');
      int hourToCompareConvert = int.parse(timeToCompare[0]);
      int minuteToCompareConvert = int.parse(timeToCompare[1]);
      DateTime dateTimeNow = DateTime.now();
      DateTime selectedDateT = DateFormat('yyyy-MM-dd').parse(_dateController.text);

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
        _timeController.text = 'Seleccione hora válida';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pueden seleccionar horarios pasados'),
          ),
        );
      } else {
        isHourCorrect = true;
        String toShow = selectedTime.text;
        DateTime formattedTime24hrs = DateFormat('HH:mm').parse(toShow);
        String formattedTime12hrs = DateFormat('hh:mm a').format(formattedTime24hrs);
        _timeController.text = formattedTime12hrs;
      }
    });
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      _dateController.text = dateToAppointmentForm;
      _showCalendar = showCalendar;
    });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void _updateSelectedClient(Client? client) {
    clientFieldDone = true;
    if (client != null) {
      setState(() {
        clientInDB = true;
        print('clientInDB T: $clientInDB');
        _selectedClient = client;
      });
    } else if (client == null) {
      setState(() {
        print('clientInDB BF: $clientInDB');
        clientInDB = false;
        print('clientInDB F: $clientInDB');
        _selectedClient = Client(
            id: 1,
            name: _clientTextController.text,
            email: '0', //emailController.text,
            number: 0);
      });
    } else {
      return;
    }
  }

  Future<void> submitAppointment() async {
    toTime = _timeController.text;
    DateFormat dateFormat12Hour = DateFormat('hh:mm a');
    DateFormat dateFormat24Hour = DateFormat('HH:mm');
    DateTime dateTime = dateFormat12Hour.parse(toTime);
    String time24HourFormat = dateFormat24Hour.format(dateTime);
    toTime = time24HourFormat;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    if (token == null) {
      print("No token found");
      return;
    }

    String url = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/createAppoinment';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'dr_id': doctor_id_body!,
          'client_id': newClientID != null ? newClientID : (widget.nameClient != null ? widget.idScreenInfo : _selectedClient?.id.toString()),
          'date': _dateController.text,
          'time': toTime,
          'treatment': treatmentController.text,
          'name': _clientTextController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          setState(() {
            showBlurr = true;
            showDialog(context: context,  barrierDismissible: false, builder: (BuildContext context){
              return Appointmetsuccessfullycreated(docLog: widget.docLog);
            }).then((_){
              setState(() {
                showBlurr = false;
              });
            });
        });
        }
        print('Respuesta del servidor: ${response.body}');
      } else {
        print(
            'Error al crear la cita: StatusCode: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.dateFromCalendarSchedule != null) {
      _dateController.text = widget.dateFromCalendarSchedule!;
    }
    Platform.isIOS ? platform = true : platform = false;
    isDocLog = widget.docLog;
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    dropdownDataManager.fetchUser();
    if (widget.nameClient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _clientTextController.text = widget.nameClient!;
          clientFieldDone = true;
        });
      });
    }
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    _clientTextController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    treatmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: platform,
      onPopInvoked: (didPop) {
        onBackPressed(didPop);
      },
      child: Scaffold(
        body: Form(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.width * 0.02),
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                CupertinoIcons.back,
                                size: MediaQuery.of(context).size.width * 0.08,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Text(
                              'Nueva cita',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.095,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                            ))
                      ])
                    ])),
            Column(
                    children: [
                      Visibility(
                        visible: _showdrChooseWidget ? true : false,
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.19),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: visibleKeyboard ? MediaQuery.of(context).size.height * 0.52
                            : _showdrChooseWidget ? MediaQuery.of(context).size.height * 0.7
                                : MediaQuery.of(context).size.height * 0.88,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Visibility(
                                visible: isDocLog ? false : _showdrChooseWidget ? false : true,
                                child: TitleContainer(
                                  child: Text(
                                    'Doctor: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: isDocLog ? false : _showdrChooseWidget ? false : true,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02,
                                      horizontal: MediaQuery.of(context).size.width * 0.026),
                                  child: TextFormField(
                                    controller: _drSelected,
                                    decoration: InputDecoration(
                                      hintText: 'Seleccione una opción...',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.03),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 1,
                                        )
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1,
                                          )
                                      ),
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        size: MediaQuery.of(context).size.width * 0.085,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      setState(
                                        () {
                                          _showdrChooseWidget = _showdrChooseWidget ? false : true;
                                          drFieldDone = true;
                                        },
                                      );
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
                                visible: !_showdrChooseWidget,
                                child: TitleContainer(
                                  child: Text('Cliente:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02,
                                    horizontal: MediaQuery.of(context).size.width * 0.026),
                                child: Autocomplete<Client>(
                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text == '') {
                                      return const Iterable<Client>.empty();
                                    }
                                    return dropdownDataManager.getSuggestions(textEditingValue.text).where((Client client) => client.id != 1);;
                                  },
                                  displayStringForOption: (Client option) => option.name,
                                  onSelected: (Client selection) {
                                    setState(() {
                                      _clientTextController.text = selection.name;
                                      nameToCompare = selection.name;
                                      _updateSelectedClient(selection);
                                      fieldClientNode.unfocus();
                                    });
                                  },
                                  fieldViewBuilder: (BuildContext context, fieldTextEditingController /*TextEditingController fieldTextEditingController*/,
                                      FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                                    fieldClientNode = fieldFocusNode;
                                    _clientTextController = fieldTextEditingController;
                                    return FieldsToWrite(
                                      inputFormatters: [
                                        RegEx(type: InputFormatterType.alphanumeric),
                                      ],
                                      eneabled: widget.nameClient == null ? true : false,
                                      textInputAction: TextInputAction.done,
                                      readOnly: false,
                                      labelText: 'Cliente',
                                      suffixIcon: Icon(
                                        CupertinoIcons.person,
                                        color: widget.nameClient != null ? Colors.grey : AppColors.primaryColor,
                                        size: MediaQuery.of(context).size.width * 0.075,
                                      ),
                                      controller: widget.nameClient != null ? _clientTextController : fieldTextEditingController,
                                      fillColor: Colors.white,
                                      focusNode: fieldFocusNode,
                                      onChanged: (text) {},
                                      onEdComplete: () {
                                        setState(() {
                                          clientFieldDone = true;
                                          nameToCompare == _clientTextController.text ? null : _updateSelectedClient(null);
                                          fieldFocusNode.unfocus();
                                        });
                                      },
                                      onTapOutside: (PointerDownEvent tapout) {
                                        setState(() {
                                          _clientTextController.text.isEmpty ? clientFieldDone = false : clientFieldDone = true;
                                          nameToCompare == _clientTextController.text ? null : _updateSelectedClient(null);
                                          fieldFocusNode.unfocus();
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible: isTimerShow ? true : _showCalendar ? false : true,
                                child: TitleContainer(
                                  child: Text('Fecha:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isTimerShow ? true : _showCalendar ? false : true,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context).size.width * 0.02,
                                      horizontal: MediaQuery.of(context).size.width * 0.026),
                                  child: FieldsToWrite(
                                    eneabled: drFieldDone && clientFieldDone &&
                                        widget.dateFromCalendarSchedule == null ? true : isDocLog && clientFieldDone &&
                                        widget.dateFromCalendarSchedule == null ? true : false,
                                    readOnly: true,
                                    labelText: 'DD/M/AAAA',
                                    controller: _dateController,
                                    suffixIcon: Icon(
                                      Icons.calendar_today,
                                      color: drFieldDone && clientFieldDone && widget.dateFromCalendarSchedule == null
                                          ? AppColors.primaryColor : isDocLog && clientFieldDone && widget.dateFromCalendarSchedule == null ?
                                      AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.3),
                                      size: MediaQuery.of(context).size.width * 0.07,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _clientTextController.text.isNotEmpty ? drFieldDone = true : null;
                                        hideKeyBoard();
                                        !_showCalendar ? _showCalendar = true : _showCalendar = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _showCalendar
                                    ? false
                                    : isTimerShow
                                        ? false
                                        : true,
                                child: TitleContainer(
                                  child: Text(
                                    'Hora:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !_showCalendar,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.026),
                                  child: FieldsToWrite(
                                    eneabled: _dateController.text.isNotEmpty ? true : false,
                                    labelText: 'HH:MM',
                                    readOnly: true,
                                    controller: _timeController,
                                    suffixIcon: Icon(
                                      Icons.access_time,
                                      color: _dateController.text.isNotEmpty
                                          ? AppColors.primaryColor
                                          : AppColors.primaryColor
                                              .withOpacity(0.3),
                                      size: MediaQuery.of(context).size.width * 0.075,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        hideKeyBoard();
                                        if (isTimerShow == false) {
                                          isTimerShow = true;
                                        } else if (isTimerShow == true) {
                                          isTimerShow = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: !isTimerShow && !_showCalendar,
                                child: TitleContainer(
                                  child: Text(
                                    'Tratamiento:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: !isTimerShow && !_showCalendar,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.026),
                                  child: FieldsToWrite(
                                    inputFormatters: [
                                      RegEx(type: InputFormatterType.alphanumeric),
                                    ],
                                    suffixIcon: Icon(
                                      CupertinoIcons.pencil_ellipsis_rectangle,
                                      size: MediaQuery.of(context).size.width *
                                          0.085,
                                      color: _timeController.text.isNotEmpty && isHourCorrect ? AppColors.primaryColor
                                          : AppColors.primaryColor.withOpacity(0.3),
                                    ),
                                    eneabled: _timeController.text.isNotEmpty && isHourCorrect ? true : false,
                                    labelText: 'Tratamiento',
                                    readOnly: false,
                                    controller: treatmentController,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !_showCalendar || isTimerShow,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: saveNewClient,
                                      onChanged: clientInDB == null || clientInDB == true ? null : (bool? value) {
                                              setState(() {
                                                saveNewClient = value ?? false;
                                              });
                                            },
                                      fillColor: MaterialStateColor.resolveWith(
                                          (states) {
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return AppColors.primaryColor;
                                        } else {
                                          return Colors.transparent;
                                        }
                                      }),
                                    ),
                                    TextButton(
                                      onPressed: clientInDB == null || clientInDB == true
                                          ? null : () {
                                              setState(() {
                                                saveNewClient == false ? saveNewClient = true : saveNewClient = false;
                                              });
                                            },
                                      child: Text(
                                        'Agregar nuevo cliente',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          color: clientInDB == null ||
                                                  clientInDB == true
                                              ? AppColors.primaryColor
                                                  .withOpacity(0.3)
                                              : AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Visibility(
                                visible: !isTimerShow && !_showCalendar
                                    ? true
                                    : false,
                                child: ElevatedButton(
                                  onPressed:
                                      treatmentController.text.isNotEmpty && !saveNewClient && isHourCorrect
                                          ? submitAppointment : saveNewClient && treatmentController.text.isNotEmpty && isHourCorrect
                                              ? addClientAndSubmitAppointment : null,
                                  style: ElevatedButton.styleFrom(
                                    surfaceTintColor: Colors.white,
                                    splashFactory: InkRipple.splashFactory,
                                    padding: EdgeInsets.symmetric(
                                        vertical: MediaQuery.of(context).size.height * 0.0225,
                                        horizontal: MediaQuery.of(context).size.width * 0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      side: BorderSide(
                                          color: treatmentController.text.isNotEmpty ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.3),
                                          width: 2),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'Crear cita',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.06,
                                      color: AppColors.primaryColor,
                                        ))))
                          ])))
                ])
              ]),

              ///timer
              if (isTimerShow)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isTimerShow = false;
                    });
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black54.withOpacity(0.27),
                    ),
                  ),
                ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.11,
                child: Visibility(
                  visible: isTimerShow,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 1,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.365,
                        ),
                        TitleContainer(
                          child: Text(
                            'Hora:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FieldsPading(
                          child: FieldsToWrite(
                            fillColor: Colors.white,
                            labelText: 'HH:MM',
                            readOnly: true,
                            controller: _timeController,
                            suffixIcon: const Icon(Icons.access_time),
                            onTap: () {
                              setState(() {
                                if (isTimerShow == false) {
                                  isTimerShow = true;
                                } else if (isTimerShow == true) {
                                  isTimerShow = false;
                                }
                              });
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                          ),
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.025,
                            left: MediaQuery.of(context).size.width * 0.038,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black54, width: 0.5),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TimerFly(onTimeChoose: _onTimeChoose),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              ///calendario
              if (_showCalendar)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCalendar = false;
                    });
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black54.withOpacity(0.27),
                    ),
                  ),
                ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.11,
                child: Visibility(
                  visible: _showCalendar,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        TitleContainer(
                          child: Text(
                            'Fecha:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width * 0.02,
                              horizontal: MediaQuery.of(context).size.width * 0.026),
                          child: FieldsToWrite(
                            fillColor: Colors.white,
                            readOnly: true,
                            labelText: 'DD/M/AAAA',
                            controller: _dateController,
                            suffixIcon: const Icon(Icons.calendar_today),
                            onTap: () {
                              setState(() {
                                !_showCalendar
                                    ? _showCalendar = true
                                    : _showCalendar = false;
                              });
                            },
                          ),
                        ),
                        CalendarContainer(
                          child: CalendarioCita(
                              onDayToAppointFormSelected: _onDateToAppointmentForm),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              ///widgetChooseDr
              if (_showdrChooseWidget)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black54.withOpacity(0.27),
                  ),
                ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.11,
                child: Visibility(
                  visible: _showdrChooseWidget,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        TitleContainer(
                          child: Text(
                            'Doctor: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.02,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.026),
                          child: TextFormField(
                            controller: _drSelected,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Seleccione una opción...',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                size: MediaQuery.of(context).size.width * 0.085,
                                color: AppColors.primaryColor,
                              ),
                              enabledBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1,
                                  )
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              setState(() {
                                  _showdrChooseWidget =
                                      _showdrChooseWidget ? false : true;
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.025),
                          child: DoctorsMenu(onAssignedDoctor: _onAssignedDoctor, optSelectedToRecieve: _optSelected),
                        )
                      ])))),
              Visibility(
            visible: showBlurr,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: Colors.black54.withOpacity(0.3),
              ),
            ),
          )
        ]))));
  }
}
