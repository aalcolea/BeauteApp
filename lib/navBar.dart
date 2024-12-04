import 'dart:io';
import 'package:beaute_app/agenda/themes/colors.dart';
import 'package:beaute_app/inventory/admin.dart';
import 'package:beaute_app/agenda/views/admin/admin.dart';
import 'package:beaute_app/inventory/listenerPrintService.dart';
import 'package:beaute_app/inventory/print/printConnections.dart';
import 'package:beaute_app/inventory/print/selBT.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'agenda/forms/alertForm.dart';
import 'agenda/utils/showToast.dart';
import 'agenda/utils/toastWidget.dart';
import 'globalVar.dart';
import 'agenda/services/auth_service.dart';
import 'inventory/print/testPDF.dart';
import 'inventory/print/testPrint.dart';

class navBar extends StatefulWidget {
  final bool isDoctorLog;
  final void Function(bool) onShowBlur;
  final Function(PrintService)? onPrintServiceComunication;
  final PrintService? printServiceAfterInitConn;
  final BluetoothCharacteristic? btChar;
  final Function(int) onItemSelected;
  final void Function(bool) onLockScreen;
  final String currentScreen;
  final Function (bool)? onChooseBT;
  final SelBt? selBt;
  final Function (bool)? onResetBT;

  const navBar({super.key, required this.onItemSelected, required this.onShowBlur, required this.isDoctorLog, required this.currentScreen,
    this.onPrintServiceComunication, this.printServiceAfterInitConn, this.btChar, required this.onLockScreen, this.onChooseBT, this.selBt, this.onResetBT});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {

  PrintService printService = PrintService();
  bool? isConecct = false;
  FlutterBlue flutterBlue = FlutterBlue.instance;


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
        }).then((_){widget.onShowBlur(false);});
  }

  @override
  void initState() {
 /*   if(widget.printServiceAfterInitConn?.characteristic != null){
      setState(() {
        //printService = widget.printServiceAfterInitConn!;
        print('aquiFly $printService');
      });
    }*/
    if(widget.btChar != null){
      setState(() {
        printService.selectedDevice = widget.printServiceAfterInitConn?.selectedDevice;
        printService.isConnect = true;
        isConecct = true;
      });
    }else {
      setState(() {
        isConecct = false;
      });
    }
    printService.listenerPrintService.registrarObservador((newValue, newIsConnect) {
      setState(() {
        switch (newValue) {
          case 0:
            setState(() {//null
              isConecct = newIsConnect;
              widget.onLockScreen(true);
            });
          case 1:
            setState(() {//conectado
              isConecct = newIsConnect;
              widget.onPrintServiceComunication!(printService);
              widget.onLockScreen(false);

            });
            break;
          case 2://conect == false
            setState(() {
              print('disconect');
              isConecct = newIsConnect;
              widget.onPrintServiceComunication!(printService);
            });
            break;
          case 3://no encontro disp
            setState(() {
              print('not found navBar');
              isConecct = false;
              widget.onLockScreen(false);
            });
            break;
        }
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrintService>(
        create: (_) => printService,
        child: Consumer<PrintService>(
            builder: (context, printService, child){
              return  Drawer(
                  backgroundColor: AppColors3.whiteColor,
                  child: Stack(
                    children: [
                      Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.17),
                          child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 30, left: 20),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: MediaQuery.of(context).size.width*0.05,
                                          backgroundColor: AppColors3.primaryColor,
                                          child: SvgPicture.asset(
                                            'assets/imgLog/drIcon.svg',
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                            height: MediaQuery.of(context).size.width * 0.067,
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child:
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(SessionManager.instance.Nombre == 'Dulce' ? 'Nombre Asistente' : SessionManager.instance.Nombre,
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.05, color: AppColors3.primaryColor)),
                                                Text('Slogan here', style: TextStyle(color: AppColors3.primaryColor.withOpacity(0.8)),)
                                              ],
                                            )
                                        )
                                      ]
                                  ),
                                ),
                                InkWell(
                                  onTap: widget.currentScreen == 'agenda' ? Navigator.of(context).pop : (){
                                    isConecct ==  true ? printService.disconnect(context) : null;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute(
                                        builder: (context) => AssistantAdmin(docLog: widget.isDoctorLog),
                                      ),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    width: MediaQuery.of(context).size.width,
                                    height: widget.currentScreen == 'agenda' ? MediaQuery.of(context).size.height * 0.07 : MediaQuery.of(context).size.height * 0.06,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      border: widget.currentScreen == 'agenda' ? Border.all(color: AppColors3.primaryColor) : const Border(left: BorderSide.none, top: BorderSide(color: AppColors3.primaryColor)),
                                      color: widget.currentScreen == 'agenda' ? AppColors3.primaryColor : Colors.transparent,
                                      boxShadow: widget.currentScreen == 'agenda' ? [
                                        BoxShadow(
                                          color: Colors.black54,
                                          offset: Offset(0, MediaQuery.of(context).size.width * 0.001),
                                          blurRadius: 5,
                                        )
                                      ] : null,
                                    ),
                                    child: Text(
                                      'Agenda',
                                      style: widget.currentScreen == 'agenda' ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width*0.05,
                                          color: AppColors3.whiteColor
                                      ) : TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width*0.05,
                                          color: AppColors3.primaryColor
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: widget.currentScreen == 'inventario' ? Navigator.of(context).pop : (){
                                    Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute(
                                        builder: (context) => adminInv(docLog: widget.isDoctorLog),
                                      ),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    width: MediaQuery.of(context).size.width,
                                    height: widget.currentScreen == 'agenda' ? MediaQuery.of(context).size.height*0.06 : MediaQuery.of(context).size.height*0.07,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      border: widget.currentScreen == 'agenda' ? const Border(left: BorderSide.none, bottom: BorderSide(color: AppColors3.primaryColor)) : Border.all(color: AppColors3.primaryColor),
                                      color: widget.currentScreen == 'agenda' ? Colors.transparent : AppColors3.primaryColor,
                                      boxShadow: widget.currentScreen == 'agenda' ? null : [
                                        BoxShadow(
                                          color: Colors.black54,
                                          offset: Offset(0, MediaQuery.of(context).size.width * 0.001),
                                          blurRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      'Punto de venta',
                                      style: widget.currentScreen == 'agenda' ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width*0.05,
                                          color: AppColors3.primaryColor
                                      ) : TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width*0.05,
                                          color: AppColors3.whiteColor
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.currentScreen == 'inventario' ? true : false,
                                  child: InkWell(
                                      splashColor: AppColors3.primaryColor.withOpacity(0.1),
                                      onTap: isConecct == false ? (){
                                        setState(() {
                                          Platform.isIOS ? printService.scanForDevices(context) :
                                          printService.connectToBluetoothDevice(context);
                                        });
                                      } : (){
                                        setState(() {
                                          printService.disconnect(context);
                                          print('printService.disconnect(context,);');
                                        });
                                      },
                                      onLongPress: () async {
                                        bool isOn = await flutterBlue.isOn;
                                        if(isOn){
                                          widget.onChooseBT!(true);
                                        }else {
                                          if(mounted){
                                            showOverlay(context, const CustomToast(message: 'Encienda el Bluethoot'));
                                          }
                                        }
                                      },
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                            padding: const EdgeInsets.only(left: 20, top: 10),
                                            width: MediaQuery.of(context).size.width,
                                            alignment: Alignment.centerLeft,
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(context).size.width * 0.0,
                                                        right: MediaQuery.of(context).size.width * 0.04,
                                                      ),
                                                      child: Icon(
                                                        isConecct == null ? Icons.print_disabled_outlined : !isConecct! ?  Icons.print_disabled_outlined : Icons.print_outlined,
                                                        size: MediaQuery.of(context).size.width * 0.08,
                                                        color: AppColors3.primaryColor,),),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Impresora',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: MediaQuery.of(context).size.width*0.05,
                                                                color: AppColors3.primaryColor
                                                            ),
                                                          ),Text(
                                                            isConecct == null ? 'Conectando...' : isConecct! ? 'Conectada' : 'Desconectada',
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(context).size.width*0.04,
                                                                color: AppColors3.primaryColor.withOpacity(0.4)
                                                            ),
                                                          ),
                                                        ],
                                                      ),),
                                                    Visibility(
                                                      visible: isConecct == null ? true : false,
                                                      child: Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.12),
                                                          child: CircularProgressIndicator(
                                                            color: AppColors3.primaryColor.withOpacity(0.8),
                                                          )),),
                                                  ],
                                                ),
                                                SizedBox(height: MediaQuery.of(context).size.width * 0.02,),
                                                Divider(
                                                  thickness: 1.5,
                                                  indent: MediaQuery.of(context).size.width * 0.0,
                                                  endIndent: MediaQuery.of(context).size.width * 0.04,
                                                  color: AppColors3.primaryColor.withOpacity(0.3),
                                                  height: 5 ,
                                                ),
                                              ],
                                            )
                                        ),
                                      )
                                  ),),
                                Visibility(
                                  visible: !widget.isDoctorLog,
                                  child: Container(
                                    padding: const EdgeInsets.only(top:40),
                                    child: ElevatedButton(
                                        onPressed: (){
                                          setState(() {
                                            widget.onShowBlur(true);
                                            createAlert();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors3.whiteColor,
                                          side: const BorderSide(color: AppColors3.primaryColor, width: 1.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          minimumSize: Size(170, 55),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          elevation: 5.0,
                                          shadowColor: Colors.black54,
                                        ),
                                        child: Text(
                                          'Mandar alerta',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).size.width*0.05,
                                              color: AppColors3.primaryColor
                                          ),
                                        )
                                    ),
                                  ),),
                                IconButton(onPressed: (){
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => testPrint(),
                                    ),
                                  );

                                }, icon: Icon(Icons.ac_unit)),
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
                                                        const Icon(Icons.exit_to_app, color: AppColors3.primaryColor),
                                                        SizedBox(width: 10),
                                                        Text('Cerrar sesion', style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05, color: AppColors3.primaryColor))
                                                      ]))])))])),

                    ],
                  )
              );
            })
    );
  }
}