import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../services/auth_service.dart';
class navBar extends StatefulWidget {

  final Function(int) onItemSelected;

  const navBar({super.key, required this.onItemSelected});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {

  void closeMenu(BuildContext context){
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.2),
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width*0.1,
                    child: SvgPicture.asset(
                      'assets/imgLog/drIcon.svg',
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      height: MediaQuery.of(context).size.width*0.13,
                    ),
                    backgroundColor: Color(0XFF4F2263)),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.02, bottom: MediaQuery.of(context).size.width*0.1), child: Text('Asistente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.08, color: Color(0XFF4F2263)))),
                ],
              )
            ),
            Container(
              padding: EdgeInsets.only(left: 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.1,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0XFF4F2263)),
                  color: Color(0XFF4F2263),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, MediaQuery.of(context).size.width * 0.001),
                      blurRadius: 10,
                    )
                  ]
              ),
              child: InkWell(
                onTap: (){

                },
                child: Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.08, color: Colors.white)),
              ),
            ),
            Container(
                padding: EdgeInsets.only(left: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.08,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide.none, bottom: BorderSide(color: Color(0XFF4F2263))),
                  color: Colors.transparent,
                ),
                child: InkWell(
                onTap: (){

                },
                child: Text('Punto de venta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.065, color: Color(0XFF4F2263))),
                ),
            ),
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
