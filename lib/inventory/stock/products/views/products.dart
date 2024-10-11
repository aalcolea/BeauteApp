import 'package:beaute_app/inventory/stock/products/services/productsService.dart';
import 'package:beaute_app/inventory/stock/products/views/productDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../sellpoint/cart/services/cartService.dart';
import '../utils/productOptions.dart';

class Products extends StatefulWidget {

  final void Function(
      bool
  ) onShowBlur;

  final String selectedCategory;
  final int selectedCategoryId;
  final VoidCallback onBack;

  const Products({super.key, required this.selectedCategory, required this.onBack, required this.selectedCategoryId, required this.onShowBlur});

  @override
  ProductsState createState() => ProductsState();
}

class ProductsState extends State<Products> with TickerProviderStateMixin {
  List<GlobalKey> productKeys = [];
  OverlayEntry? overlayEntry;

  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<int> tapedIndices = [];
  late Animation<double> movLeft;
  late Animation<double> movLeftCount;
  int ? tapedIndex;
  double widgetHeight = 0.0;


  void itemCount (index, action){
    if(action == false){
      cantHelper[index] > 0 ? cantHelper[index]-- : cantHelper[index] = 0;
      if(cantHelper[index] == 0){
        tapedIndices.remove(index);
        aniControllers[index].reverse().then((_){
          aniControllers[index].reset();
        });
      }
    }else{
      cantHelper[index]++;
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    ///RECORDAR QUITAR DEL INIT
    super.initState();
    productKeys = List.generate(products_global.length, (index) => GlobalKey());
    for (int i = 0; i < products_global.length; i++) {
      aniControllers.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 450)));
      cantHelper.add(0);
    }
    fetchProducts();
  }
  Future<void> fetchProducts() async {
    try {
      final productService = ProductService();
      await productService.fetchProducts(widget.selectedCategoryId);
      setState(() {
        aniControllers = List.generate(
          products_global.length,
              (index) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 450),
          ),
        );
        cantHelper = List.generate(products_global.length, (index) => 0);
        productKeys = List.generate(products_global.length, (index) => GlobalKey());
      });
    } catch (e) {
      print('Error fetching productos: $e');
    }
  }


  void colHeight (double _colHeight) {
    widgetHeight = _colHeight;
  }

  void showProductOptions(int index) {
    removeOverlay();
    if (index >= 0 && index < productKeys.length) {
      final key = productKeys[index];
      final RenderBox renderBox = key.currentContext
          ?.findRenderObject() as RenderBox;

      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);

      final screenHeight = MediaQuery.of(context).size.height;
      final availableSpaceBelow = screenHeight - position.dy;

      double topPosition;

      if (availableSpaceBelow >= widgetHeight) {
        topPosition = position.dy;
      } else {
        topPosition = screenHeight - widgetHeight - MediaQuery.of(context).size.height*0.03;
      }

      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: topPosition,
            left: position.dx,
            width: size.width,
            child: IntrinsicHeight(
              child: ProductOptions(
                onClose: removeOverlay,
                nombre: products_global[index]['product'] ?? "El producto no existe",
                cant: products_global[index]['cant_cart'] == null
                    ? 'Agotado'
                    : '${products_global[index]['cant_cart']['cantidad']}',
                precio: products_global[index]['price'],
                stock: products_global[index]['cant_cart'] == null ? 0 : products_global[index]['cant_cart']['cantidad'],
                barCode: products_global[index]['barCod'],
                catId: products_global[index]['catId'],
                id: products_global[index]['id'],
                descripcion: products_global[index]['descripcion'],
                columnHeight: colHeight,
                onProductDeleted: () async {
                  await refreshProducts();
                  removeOverlay();
                  setState(() {});
                },
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(overlayEntry!);
      widget.onShowBlur(true);
    } else {
      print("Invalid index: $index");
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    widget.onShowBlur(false); // Elimina el blur si estaba activo
  }
  Future<void> refreshProducts() async {
    try {
      await fetchProducts();
    } catch (e) {
      print('Error en refresh productos $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.width * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02),
            child: Row(
              children: [
                IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF4F2263),
                    )
                ),
                Text(
                  widget.selectedCategory,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      color: const Color(0xFF4F2263)
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.01,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: products_global.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    key: productKeys[index],
                    onTap: (){
                      Navigator.push(context,
                        CupertinoPageRoute(
                          builder: (context) => ProductDetails(
                            idProduct: products_global[index]['id'],
                            nameProd: products_global[index]['product'],
                            descriptionProd: products_global[index]['descripcion'],
                            catId: products_global[index]['catId'],
                            barCode: products_global[index]['barCod'],
                            stock: products_global[index]['cant_cart'] == null ? 0 : products_global[index]['cant_cart']['cantidad'],
                            precio: products_global[index]['price'],
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      if (index >= 0 && index < products_global.length) {
                        widget.onShowBlur(true);
                        showProductOptions(index);
                      } else {
                        print("Invalid product index: $index");
                      }
                    },
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.0075, horizontal: MediaQuery.of(context).size.width * 0.0247),
                          title: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${products_global[index]['product']}",
                                    style: TextStyle(
                                      color: const Color(0xFF4F2263),
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Cant.: ",
                                        style: TextStyle(color: const Color(0xFF4F2263).withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                                      ),
                                      Text(
                                        products_global[index]['cant_cart'] == null ? 'Agotado' : '${products_global[index]['cant_cart']['cantidad']}',
                                        style: TextStyle(
                                            color: const Color(0xFF4F2263),
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
                                        style: TextStyle(color: const Color(0xFF4F2263).withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Text(
                                          "\$${products_global[index]['price']} MXN",
                                          style: TextStyle(
                                            color: const Color(0xFF4F2263),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width * 0.035,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Spacer(),
                              AnimatedContainer(
                                alignment: Alignment.bottomRight,
                                duration: const Duration(milliseconds: 225),
                                  width: tapedIndices.contains(index) ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.13,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF4F2263),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedBuilder(animation: aniControllers[index],
                                          child: Visibility(
                                            visible:  tapedIndices.contains(index),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(0, 0),
                                                backgroundColor: Colors.transparent,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MediaQuery.of(context).size.width * 0.015,
                                                  vertical: MediaQuery.of(context).size.width * 0.015,
                                                ),
                                                shadowColor: Colors.transparent
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  bool action = false;
                                                  itemCount(index, action);
                                                });
                                              },
                                              child: Icon(
                                                CupertinoIcons.minus,
                                                color: Colors.white,
                                                size: MediaQuery.of(context).size.width * 0.07,
                                              ),
                                            ),),
                                          builder: (context, minusMove){
                                            movLeft = Tween(begin: 0.0, end: MediaQuery.of(context).size.width * 0.023).animate(aniControllers[index]);
                                            return Transform.translate(offset: Offset(-movLeft.value, 0), child: minusMove);
                                          }),
                                      AnimatedBuilder(
                                          animation: aniControllers[index],
                                          child: Visibility(
                                              visible: tapedIndices.contains(index),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF4F2263),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MediaQuery.of(context).size.width * 0.0,
                                                  vertical: MediaQuery.of(context).size.width * 0.015,
                                                ),
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  '${cantHelper[index]}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              )),
                                          builder: (context, countMov){
                                            movLeftCount = Tween(begin: 0.0, end: MediaQuery.of(context).size.width * 0.012).animate(aniControllers[index]);
                                            return Transform.translate(offset: Offset(-movLeftCount.value, 0), child: countMov);
                                          }),
                                      ///btn mas
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(0, 0),
                                          backgroundColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context).size.width * 0.015,
                                            vertical: MediaQuery.of(context).size.width * 0.015,
                                          ),
                                          shadowColor: Colors.transparent
                                        ),
                                        onPressed: () {
                                          cartProvider.addElement(products_global[index]['product_id']);
                                          setState(() {
                                            bool action = true;
                                            tapedIndex = index;
                                            if (!tapedIndices.contains(index)) {
                                              tapedIndices.add(index);
                                            }
                                            itemCount(index, action);
                                            aniControllers[index].forward();
                                          });
                                        },
                                        child: Icon(
                                          CupertinoIcons.add,
                                          color: Colors.white,
                                          size: MediaQuery.of(context).size.width * 0.07,
                                        ),
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),),
                        Divider(
                          indent: MediaQuery.of(context).size.width * 0.05,
                          endIndent: MediaQuery.of(context).size.width * 0.05,
                          color: Color(0xFF4F2263).withOpacity(0.1),
                          thickness: MediaQuery.of(context).size.width * 0.005,
                        )
                      ],
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}