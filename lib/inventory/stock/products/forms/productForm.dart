import 'dart:async';
import 'package:beaute_app/agenda/forms/clientForm.dart';
import 'package:beaute_app/inventory/stock/categories/forms/categoryBox.dart';
import 'package:beaute_app/inventory/stock/products/styles/productFormStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../../../agenda/utils/showToast.dart';
import '../../../../agenda/utils/toastWidget.dart';
import '../../../../regEx.dart';
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
      ).then((_){
        if(mounted){
          showOverlay(
              context,
              const CustomToast(
                message: 'Producto creado exitosamente',
              ));}});
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
                 Column(
                   children: [
                     TitleModContainer(text: 'Nombre', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: nameFocus,
                           controller: nameController,
                           inputFormatters: [
                             EmailInputFormatter()
                           ],
                           text: 'Nombre del producto',
                           textStyle: const TextStyle(
                             color: Color(0xFF4F2263),
                           ),
                           onEditingComplete: () => changeFocus(context, nameFocus, descriptionFocus),
                         )),
                   ],
                 ),

                 Column(
                   children: [
                     TitleModContainer(text: 'Descripción', ),
                     Padding(
                         padding: EdgeInsets.only(
                           left: MediaQuery.of(context).size.width * 0.03,
                           right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: descriptionFocus,
                           controller: descriptionController,
                           inputFormatters: [
                             RegEx(type: InputFormatterType.alphanumeric),
                           ],
                           text: 'Descripción del producto',
                           textStyle: const TextStyle(
                             color: Color(0xFF4F2263),
                           ),
                           onEditingComplete: () => changeFocus(context, descriptionFocus, precioFocus),
                         )),
                   ],
                 ),

                 Column(
                   children: [
                     TitleModContainer(text: 'Precio', ),
                     Padding(
                         padding: EdgeInsets.only(
                           left: MediaQuery.of(context).size.width * 0.03,
                           right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: precioFocus,
                           controller: precioController,
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           inputFormatters: [
                             RegEx(type: InputFormatterType.numeric),
                           ],
                           text: 'Precio del producto',
                           textStyle: const TextStyle(
                             color: Color(0xFF4F2263),
                           ),
                           onEditingComplete: () => changeFocus(context, precioFocus, barCodeFocus),
                         )),
                   ],
                 ),

                 Column(
                   children: [
                     TitleModContainer(text: 'Código de barras', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: barCodeFocus,
                           controller: barCodeController,
                           keyboardType: TextInputType.number,
                           inputFormatters: [
                             RegEx(type: InputFormatterType.numeric),
                           ],
                           text: 'Código de barras del producto',
                           textStyle: const TextStyle(
                             color: Color(0xFF4F2263),
                           ),
                         )),
                   ],
                 ),
                 Column(
                     children: [
                       TitleModContainer(text: 'Categoria'),
                       Padding(padding: EdgeInsets.only(
                           left: MediaQuery.of(context).size.width * 0.03,
                           right: MediaQuery.of(context).size.width * 0.03),
                           child: CategoryBox(formType: 1, onSelectedCat: onSelectedCat))]),

                 Padding(padding: EdgeInsets.only(
                     top: MediaQuery.of(context).size.width * 0.04,
                     left: MediaQuery.of(context).size.width * 0.03,
                     right: MediaQuery.of(context).size.width * 0.03,
                 ),
                 child: ElevatedButton(
                   onPressed: createProduct,
                   style: ElevatedButton.styleFrom(
                     minimumSize: Size(double.infinity, 0),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),
                     backgroundColor: const Color(0xFF4F2263),
                     padding: EdgeInsets.symmetric(
                       horizontal: MediaQuery.of(context).size.width * 0.15,
                       vertical: MediaQuery.of(context).size.width * 0.03,
                     ),
                   ), child: !isLoading ? Text('Crear Producto', style: TextStyle(
                     fontSize: MediaQuery.of(context).size.width * 0.06,
                     color: Colors.white
                 ),) : CircularProgressIndicator(color: Colors.white,),
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
