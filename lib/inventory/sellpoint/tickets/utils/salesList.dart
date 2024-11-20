import 'dart:io';

import 'package:beaute_app/inventory/print/printSalesService.dart';
import 'package:beaute_app/inventory/print/printService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../agenda/utils/showToast.dart';
import '../../../../agenda/utils/toastWidget.dart';
import '../../../print/printConnections.dart';
import '../../../themes/colors.dart';
import '../services/salesServices.dart';
import 'listenerOnDateChanged.dart';

class SalesList extends StatefulWidget {
  final void Function(int) onShowBlur;
  final ListenerOnDateChanged listenerOnDateChanged;
  final String dateController;
  final void Function(String) onDateChanged;
  final PrintService printService;

  const SalesList({super.key, required this.onShowBlur, required this.listenerOnDateChanged, required this.dateController, required this.onDateChanged, required this.printService});

  @override
  State<SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {

  bool isLoading = false;
  List<Map<String, dynamic>> products = [];
  late String formattedDate;
  late SalesPrintService salesPrintService;

  @override
  void initState() {
    super.initState();
    fetchSales(widget.dateController, widget.dateController);
    widget.listenerOnDateChanged.registrarObservador((callback, initData, finalData) async {
      if (callback) {
        await fetchSales(initData, finalData);
      }
    });
  }

  Future<void> fetchSales(String? initData, String? finalData) async{
    setState(() {
      isLoading = true;
      widget.onDateChanged(initData!);
    });
    try{
      final salesService = SalesServices();
      //await salesService.fetchSales();
      final products2 = await salesService.getSalesByProduct(initData, finalData);
      setState(() {
        products = products2;
        Future.delayed(Duration(milliseconds: 250));
        isLoading = false;
      });
    }catch (e) {
      print('Error fetching sales: $e');
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        children: [
          Expanded(
            child: !isLoading
                ? ( products.isNotEmpty ? ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.0075,
                            horizontal: MediaQuery.of(context).size.width * 0.0247),
                        title: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${products[index]['nombre']}",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Cant.:",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '${products[index]['cantidad']} pzs',
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Precio unitario: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '\$${products[index]['precio']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Total: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '\$${products[index]['total'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Fecha de venta: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '${products[index]['fecha_venta']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: AppColors.primaryColor,
                        thickness: MediaQuery.of(context).size.width * 0.0055,
                      ),
                    ],
                  ),
                );
              },
            ) : const Center(
              child: Text(
                'No hay tickets correspondientes a la fecha seleccionada',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            )) : const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              border: const Border(top: BorderSide(color: AppColors.primaryColor, width: 2)),
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.15),
                  offset: const Offset(4, -5),
                  blurRadius: 5,
                  spreadRadius: 0.1,
                )
              ],
            ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      bool canPrint = false;
                      try{
                        await widget.printService.ensureCharacteristicAvailable();
                        if(widget.printService.characteristic != null){
                          canPrint = true;
                        }
                      }catch(e){
                        print("Error: No hay impresora conectada  - $e");
                        showOverlay(context, const CustomToast(message: 'Impresion no disponible, continuando con la venta'));
                      }
                      if (canPrint) {
                        salesPrintService = SalesPrintService(widget.printService.characteristic!);
                        try{
                          Platform.isAndroid ? await salesPrintService.connectAndPrintAndroide(products, 'assets/imgLog/test2.jpeg', products[0]['fecha_venta']) :
                      await salesPrintService.connectAndPrintIOS(products, 'assets/imgLog/test2.jpeg', products[0]['fecha_venta']);
                      } catch(e){
                      print("Error al intentar imprimir: $e");
                      showOverlay(context, const CustomToast(message: 'Error al intentar imprimir'));
                      }
                    }
                    },
                    icon: Icon(
                      CupertinoIcons.printer_fill,
                      color: AppColors.primaryColor,
                      size: MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.005,
                  height: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {

                    },
                    icon: Icon(
                      CupertinoIcons.arrow_down_doc_fill,
                      color: AppColors.primaryColor,
                      size: MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}