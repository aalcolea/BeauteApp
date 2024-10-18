import 'dart:ui';
import 'package:beaute_app/inventory/sellpoint/processStuff/utils/todaySalesList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../agenda/calendar/calendarioScreenCita.dart';
import '../../../agenda/themes/colors.dart';
import '../../../regEx.dart';
import '../../kboardVisibilityManager.dart';
import '../processStuff/utils/salesList.dart';

class SalesHistory extends StatefulWidget {
  const SalesHistory({super.key});

  @override
  State<SalesHistory> createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> {

  List<Map<String, dynamic>> sales = [
    {'producto':'Shampoo para calvos', 'cant':10, 'precio_uni':100, 'fecha':'01-10-2024'},
    {'producto':'Botox de nalgas', 'cant':5, 'precio_uni':50, 'fecha':'13-06-2024'},
    {'producto':'Jirafa amarilla', 'cant':10, 'precio_uni':50, 'fecha':'16-01-2024'},
    {'producto':'Crema para pies', 'cant':2, 'precio_uni':500, 'fecha':'24-08-2024'},
    {'producto':'Agua de horchata', 'cant':10, 'precio_uni':25, 'fecha':'17-05-2024'},
  ];

  late String formattedDate;
  late KeyboardVisibilityManager keyboardVisibilityManager;
  //
  double? screenWidth;
  double? screenHeight;
  bool showBlurr = false;
  int selectedPage = 0;
  //
  TextEditingController seekController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode seekNode = FocusNode();
  FocusNode dateNode = FocusNode();

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      DateTime parsedDate = DateTime.parse(dateToAppointmentForm);
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
      dateController.text = formattedDate;
      showBlurr = showCalendar;
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
    // TODO: implement initState
    keyboardVisibilityManager = KeyboardVisibilityManager();
    super.initState();
    DateTime now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    formattedDate = formatter.format(now);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                leadingWidth: MediaQuery.of(context).size.width,
                backgroundColor: Colors.white,
                stretch: false,
                pinned: true,
                leading: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primaryColor, width: 2.0),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.back,
                          size: MediaQuery.of(context).size.width * 0.08,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _buildTabButton('Historial de ventas', 0),
                            _buildTabButton('Ventas de hoy', 1),
                          ]),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primaryColor, width: 2.0),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.back,
                          size: MediaQuery.of(context).size.width * 0.08,
                          color: AppColors.calendarBg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(

                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.005),
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.width * 0.105,
                              child: TextFormField(
                                readOnly: true,
                                controller: dateController,
                                focusNode: dateNode,
                                decoration: InputDecoration(
                                  enabled: selectedPage == 0 ? true : false,
                                  isDense: true,
                                    floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                                    hintText: selectedPage == 0 ? 'Fecha' : formattedDate,
                                  hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                ),
                                onTap: (){
                                  setState(() {
                                    print('tap');
                                    showBlurr = true;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.02,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: seekController,
                                focusNode: seekNode,
                                inputFormatters: [
                                  RegEx(type: InputFormatterType.alphanumeric),
                                ],
                                decoration: InputDecoration(
                                  isDense: true,
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.width * 0.105,
                                  ),
                                  hintText: 'Buscar por nombre o categoria...',
                                  hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: dateController.text.isEmpty ? false : true,
                        child: Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.03),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            textAlign: TextAlign.left,
                            '*Productos vendidos el ${dateController.text}',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: PageView(
                  controller: PageController(initialPage: selectedPage),
                  onPageChanged: (int page) {
                    setState(() {
                      selectedPage = page;
                    });
                  },
                  children: [
                    buildSalesList(context),
                    buildTodaySalesList(context),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: showBlurr,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showBlurr = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54.withOpacity(0.3),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.2943,
                        bottom: MediaQuery.of(context).size.width * 0.03,
                        left: MediaQuery.of(context).size.width * 0.03,
                        right: MediaQuery.of(context).size.width * 0.03,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            textAlign: TextAlign.center,
                            readOnly: true,
                            controller: dateController,
                            decoration: InputDecoration(
                              isDense: true,
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.width * 0.105,
                                maxWidth: MediaQuery.of(context).size.width * 0.25
                              ),
                              floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                              hintText: 'DD-MM-AAAA',
                              hintStyle: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: MediaQuery.of(context).size.width * 0.03,
                              ),
                              filled: true,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: MediaQuery.of(context).size.width * 0.035
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.03),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryColor, width: 3.0),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CalendarioCita(
                                onDayToAppointFormSelected: _onDateToAppointmentForm),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int pageIndex) {
    return Container(
      decoration: selectedPage == pageIndex
          ? const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primaryColor, width: 2.0),
          left: BorderSide(color: AppColors.primaryColor, width: 2.0),
          right: BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      )
          : const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedPage = pageIndex;
          });
        },
        child: Text(
          textAlign: TextAlign.center,
          title,
          style: selectedPage == pageIndex
              ? TextStyle(
            color: AppColors.primaryColor,
            fontSize: MediaQuery.of(context).size.width * 0.063,
            fontWeight: FontWeight.bold,
          )
              : TextStyle(
            color: AppColors.primaryColor.withOpacity(0.5),
            fontSize: MediaQuery.of(context).size.width * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
