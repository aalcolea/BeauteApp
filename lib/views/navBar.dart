import 'package:beaute_app/inventory/admin.dart';
import 'package:beaute_app/views/admin/assistantAdmin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../forms/alertForm.dart';
import '../globalVar.dart';
import '../services/auth_service.dart';

class navBar extends StatefulWidget {
  final bool isDoctorLog;
  final void Function(bool) onShowBlur;
  final Function(int) onItemSelected;
  final String currentScreen;

  const navBar({super.key, required this.onItemSelected, required this.onShowBlur, required this.isDoctorLog, required this.currentScreen});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {

  void closeMenu(BuildContext context){
    Navigator.of(context).pop();
  }

  Future<void> createAlert() async {
    Navigator.of(context).pop();
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return AlertForm(isDoctorLog: widget.isDoctorLog);
    }).then((_){
      widget.onShowBlur(false);
    });
  }

  @override
  void initState() {
    super.initState();
    print('currentScreen ${widget.currentScreen}');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.17),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 30, left: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width*0.05,
                      child: SvgPicture.asset(
                        'assets/imgLog/drIcon.svg',
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        height: MediaQuery.of(context).size.width*0.067,
                      ),
                      backgroundColor: Color(0XFF4F2263),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(SessionManager.instance.Nombre,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.05, color: Color(0XFF4F2263))),
                            Text('Slogan here')
                          ],
                        )
                    )
                  ]
              ),
            ),
            InkWell(
              onTap: widget.currentScreen == 'agenda' ? Navigator.of(context).pop : (){
                Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => AssistantAdmin(docLog: false),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              child: Container(
                padding: EdgeInsets.only(left: 20),
                width: MediaQuery.of(context).size.width,
                height: widget.currentScreen == 'agenda' ? MediaQuery.of(context).size.height*0.07 : MediaQuery.of(context).size.height*0.06,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: widget.currentScreen == 'agenda' ? Border.all(color: Color(0XFF4F2263)) : Border(left: BorderSide.none, top: BorderSide(color: Color(0XFF4F2263))),
                  color: widget.currentScreen == 'agenda' ? Color(0XFF4F2263) : Colors.transparent,
                  boxShadow: widget.currentScreen == 'agenda' ? [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, MediaQuery.of(context).size.width * 0.001),
                      blurRadius: 10,
                    )
                  ] : null,
                ),
                child: Text(
                    'Agenda',
                    style: widget.currentScreen == 'agenda' ? TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width*0.05,
                        color: Colors.white
                    ) : TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width*0.05,
                        color: Color(0XFF4F2263)
                    ),
                ),
              ),
            ),
            InkWell(
              onTap: widget.currentScreen == 'inventario' ? Navigator.of(context).pop : (){
                Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => adminInv(),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              child: Container(
                padding: EdgeInsets.only(left: 20),
                width: MediaQuery.of(context).size.width,
                height: widget.currentScreen == 'agenda' ? MediaQuery.of(context).size.height*0.06 : MediaQuery.of(context).size.height*0.07,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: widget.currentScreen == 'agenda' ? Border(left: BorderSide.none, bottom: BorderSide(color: Color(0XFF4F2263))) : Border.all(color: Color(0XFF4F2263)),
                  color: widget.currentScreen == 'agenda' ? Colors.transparent : Color(0XFF4F2263),
                  boxShadow: widget.currentScreen == 'agenda' ? null : [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, MediaQuery.of(context).size.width * 0.001),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Text(
                  'Punto de venta',
                  style: widget.currentScreen == 'agenda' ? TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width*0.05,
                      color: Color(0XFF4F2263)
                  ) : TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width*0.05,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !widget.isDoctorLog,
              child: Container(
              padding: EdgeInsets.only(top:40),
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      widget.onShowBlur(true);
                      createAlert();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0XFF4F2263), width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size(170, 55),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 5.0,
                    shadowColor: Colors.black54,
                  ),
                  child: Text(
                    'Mandar alerta',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width*0.05,
                        color: Color(0XFF4F2263)
                    ),
                  )
              ),
            ),),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.03),
                alignment: Alignment.bottomCenter,
                child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            PinEntryScreenState().logout(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.exit_to_app, color: Color(0XFF4F2263)),
                              SizedBox(width: 10),
                              Text('Cerrar sesion', style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05, color: Color(0XFF4F2263)))
                            ],
                          )),
                    ],
                  ),
              )
            )
          ],
        ),
      ),);
  }
}
