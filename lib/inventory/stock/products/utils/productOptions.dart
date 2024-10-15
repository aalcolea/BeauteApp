import 'dart:ffi';

import 'package:beaute_app/inventory/stock/products/utils/PopUpTabs/deleteProductDialog.dart';
import 'package:beaute_app/inventory/stock/products/utils/PopUpTabs/modifyStockDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../agenda/themes/colors.dart';
import '../../../../agenda/utils/showToast.dart';
import '../../../../agenda/utils/toastWidget.dart';
import '../views/productDetails.dart';
import '../services/productsService.dart';

class ProductOptions extends StatefulWidget {

  final VoidCallback onClose;
  final String nombre;
  final String cant;
  final double precio;
  final int id;
  final String barCode;
  final String descripcion;
  final int stock;
  final int catId;
  final Function(double) columnHeight;
  final Future<void> Function() onProductDeleted;
  final void Function(
      bool
      ) onShowBlur;

  final dynamic columnH;

  const ProductOptions({super.key, required this.onClose, required this.nombre, required this.cant, required this.precio, required this.columnH, required void Function(bool p1) onShowBlureight, required this.id, required this.barCode, required this.stock, required this.catId, required this.descripcion, required this.onProductDeleted, required this.onShowBlur, required this.columnHeight,
  });

  @override
  State<ProductOptions> createState() => _ProductOptionsState();
}

class _ProductOptionsState extends State<ProductOptions> {

  final GlobalKey _columnKey = GlobalKey();
  double _columnHeight = 0.0;
  final productService = ProductService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeight();
    });
  }

  void _calculateHeight() {
    final RenderBox? renderBox =
    _columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _columnHeight = renderBox.size.height;
        widget.columnHeight(_columnHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.width * 0.02, right: MediaQuery.of(context).size.width * 0.02),
      child: Column(
        key: _columnKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02,
                      top: MediaQuery.of(context).size.width * 0.009,
                      bottom: MediaQuery.of(context).size.width * 0.009,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02, horizontal: MediaQuery.of(context).size.width * 0.0247),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.nombre}',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Cant.: ",
                                style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                              ),
                              Text(
                                '${widget.cant}',//products_global[index]['cant_cart'] == null ? 'Agotado' : '${products_global[index]['cant_cart']['cantidad']}',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.035
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Precio: ",
                                style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  '\$${widget.precio} MXN',//"\$${products_global[]['price']} MXN",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ),
              ),
          ),
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.width * 0.4,
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
                bottom: MediaQuery.of(context).size.width * 0.02,
                top: MediaQuery.of(context).size.width * 0.02
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.onClose();
                            Navigator.push(context,
                              CupertinoPageRoute(
                                builder: (context) => ProductDetails(
                                  idProduct: widget.id,
                                  nameProd: widget.nombre,
                                  descriptionProd: widget.descripcion,
                                  catId: widget.catId,
                                  barCode: widget.barCode,
                                  stock: widget.stock,
                                  precio: widget.precio,
                                  onProductModified: () async {
                                  await productService.refreshProducts(widget.catId);
                                  }


                                ),
                              ),
                            );
                          },
                          style: const ButtonStyle(
                            alignment: Alignment.centerLeft,
                          ),
                          child: const Text(
                            'Editar producto',
                            style: TextStyle(
                                color: AppColors.primaryColor
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  thickness: MediaQuery.of(context).size.width * 0.004,
                ),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.onClose();
                            widget.onShowBlur(true);
                            showModifyproductStockDialog(context, widget.nombre, widget.stock, () async {

                            }).then((_) {
                              widget.onShowBlur(false);
                            });
                          },
                          style: const ButtonStyle(
                              alignment: Alignment.centerLeft
                          ),
                          child: const Text(
                            'Modificar stock',
                            style: TextStyle(
                                color: AppColors.primaryColor
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  thickness: MediaQuery.of(context).size.width * 0.004,
                ),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.onClose();
                            widget.onShowBlur(true);
                            showDeleteProductConfirmationDialog(context, () async {
                              await productService.deleteProduct(widget.id);
                              if (mounted) {
                                showOverlay(
                                  context,
                                  const CustomToast(
                                    message: 'Producto eliminado',
                                  ),
                                );
                              }
                              await widget.onProductDeleted();
                            }).then((_) {
                              widget.onShowBlur(false);
                            });
                          },
                          style: const ButtonStyle(
                              alignment: Alignment.centerLeft
                          ),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(
                                color: Colors.red
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
