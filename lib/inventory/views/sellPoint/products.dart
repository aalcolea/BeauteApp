import 'package:beaute_app/inventory/services/productsService.dart';
import 'package:beaute_app/inventory/views/sellPoint/styles/productDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cartProvider.dart';

class Products extends StatefulWidget {

  final void Function(
      bool
  ) onShowBlur;

  final String selectedCategory;
  final int selectedCategoryId;
  final VoidCallback onBack;

  const Products({super.key, required this.selectedCategory, required this.onBack, required this.selectedCategoryId, required this.onShowBlur});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> with TickerProviderStateMixin {
  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<int> tapedIndices = [];
  late Animation<double> movLeft;
  late Animation<double> movLeftCount;
  int ? tapedIndex;
  bool editProductWidget = false;


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
    for (int i = 0; i < products_global.length; i++) {
      aniControllers.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 450)));
      cantHelper.add(0);
    }
    super.initState();
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
                vsync: this, duration: const Duration(milliseconds: 450)));
        cantHelper = List.generate(products_global.length, (index) => 0);
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
      });
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
                    onTap: (){
                      Navigator.push(context,
                        CupertinoPageRoute(
                          builder: (context) => ProductDetails(
                            nameProd: products_global[index]['product'],
                            descriptionProd: '',
                            barCode: 101010101,
                            stock: '${products_global[index]['cant_cart']['cantidad']}' ?? '0',
                            precio: products_global[index]['price'],
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      editProductWidget = true;
                    },
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
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
                                        products_global[index]['cant_cart'] == null ? '0' : '${products_global[index]['cant_cart']['cantidad']}',
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