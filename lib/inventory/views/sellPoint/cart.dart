import 'dart:async';

import 'package:beaute_app/inventory/cartProvider.dart';
import 'package:beaute_app/inventory/views/sellPoint/styles/cartStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  final void Function(
      bool,
      ) onHideBtnsBottom;
  const Cart({super.key, required this.onHideBtnsBottom});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  List<TextEditingController> cantControllers = [];
  List<int> cantHelper = [];

  double totalCart = 0;

  final FocusNode focusNode = FocusNode();
  final TextEditingController cantidadController = TextEditingController();
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late KeyboardVisibilityController keyboardVisibilityController;
  bool visibleKeyboard = false;
  int oldIndex = 0;

  void itemCount (index, action){
    if(action == false){
      cantHelper[index]--;
      cantHelper[index] < 0 ? cantHelper[index] = 0 : cantControllers[index].text = cantHelper[index].toString();
    }else{
      cantHelper[index]++;
      cantControllers[index].text = cantHelper[index].toString();
    }
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
            widget.onHideBtnsBottom(visibleKeyboard);
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
  }

  @override
  void didChangeDependencies() {
    final cartProvider = Provider.of<CartProvider>(context);
    cantControllers.clear();
    totalCart = 0;
    for (int i = 0; i < cartProvider.cart.length; i++) {
      cantControllers.add(TextEditingController(text: cartProvider.cart[i]['cant_cart'].toString()));
      totalCart += cartProvider.cart[i]['price'] * cartProvider.cart[i]['cant_cart'];
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    focusNode.dispose();
    for (var controller in cantControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.02,
                  bottom: MediaQuery.of(context).size.width * 0.01,
                  left: MediaQuery.of(context).size.width * 0.01,
                  right: MediaQuery.of(context).size.width * 0.01
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4F2263).withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final widthItem1 = constraints.maxWidth * 0.382;
                    final widthItem2 = constraints.maxWidth * 0.38;
                    return Background(widthItem1: widthItem1, widthItem2: widthItem2);/// termina codigo que sirve para el background
                  }
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.width * 0.1),
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          final widthItem1 = constraints.maxWidth * 0.352;
                          final widthItem2 = constraints.maxWidth * 0.4;
                          return ListView.builder(
                            itemCount: cartProvider.cart.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02,
                                    top: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.02
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: widthItem1,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${cartProvider.cart[index]['product']}',
                                                style: TextStyle(
                                                  color: const Color(0xFF4F2263),
                                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                                ),
                                              ),
                                              Text(
                                                'Codigo ${cartProvider.cart[index]['product_id']}',
                                                style: TextStyle(
                                                    color: Color(0xFF4F2263).withOpacity(0.3),
                                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width: widthItem2,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size(0, 0),
                                                          backgroundColor: const Color(0xFF4F2263).withOpacity(0.5),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: MediaQuery.of(context).size.width * 0.02,
                                                              vertical: MediaQuery.of(context).size.width * 0.02,
                                                          ),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          cartProvider.decrementElement(cartProvider.cart[index]['product_id']);
                                                          setState(() {
                                                            bool action = false;
                                                            itemCount(index, action);
                                                          });
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons.minus,
                                                          color: Colors.white,
                                                          size: MediaQuery.of(context).size.width * 0.04,
                                                        ),
                                                      ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.12,
                                                      child: TextFormField(
                                                        style: const TextStyle(
                                                          fontSize: 25
                                                        ),
                                                        keyboardType: TextInputType.number,
                                                        controller: cantControllers[index],
                                                        textAlign: TextAlign.center,
                                                        textAlignVertical: TextAlignVertical.top,
                                                        decoration: InputDecoration(
                                                          isCollapsed: true,
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: const BorderSide(
                                                              color: Color(0xFF4F2263),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: const BorderSide(
                                                              color: Colors.black54,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size(0, 0),
                                                          backgroundColor: const Color(0xFF4F2263).withOpacity(0.5),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: MediaQuery.of(context).size.width * 0.02,
                                                            vertical: MediaQuery.of(context).size.width * 0.02,
                                                          ),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          cartProvider.addElement(cartProvider.cart[index]['product_id']);
                                                          setState(() {
                                                            bool action = true;
                                                            itemCount(index, action);
                                                          });
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons.add,
                                                          color: Colors.white,
                                                          size: MediaQuery.of(context).size.width * 0.04,
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
                                                  '\$${cartProvider.cart[index]['cant_cart'] * cartProvider.cart[index]['price']}',
                                                  style: TextStyle(
                                                    color: const Color(0xFF4F2263),
                                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                                  ),
                                                ),
                                                Text(
                                                  'MXN',
                                                  style: TextStyle(
                                                      color: const Color(0xFF4F2263).withOpacity(0.3),
                                                      fontSize: MediaQuery.of(context).size.width * 0.04
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
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
                        color: const Color(0xFF4F2263).withOpacity(0.3),
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
              color: const Color(0xFF4F2263),
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
