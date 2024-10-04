import 'package:beaute_app/inventory/services/productsService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cartProvider.dart';

class Products extends StatefulWidget {

  final String selectedCategory;
  final VoidCallback onBack;

  const Products({super.key, required this.selectedCategory, required this.onBack});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

  @override
  void initState() {
    print(products_global);
    super.initState();
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
                      color: Color(0xFF4F2263)
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.01,
                  left: MediaQuery.of(context).size.width * 0.01,
                  right: MediaQuery.of(context).size.width * 0.01,
                ),
                itemCount: products_global.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          "${products_global[index]['product']}",
                          style: TextStyle(
                            color: Color(0xFF4F2263),
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              "Precio: ",
                              style: TextStyle(color: Color(0xFF4F2263).withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.03),
                            ),
                            Container(
                              child: Text(
                                "\$${products_global[index]['price']} MXN",
                                style: TextStyle(
                                    color: Color(0xFF4F2263),
                                    fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.03,
                                ),
                              ),
                              padding: EdgeInsets.only(right: 10),
                            ),
                            Text(
                              "Cant.: ",
                              style: TextStyle(color: Color(0xFF4F2263).withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.03),
                            ),
                            Text(
                              "${products_global[index]['cant_cart']}",
                              style: TextStyle(
                                  color: Color(0xFF4F2263),
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.03
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.width * 0.09,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F2263),
                              padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.03,
                              ),
                              surfaceTintColor: const Color(0xFF4F2263),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () {
                              cartProvider.addElement(products_global[index]['product_id']);
                              print('Product added');
                            },
                            child: Icon(
                              CupertinoIcons.add,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width * 0.07,
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                      ),
                      Divider(
                        indent: MediaQuery.of(context).size.width * 0.05,
                        endIndent: MediaQuery.of(context).size.width * 0.05,
                        color: Color(0xFF4F2263).withOpacity(0.1),
                        thickness: MediaQuery.of(context).size.width * 0.005,
                      )
                    ],
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
