import 'dart:ui';
import 'package:beaute_app/inventory/sellpoint/processStuff/services/salesServices.dart';
import 'package:beaute_app/inventory/sellpoint/processStuff/utils/listenerRemoverOL.dart';
import 'package:beaute_app/inventory/sellpoint/processStuff/utils/sales/calendarSales.dart';
import 'package:beaute_app/inventory/sellpoint/processStuff/utils/ticketsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../agenda/calendar/calendarioScreenCita.dart';
import '../../themes/colors.dart';
import '../../../regEx.dart';
import '../../kboardVisibilityManager.dart';
import '../processStuff/utils/salesList.dart';

class SalesHistory extends StatefulWidget {
  const SalesHistory({super.key});

  @override
  State<SalesHistory> createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> with SingleTickerProviderStateMixin {

  ListenerremoverOL listenerremoverOL = ListenerremoverOL();
  late AnimationController animationController;
  late Animation<double> opacidad;
  late String formattedDate;
  late KeyboardVisibilityManager keyboardVisibilityManager;
  //
  double? screenWidth;
  double? screenHeight;
  double optSize = 0;
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

  void onOptnSize(double optSize){
    setState(() {
      this.optSize = optSize;
    });
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      animationController.reverse().then((_){
        showBlurr = showCalendar;
        animationController.reset();
      });
      DateTime parsedDate = DateTime.parse(dateToAppointmentForm);
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
      dateController.text = formattedDate;
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
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.addListener((){
      setState(() {
        print('stat ${animationController.status}');
      });
    });
    keyboardVisibilityManager = KeyboardVisibilityManager();
    DateTime now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    formattedDate = formatter.format(now);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }
  bool isLoading = false;

  void removerOverL(){
    listenerremoverOL.setChange(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgColor,
                leadingWidth: MediaQuery.of(context).size.width,
                pinned: true,
                leading: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
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
                      Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                          _buildTabButton('Tickets', 0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.01,
                          height: MediaQuery.of(context).size.width * 034,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        _buildTabButton('Ventas', 1),
                      ],
                    )),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.12,)

                    ],
                  ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.bgColor,
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
                                color: AppColors.bgColor,
                              ),
                              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                              width: MediaQuery.of(context).size.width * 0.32,
                              height: MediaQuery.of(context).size.width * 0.105,
                              child: TextFormField(
                                enableInteractiveSelection: false,
                                readOnly: true,
                                controller: dateController,
                                focusNode: dateNode,
                                decoration: InputDecoration(
                                  isDense: true,
                                    floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                                    hintText: formattedDate,
                                  hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                ),
                                onTap: (){
                                  setState(() {
                                    showBlurr = true;
                                    blurShowed = 1;
                                    animationController.forward();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppColors.bgColor,
                                ),
                                child: TextFormField(
                                  controller: seekController,
                                  focusNode: seekNode,
                                  inputFormatters: [
                                    RegEx(type: InputFormatterType.alphanumeric),
                                  ],
                                  decoration: InputDecoration(
                                    isDense: false,
                                    constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.width * 0.105,
                                    ),
                                    hintText: 'Buscar por nombre o categoria...',
                                    hintStyle: TextStyle(
                                      color: AppColors.primaryColor.withOpacity(0.3),
                                      fontSize: MediaQuery.of(context).size.width * 0.035,
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.0425,
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
                              color: AppColors.bgColor,
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
                    Ticketslist(onShowBlur: _onShowBlurr, onOptnSize: onOptnSize, listenerremoverOL: listenerremoverOL,),
                    SalesList(onShowBlur: _onShowBlurr,),
                  ],
                ),
              ),
            ],
          ),
          blurShowed == 1 ? AnimatedBuilder(
              animation: animationController,
              child: Visibility(
                visible: showBlurr,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      animationController.reverse().then((_){
                        showBlurr = false;
                        animationController.reset();
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.blackColor.withOpacity(0.1),
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.25,
                            bottom: MediaQuery.of(context).size.width * 0.03,
                            left: MediaQuery.of(context).size.width * 0.02,
                            right: MediaQuery.of(context).size.width * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.03),
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03, bottom: MediaQuery.of(context).size.width * 0.03),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.45,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent, width: 2.0),
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ), child: SalesCalendar(
                                onDayToAppointFormSelected: _onDateToAppointmentForm, dateInit: dateController.text),
                              ),
                            ],
                          )
                      ),
                    ),
                  ),
                ),
              ),
              builder: (context, selCalendarOp,){
                return Opacity(
                    opacity: opacidad.value,
                    child: selCalendarOp);
              }) : Visibility(
              visible: showBlurr,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: GestureDetector(
                  onTap: () {
                    removerOverL();
                    setState(() {
                      showBlurr = false;
                      blurShowed = 0;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.blackColor.withOpacity(0.1),
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
          color: AppColors.primaryColor,
          fontSize: MediaQuery.of(context).size.width * 0.06,
          fontWeight: FontWeight.bold,
        )
            : TextStyle(
          color: AppColors.primaryColor.withOpacity(0.2),
          fontSize: MediaQuery.of(context).size.width * 0.035,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
