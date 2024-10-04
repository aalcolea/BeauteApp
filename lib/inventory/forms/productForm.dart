import 'dart:async';

import 'package:beaute_app/inventory/forms/categoryBox.dart';
import 'package:beaute_app/inventory/forms/styles/productFormStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/productsService.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {

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
  bool isLoading = false;
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

  final productService = ProductService();

  Future<void> createProduct() async {
    if (nameController.text.isEmpty ||
        precioController.text.isEmpty ||
        barCodeController.text.isEmpty) {
      print("Por favor complete todos los campos obligatorios");
      return;
    }
    setState(() {
      //colocar isloading true (Mario lo debe ver)
    });
    try {
      await productService.createProduct(nombre: nameController.text, precio: double.parse(precioController.text), codigoBarras: barCodeController.text,
        descripcion: descriptionController.text, categoryId: 20,
      );
      print('Producto creado exitosamente');

      Navigator.pop(context);
    } catch (e) {
      print('Error al crear producto');
    } finally {
      setState(() {
        //colordar isloading
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                IconButton(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.back,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: const Color(0xFF4F2263),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0), child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          textAlign: TextAlign.start,
                          'Agregar Producto',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.095,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4F2263),
                          ))
                    ]))
              ],
            ),
             ),
        SliverList(delegate: SliverChildListDelegate(
            [
             Column(
               children: [
                 TitleContainer(
                   child: Text('Nombre', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),),
                 ),
                 Padding(padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.03),
                     child: TextFormField(
                       focusNode: nameFocus,
                       controller: nameController,
                       decoration: InputDecoration(
                         hintText: 'Nombre del producto',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10.0),
                         ),
                       ),
                       onEditingComplete: () => changeFocus(context, nameFocus, descriptionFocus),
                     ),
                     ),
                 TitleContainer(
                   child: Text('Descripción', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),),
                 ),
                 Padding(padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.03),
                     child: TextFormField(
                       focusNode: descriptionFocus,
                       controller: descriptionController,
                       decoration: InputDecoration(
                         hintText: 'Descripción del producto',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10.0),
                         ),
                       ),
                         onEditingComplete: () => changeFocus(context, descriptionFocus, precioFocus)
                     )),
                 TitleContainer(
                   child: Text('Precio', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),),
                 ),
                 Padding(padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.03),
                     child: TextFormField(
                       focusNode: precioFocus,
                       controller: precioController,
                       decoration: InputDecoration(
                         hintText: 'Precio del producto',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10.0),
                         )),
                       onEditingComplete: () => changeFocus(context, precioFocus, barCodeFocus),)),
                 TitleContainer(
                   child: Text('Código de barras', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),),
                 ),
                 Padding(padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.03),
                     child: TextFormField(
                       focusNode: barCodeFocus,
                       controller: barCodeController,
                       decoration: InputDecoration(
                         hintText: 'Codigo de barras del producto',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10.0),
                         ),
                       ),
                     )),
                 TitleContainer(
                   child: Text('Categoría', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),),
                 ),
                 Padding(padding: EdgeInsets.symmetric(
                   horizontal: MediaQuery.of(context).size.width * 0.03,
                   vertical: MediaQuery.of(context).size.width * 0.03,
                 ),
                 child: CategoryBox(),
                 ),
                 ElevatedButton(
                   onPressed: createProduct,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF4F2263),
                     padding: EdgeInsets.symmetric(
                       horizontal: MediaQuery.of(context).size.width * 0.2,
                       vertical: MediaQuery.of(context).size.width * 0.05,
                     ),
                   ), child: null,
                 )
               ],
             )
            ]
          )),
        ],
      )
    );
  }
}
