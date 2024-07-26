import 'dart:ui';

import 'package:flutter/material.dart';

void showClienteSuccessfullyAdded(BuildContext context, Widget widget, bool isDoctorLog) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: Colors.black54.withOpacity(0.3),
            ),
          ),
          Center(
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.08),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(blurRadius: 3.5, offset: Offset(0, 0))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '¡Cita creada!',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.085,
                        color: const Color(0xFF4F2263),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        isDoctorLog == true ?
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/drScreen',
                          (Route<dynamic> route) => false,
                        ) : Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/assistantScreen',
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.03),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Inicio',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            color: const Color(0xFF4F2263),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
