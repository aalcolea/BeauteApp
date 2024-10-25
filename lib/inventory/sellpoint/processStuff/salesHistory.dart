import 'dart:ui';
import 'package:beaute_app/inventory/sellpoint/processStuff/services/salesServices.dart';
import 'package:beaute_app/inventory/sellpoint/processStuff/utils/ticketsList.dart';
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

  late String formattedDate;
  late KeyboardVisibilityManager keyboardVisibilityManager;
  //
  double? screenWidth;
  double? screenHeight;
  bool showBlurr = false;
  int blurShowed = 0;
  int selectedPage = 0;
  //
  TextEditingController seekController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode seekNode = FocusNode();
  FocusNode dateNode = FocusNode();
  PageController pageController = PageController();

  List<Map<String, dynamic>> tickets = [];

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      DateTime parsedDate = DateTime.parse(dateToAppointmentForm);
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
      dateController.text = formattedDate;
      showBlurr = showCalendar;
    });
  }

  void _onShowBlurr(int showBlurr) {
    setState(() {
      blurShowed = showBlurr;
      if (blurShowed == 0) {
        this.showBlurr = false;
      } else {
        this.showBlurr = true;
      }
      print(blurShowed);
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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors2.calendarBg,
                leadingWidth: MediaQuery.of(context).size.width,
                pinned: true,
                leading: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.back,
                        size: MediaQuery.of(context).size.width * 0.08,
                        color: AppColors2.primaryColor,
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildTabButton('Historial de ventas', 0),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.005,
                            height: MediaQuery.of(context).size.width * 0.1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: AppColors2.primaryColor.withOpacity(0.7),
                            ),
                          ),
                          _buildTabButton('Ventas por dia', 1)
                        ]
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors2.calendarBg,
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.005, bottom: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: AppColors2.calendarBg,
                              ),
                              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.width * 0.105,
                              child: TextFormField(
                                readOnly: true,
                                controller: dateController,
                                focusNode: dateNode,
                                decoration: InputDecoration(
                                  isDense: true,
                                    floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                                    hintText: selectedPage == 0 ? 'Fecha' : formattedDate,
                                  hintStyle: TextStyle(
                                    color: AppColors2.primaryColor.withOpacity(0.3),
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors2.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors2.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors2.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors2.primaryColor,
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                ),
                                onTap: (){
                                  setState(() {
                                    print('tap');
                                    showBlurr = true;
                                    blurShowed = 1;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppColors2.calendarBg,
                                ),
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
                                      color: AppColors2.primaryColor.withOpacity(0.3),
                                      fontSize: MediaQuery.of(context).size.width * 0.035,
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors2.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors2.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors2.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: AppColors2.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                ),
                              )
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
                              color: AppColors2.calendarBg,
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
                  controller: pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      selectedPage = page;
                    });
                  },
                  children: [
                    Ticketslist(onShowBlur: _onShowBlurr),
                    SalesList(onShowBlur: _onShowBlurr,),
                  ],
                ),
              ),
            ],
          ),
          blurShowed == 1 ? Visibility(
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
                                color: AppColors2.primaryColor,
                                fontSize: MediaQuery.of(context).size.width * 0.03,
                              ),
                              filled: true,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: AppColors2.primaryColor, width: 2.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: AppColors2.primaryColor, width: 2.0),
                              ),
                            ),
                            style: TextStyle(
                                color: AppColors2.primaryColor,
                                fontSize: MediaQuery.of(context).size.width * 0.035
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.03),
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03, bottom: MediaQuery.of(context).size.width * 0.03),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors2.primaryColor, width: 2.0),
                              color: AppColors2.calendarBg,
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
          ) : Visibility(
              visible: showBlurr,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showBlurr = false;
                      blurShowed = 0;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black54.withOpacity(0.3),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int pageIndex) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedPage = pageIndex;
          pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 250), curve: Curves.linear);
        });
      },
      child: Text(
        textAlign: TextAlign.center,
        title,
        style: selectedPage == pageIndex
            ? TextStyle(
          color: AppColors2.primaryColor,
          fontSize: MediaQuery.of(context).size.width * 0.06,
          fontWeight: FontWeight.bold,
        )
            : TextStyle(
          color: AppColors2.primaryColor.withOpacity(0.2),
          fontSize: MediaQuery.of(context).size.width * 0.035,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
