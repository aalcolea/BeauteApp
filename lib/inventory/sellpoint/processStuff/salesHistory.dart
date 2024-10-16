import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../agenda/calendar/calendarioScreenCita.dart';
import '../../../agenda/themes/colors.dart';
import '../../../regEx.dart';
import '../../kboardVisibilityManager.dart';

class SalesHistory extends StatefulWidget {
  const SalesHistory({super.key});

  @override
  State<SalesHistory> createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> {

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
            physics: keyboardVisibilityManager.visibleKeyboard
                ? const BouncingScrollPhysics()
                : const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                leadingWidth: MediaQuery.of(context).size.width,
                backgroundColor: Colors.white,
                stretch: false,
                pinned: true,
                leading: Row(
                  children: [
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
                                    floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                                    hintText: 'Fecha',
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
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
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
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.width * 0.105,
                                  ),
                                  labelText: 'Buscar por nombre o categoria...',
                                  labelStyle: TextStyle(
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
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
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
                          child: Text(textAlign: TextAlign.left,
                              'Productos vendidos el ${dateController.text}'),
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
                    _buildSalesList(context), // Página para Historial de ventas
                    _buildSalesList(context), // Página para Ventas de hoy (puedes agregar lógica específica)
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
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.3,
                        bottom: MediaQuery.of(context).size.width * 0.03,
                        left: MediaQuery.of(context).size.width * 0.03,
                        right: MediaQuery.of(context).size.width * 0.03,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: MediaQuery.of(context).size.width * 0.105,
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.03,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.03,
                              vertical: MediaQuery.of(context).size.width * 0.03,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              'Fecha:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextFormField(
                            readOnly: true,
                            controller: dateController,
                            decoration: InputDecoration(
                              floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                              hintText: 'DD/MM/AA',
                              filled: true,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: AppColors.primaryColor),
                              ),
                            ),
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.03),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54, width: 0.5),
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

  Widget _buildSalesList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.0075,
                    horizontal: MediaQuery.of(context).size.width * 0.0247),
                title: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "'NOMBRE DEL PRODUCTO'",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Cant.: ",
                              style: TextStyle(
                                  color: AppColors.primaryColor.withOpacity(0.5),
                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                            ),
                            Text(
                              '10 pzs',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Precio unitario: ",
                              style: TextStyle(
                                  color: AppColors.primaryColor.withOpacity(0.5),
                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                            ),
                            Text(
                              '\$100',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Total: ",
                              style: TextStyle(
                                  color: AppColors.primaryColor.withOpacity(0.5),
                                  fontSize: MediaQuery.of(context).size.width * 0.035),
                            ),
                            Text(
                              '\$500',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppColors.primaryColor.withOpacity(0.7),
                thickness: MediaQuery.of(context).size.width * 0.004,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String title, int pageIndex) {
    return Container(
      decoration: selectedPage == pageIndex
          ? BoxDecoration(
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
          : BoxDecoration(
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
