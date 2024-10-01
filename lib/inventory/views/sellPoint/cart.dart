import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Cart extends StatefulWidget {

  final void Function(
      bool,
      ) onHideBtnsBottom;

  const Cart({super.key, required this.onHideBtnsBottom});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  double totalCart = 0;
  final FocusNode focusNode = FocusNode();
  final TextEditingController cantidadController = TextEditingController();
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late KeyboardVisibilityController keyboardVisibilityController;
  bool visibleKeyboard = false;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
            widget.onHideBtnsBottom(visibleKeyboard);
          });
        });
  }

  /*void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }*/

  @override
  void initState() {
    super.initState();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    cantidadController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.01,
                  bottom: MediaQuery.of(context).size.width * 0.01,
                  left: MediaQuery.of(context).size.width * 0.03,
                  right: MediaQuery.of(context).size.width * 0.03
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFF4F2263).withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final widthItem1 = constraints.maxWidth * 0.41;
                    final widthItem2 = constraints.maxWidth * 0.33;
                    return Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: widthItem1,
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFF4F2263).withOpacity(0.1), width: 2))
                          ),
                          child: Text(
                            'Producto',
                            style: TextStyle(
                              color: Color(0xFF4F2263),
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: widthItem2,
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFF4F2263).withOpacity(0.1), width: 2))
                          ),
                          child: Text(
                            'Cant.',
                            style: TextStyle(
                              color: Color(0xFF4F2263),
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          child: Text(
                            'Precio',
                            style: TextStyle(
                              color: Color(0xFF4F2263),
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.width * 0.1),
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          final widthItem1 = constraints.maxWidth * 0.382;
                          final widthItem2 = constraints.maxWidth * 0.34;
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.06, left: MediaQuery.of(context).size.width * 0.02),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: widthItem1,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Producto $index',
                                                style: TextStyle(
                                                  color: Color(0xFF4F2263),
                                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                                ),
                                              ),
                                              Text(
                                                'Codigo $index',
                                                style: TextStyle(
                                                    color: Color(0xFF4F2263).withOpacity(0.3),
                                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.zero,
                                          width: widthItem2,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                                                height: MediaQuery.of(context).size.height * 0.035,
                                                width: MediaQuery.of(context).size.width * 0.08,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF4F2263).withOpacity(0.5),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.005,
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
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context).size.width * 0.07,
                                                height: MediaQuery.of(context).size.height * 0.035,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Color(0xFF4F2263).withOpacity(0.1),
                                                      width: 2
                                                  ),
                                                ),
                                                child: TextFormField(
                                                  controller: cantidadController,
                                                  focusNode: focusNode,
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical: TextAlignVertical.center,
                                                  //initialValue: '$index',
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                                height: MediaQuery.of(context).size.height * 0.035,
                                                width: MediaQuery.of(context).size.width * 0.08,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF4F2263).withOpacity(0.5),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(context).size.width * 0.005,
                                                    ),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                  ),
                                                  onPressed: () {

                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.add,
                                                    color: Colors.white,
                                                    size: MediaQuery.of(context).size.width * 0.045,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                                            alignment: Alignment.topRight,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '\$0',
                                                  style: TextStyle(
                                                    color: Color(0xFF4F2263),
                                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                                  ),
                                                ),
                                                Text(
                                                  'MXN',
                                                  style: TextStyle(
                                                      color: Color(0xFF4F2263).withOpacity(0.3),
                                                      fontSize: MediaQuery.of(context).size.width * 0.04
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        }
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.03,
              right: MediaQuery.of(context).size.width * 0.03,
              top: MediaQuery.of(context).size.width * 0.0,
              bottom: MediaQuery.of(context).size.width * 0.01
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    color: Color(0xFF4F2263),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$totalCart',
                      style: TextStyle(
                        color: Color(0xFF4F2263),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                      ),
                    ),
                    Text(
                      'MXN ',
                      style: TextStyle(
                        color: Color(0xFF4F2263).withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.width * 0.15,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.01,
                bottom: MediaQuery.of(context).size.width * 0.02,
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.03
            ),
            decoration: BoxDecoration(
              color: Color(0xFF4F2263),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Pagar',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.08,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
