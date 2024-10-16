import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showConfirmSellDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Text(
                    'Confirmar venta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.07,
                      vertical: MediaQuery.of(context).size.height * 0.02),
                  child: Text(
                    'Estas seguro de que deseas enviar el carrito?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width * 0.03),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.red,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.width * 0.05,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width * 0.03),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.purpleAccent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.width * 0.05,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}
