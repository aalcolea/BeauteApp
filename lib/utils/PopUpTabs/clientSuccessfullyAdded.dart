import 'package:flutter/material.dart';
import 'dart:ui';

void showClienteSuccessfullyAdded(BuildContext context, Widget widget, VoidCallback onDialogClose) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDialogClose();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.075,
                      ),
                      child: Text(
                        '¡Cliente agregado!',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.085,
                          color: const Color(0xFF4F2263),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

          ),
        ],
      );
    },
  ).then((_) {
    onDialogClose();
  });
}