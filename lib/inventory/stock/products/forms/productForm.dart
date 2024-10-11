import 'dart:async';
import 'package:beaute_app/inventory/stock/categories/forms/categoryBox.dart';
import 'package:beaute_app/inventory/stock/products/styles/productFormStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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
  double ? screenWidth;
  double ? screenHeight;
  int _catID = 0;
  bool isLoading = false;

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

  final productService = ProductService();

  Future<void> createProduct() async {
    if (nameController.text.isEmpty ||
        precioController.text.isEmpty ||
        barCodeController.text.isEmpty) {
      print("Por favor complete todos los campos obligatorios");
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      await productService.createProduct(nombre: nameController.text, precio: double.parse(precioController.text), codigoBarras: barCodeController.text,
        descripcion: descriptionController.text, categoryId: _catID,
      );
      print('Producto creado exitosamente');
      Navigator.pop(context, true);
    } catch (e) {
      print('Error al crear producto');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void onSelectedCat (int catID) {
    _catID = catID;
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
                          color: const Color(0xFF4F2263),
                          fontSize: screenWidth! < 370.00
                              ? MediaQuery.of(context).size.width * 0.078
                              : MediaQuery.of(context).size.width * 0.082,
                          fontWeight: FontWeight.bold,
                        ),)
                    ]))
              ],
            ),
             ),
        SliverList(

            delegate: SliverChildListDelegate(
            [
             Column(
               children: [
                 TitleContainer(
                   margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04,
                   left: MediaQuery.of(context).size.width * 0.03,
                   right: MediaQuery.of(context).size.width * 0.03),
                   child: Text('Nombre', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),),
                 ),
                 Padding(
                   padding: EdgeInsets.only(
                       left: MediaQuery.of(context).size.width * 0.03,
                       right: MediaQuery.of(context).size.width * 0.03,
                       top: MediaQuery.of(context).size.width * 0.03,
                       bottom: MediaQuery.of(context).size.width * 0.03,
                   ),
                     child: TextFormField(
                       focusNode: nameFocus,
                       controller: nameController,
                       decoration: InputDecoration(
                         constraints: BoxConstraints(
                           maxHeight: MediaQuery.of(context).size.width * 0.1,
                         ),
                         contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
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
                         contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                         constraints: BoxConstraints(
                           maxHeight: MediaQuery.of(context).size.width * 0.1,
                         ),
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
                           constraints: BoxConstraints(
                             maxHeight: MediaQuery.of(context).size.width * 0.1,
                           ),
                           contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
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
                         constraints: BoxConstraints(
                           maxHeight: MediaQuery.of(context).size.width * 0.1,
                         ),
                         contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
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
                 child: CategoryBox(borderType: 1, onSelectedCat: onSelectedCat),
                 ),
                 ElevatedButton(
                   onPressed: createProduct,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF4F2263),
                     padding: EdgeInsets.symmetric(
                       horizontal: MediaQuery.of(context).size.width * 0.2,
                       vertical: MediaQuery.of(context).size.width * 0.05,
                     ),
                   ), child: Text(isLoading ? "cargando" : "hola"),
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
