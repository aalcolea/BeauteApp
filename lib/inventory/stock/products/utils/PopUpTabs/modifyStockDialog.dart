import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showModifyproductStockDialog(
    BuildContext context, String nombreProd, int cantProd, Future<void> Function() onDelete) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: IntrinsicHeight(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.015,
                left: MediaQuery.of(context).size.height * 0.02,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                            child: Text(
                              'Modificar stock',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.07,
                                color: const Color(0xFF4F2263),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            icon: const Icon(
                              CupertinoIcons.xmark,
                              color: Color(0xFF4F2263),
                            ),
                          )
                        ],
                      ),
                      Text(
                        '${nombreProd}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: Color(0xFF4F2263),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(40, 40),
                            backgroundColor: const Color(0xFF4F2263),
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.02,
                              vertical: MediaQuery.of(context).size.width * 0.02,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onPressed: () {

                          },
                          child: Icon(
                            CupertinoIcons.minus,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: TextFormField(
                            initialValue: '${cantProd}',
                            style: const TextStyle(
                                fontSize: 30
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4F2263),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4F2263),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(40, 40),
                            backgroundColor: const Color(0xFF4F2263),
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.02,
                              vertical: MediaQuery.of(context).size.width * 0.02,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onPressed: () {

                          },
                          child: Icon(
                            CupertinoIcons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.04,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      );
    },
  ).then((value) => value ?? false);
}
