import 'dart:async';
import 'dart:ffi';
import 'package:beaute_app/inventory/stock/products/styles/productFormStyles.dart';
import 'package:beaute_app/inventory/stock/utils/listenerCatBox.dart';
import 'package:beaute_app/regEx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../../../agenda/themes/colors.dart';
import '../../../../agenda/utils/showToast.dart';
import '../../../../agenda/utils/toastWidget.dart';
import '../../../kboardVisibilityManager.dart';
import '../../categories/forms/categoryBox.dart';
import '../services/productsService.dart';

class ProductDetails extends StatefulWidget {
  final int idProduct;
  final String nameProd;
  final String descriptionProd;
  final String barCode;
  final int stock;
  final double precio;
  final int catId;
  final Future<void> Function() onProductModified;

  const ProductDetails({super.key, required this.idProduct, required this.nameProd, required this.descriptionProd, required this.barCode, required this.stock, required this.precio, required this.catId, required this.onProductModified});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {

  //
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocus = FocusNode();
  TextEditingController precioController = TextEditingController();
  FocusNode precioFocus = FocusNode();
  TextEditingController stockController = TextEditingController();
  FocusNode stockFocus = FocusNode();
  TextEditingController barCodeController = TextEditingController();
  FocusNode barCodeFocus = FocusNode();
  late KeyboardVisibilityManager keyboardVisibilityManager;

  //
  bool editProd = false;
  ListenerCatBox listernerCatBox = ListenerCatBox();
  bool isLoading = false;
  //
  String? oldNameProd;
  String? oldDescriptionProd;
  String? oldPrecioProd;
  String? oldBarcode;
  String? oldStock;
  int _catID = 0;
  double ? screenWidth;
  double ? screenHeight;
  final productService = ProductService();

  void changeLockCatBox(){
    listernerCatBox.setChange(!editProd);
  }

  Future<void> updateProduct() async {
    setState(() {
      isLoading = true;
    });
    try{
      int? stock = int.tryParse(stockController.text);
      await productService.updateProductInfo(idProduct: widget.idProduct, name: nameController.text, price:  double.parse(precioController.text),
          barCod: barCodeController.text, catId: _catID, desc : descriptionController.text , cant: stock ?? 0).then((_){
        if(mounted){
          showOverlay(
              context,
              const CustomToast(
                message: 'Producto actualizado exitosamente',
              ));}
          });
      await widget.onProductModified();
    }catch(e){
      print('Error al crear producto');
      if(mounted){
        showOverlay(
            context,
            const CustomToast(
              message: 'Error al crear producto',
            ));}
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  @override
  void initState() {
    nameController.text = widget.nameProd;
    descriptionController.text = widget.descriptionProd;
    barCodeController.text = widget.barCode.toString();
    stockController.text = widget.stock.toString();
    precioController.text = widget.precio.toString();
    _catID =  widget.catId;
    keyboardVisibilityManager = KeyboardVisibilityManager();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }
  void onSelectedCat (int catID) {
    _catID = catID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: keyboardVisibilityManager.visibleKeyboard ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
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
                      }, child: Text('Cancelar',
                      style: TextStyle(
                        color: AppColors.primaryColor,
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
                      color: AppColors.primaryColor,
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
                          'Modificar',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: screenWidth! < 370.00
                                ? MediaQuery.of(context).size.width * 0.078
                                : MediaQuery.of(context).size.width * 0.082,
                            fontWeight: FontWeight.bold,
                          ),)
                      ])),),
                  Spacer(),
                  IconButton(//onPressed del icono de modificar
                      onPressed: editProd == false ? () {
                        setState(() {
                          editProd = true;
                          changeLockCatBox();
                          oldNameProd = nameController.text;
                          oldDescriptionProd = descriptionController.text;
                          oldBarcode = barCodeController.text;
                          oldStock = stockController.text;
                          oldPrecioProd = precioController.text;
                        });
                      } : (){//onPressedDelBoton
                        setState(() {//onPresseddelGuardar
                          _catID != widget.catId || nameController.text != oldNameProd! || descriptionController.text != oldDescriptionProd! ||
                              barCodeController.text != oldBarcode! || stockController.text != oldStock! || precioController.text != oldPrecioProd! ?
                          updateProduct() :  showOverlay(
                              context,
                              const CustomToast(
                              message: 'No se hicieron cambios',
                          ));
                          editProd = false;
                          changeLockCatBox();
                        });
                      },
                      icon: !editProd ? const Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ) : Text('Guardar ', style: TextStyle(
                        color: AppColors.primaryColor,
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
                                inputFormatters: [
                                  RegEx(type: InputFormatterType.alphanumeric),
                                ],
                                controller: nameController,
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
                                    inputFormatters: [RegEx(type: InputFormatterType.alphanumeric)],
                                    controller: descriptionController,
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
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      RegEx(type: InputFormatterType.numeric)],
                                    controller: barCodeController,
                                    enabled: editProd,
                                    text: 'Codigo del producto',
                                  ))]),
                          Column(
                            children: [
                              TitleModContainer(text: 'Categoria'),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: CategoryBox(formType: 2, onSelectedCat: onSelectedCat,selectedCatId: widget.catId, listernerCatBox: listernerCatBox))]),
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
                                        color: AppColors.primaryColor,
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
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [RegEx(type: InputFormatterType.numeric)],
                                      controller: stockController,
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
                                        color: AppColors.primaryColor,
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
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [RegEx(type: InputFormatterType.numeric)],
                                      controller: precioController,
                                      enabled: editProd,
                                      text: 'MXN',
                                    ),)
                                  ],
                                )),
                          ],),
                          SizedBox(height: editProd ? 0 : 15,),
                          Visibility(
                              visible: isLoading,
                              child: const CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              )),
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
                                  side: const BorderSide(color: AppColors.primaryColor,),
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
