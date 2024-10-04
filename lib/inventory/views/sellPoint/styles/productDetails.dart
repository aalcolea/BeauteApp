import 'dart:async';
import 'package:beaute_app/inventory/forms/styles/productFormStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../../forms/categoryBox.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  //
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocus = FocusNode();
  TextEditingController precioController = TextEditingController();
  FocusNode precioFocus = FocusNode();
  TextEditingController barCodeController = TextEditingController();
  FocusNode barCodeFocus = FocusNode();
  //
  bool editProd = false;

  double ? screenWidth;
  double ? screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  void changeFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
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
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: visibleKeyboard ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              leadingWidth: MediaQuery.of(context).size.width,
              backgroundColor: Colors.white,
              stretch: false,
              pinned: true,
              leading: Row(
                children: [
                  Visibility(
                      visible: editProd,
                      child: TextButton(onPressed: (){
                        setState(() {
                          editProd = false;
                        });
                      }, child: Text(' Cancelar',
                      style: TextStyle(
                        color: const Color(0xFF4F2263),
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),), )),
                  Visibility(
                    visible: !editProd,
                    child: IconButton(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      CupertinoIcons.back,
                      size: MediaQuery.of(context).size.width * 0.08,
                      color: const Color(0xFF4F2263),
                    ),
                  ),),
                  Visibility(
                    visible: !editProd,
                    child: Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0), child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          textAlign: TextAlign.start,
                          'Producto 1',
                          style: TextStyle(
                            color: const Color(0xFF4F2263),
                            fontSize: screenWidth! < 370.00
                                ? MediaQuery.of(context).size.width * 0.078
                                : MediaQuery.of(context).size.width * 0.082,
                            fontWeight: FontWeight.bold,
                          ),)
                      ])),),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          editProd = true;
                        });
                      },
                      icon: !editProd ? const Icon(
                        Icons.edit,
                        color: Color(0xFF4F2263),
                      ) : Text('Guardar ', style: TextStyle(
                        color: const Color(0xFF4F2263),
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),))
                ],
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
                      Column(
                        children: [
                          Column(
                            children: [
                              TitleModContainer(text: 'Nombre'),
                              Padding(
                                  padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                              child: TextProdField(
                                enabled: editProd,
                                text: 'Nombre del producto',
                              )),
                            ],
                          ),
                          Column(
                            children: [
                              TitleModContainer(text: 'Descripcion'),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: TextProdField(
                                    enabled: editProd,
                                    text: 'Descripcion del producto',
                                  ))]),
                          Column(
                            children: [
                              TitleModContainer(text: 'Codigo de barras'),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: TextProdField(
                                    enabled: editProd,
                                    text: 'Codigo del producto',
                                  ))]),
                          Column(
                            children: [
                              TitleModContainer(text: 'Categoria'),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: const CategoryBox(borderType: 2,))]),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width * 0.04,
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4F2263),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Cant. Disponible',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                    child: TextProdField(
                                      enabled: editProd,
                                      text: 'Piezas',
                                    ))
                                  ],
                                )),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width * 0.04,
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4F2263),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Precio',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                    child: TextProdField(
                                      enabled: editProd,
                                      text: 'MXN',
                                    ),)
                                  ],
                                )),
                          ],),
                          Visibility(
                            visible: editProd,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.03,
                                  vertical: MediaQuery.of(context).size.width * 0.03,
                              ),
                              width: MediaQuery.of(context).size.width,
                              child:  ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFF4F2263),),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                  });
                                },
                                child: const Text('Eliminar Producto', style: TextStyle(color: Colors.red),),
                              ),
                            ),),
                        ],
                      )
                    ]
                )),
          ],
        )
    );
  }
}
