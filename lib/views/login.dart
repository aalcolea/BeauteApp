import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../styles/ladingDraw.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isDocLog = true;
  int userIdHelper = 0;
  bool showPinEntryScreen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LadingDraw(),
        Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.32),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: MediaQuery.of(context).size.height * 0.21,
                  backgroundImage:
                      const AssetImage("assets/imgLog/logoBeauteWhite.png"),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.065,
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.095,
                  right: MediaQuery.of(context).size.width * 0.095,
                  bottom: MediaQuery.of(context).size.width * 0.065,
                ),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPinEntryScreen = true;
                        isDocLog = true;
                        userIdHelper = 1;
                        /*   Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PinEntryScreen(
                                  userId: 1,
                                  docLog: isDocLog,
                                )),
                      );*/
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 10,
                      surfaceTintColor: const Color(0xFF4F2263),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Color(0xFF4F2263), width: 2),
                      ),
                      backgroundColor: const Color(0xFF4F2263),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.035),
                          child: Image.asset(
                            'assets/imgLog/docWhite.png',
                            width: MediaQuery.of(context).size.width * 0.08,
                            height: MediaQuery.of(context).size.width * 0.08,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.015,
                              right: MediaQuery.of(context).size.width * 0.15),
                          height: MediaQuery.of(context).size.width * 0.09,
                          width: MediaQuery.of(context).size.width * 0.006,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(width: 0.5),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Doctor1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.065,
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.095,
                  right: MediaQuery.of(context).size.width * 0.095,
                  bottom: MediaQuery.of(context).size.width * 0.065,
                ),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPinEntryScreen = true;
                        userIdHelper = 2;
                        isDocLog = true;
                        /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PinEntryScreen(
                                  userId: 2,
                                  docLog: isDocLog,
                                )),
                      );*/
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 10,
                      surfaceTintColor: const Color(0xFF4F2263),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Color(0xFF4F2263), width: 2),
                      ),
                      backgroundColor: const Color(0xFF4F2263),
                    ),
                    child: Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                left:
                                    MediaQuery.of(context).size.width * 0.035),
                            child: Image.asset(
                                'assets/imgLog/docWhite.png') /*Icon(
                            Icons.person,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.1,
                          ),*/
                            ),
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.015,
                              right: MediaQuery.of(context).size.width * 0.15),
                          height: MediaQuery.of(context).size.width * 0.09,
                          width: MediaQuery.of(context).size.width * 0.006,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(width: 0.5),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Doctor2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.065,
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.095,
                    right: MediaQuery.of(context).size.width * 0.095,
                    bottom: MediaQuery.of(context).size.width * 0.08),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPinEntryScreen = true;
                        userIdHelper = 3;
                        isDocLog = false;
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PinEntryScreen(
                                userId: 3,
                                docLog: isDocLog,
                              )),
                        );*/
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 10,
                      surfaceTintColor: const Color(0xFF4F2263),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Color(0xFF4F2263), width: 2),
                      ),
                      backgroundColor: const Color(0xFF4F2263),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.035),
                          child: Image.asset('assets/imgLog/assiWhite.png'),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.015,
                              right: MediaQuery.of(context).size.width * 0.15),
                          height: MediaQuery.of(context).size.width * 0.09,
                          width: MediaQuery.of(context).size.width * 0.006,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(width: 0.5),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Asistente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.003,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4F2263),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(2, -0),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),

        ///
        Visibility(
          visible: showPinEntryScreen,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PinEntryScreen(
              userId: userIdHelper,
              docLog: isDocLog,
              onCloseScreeen: (closeScreen) {
                setState(() {
                  closeScreen == true
                      ? showPinEntryScreen = false
                      : showPinEntryScreen == true;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
