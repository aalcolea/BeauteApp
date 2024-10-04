import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Products extends StatefulWidget {

  final String selectedCategory;
  final VoidCallback onBack;

  const Products({super.key, required this.selectedCategory, required this.onBack});

  @override
  State<Products> createState() => _ProductsState();
}

List<Map<String, dynamic>> products = [
  {'product': 'Producto 1', 'price': '59', 'cant': '5', 'product_id': '1'},
  {'product': 'Producto 2', 'price': '79', 'cant': '3', 'product_id': '2'},
  {'product': 'Producto 3', 'price': '99', 'cant': '8', 'product_id': '3'},
  {'product': 'Producto 4', 'price': '199', 'cant': '4', 'product_id': '4'},
  {'product': 'Producto 5', 'price': '19', 'cant': '22', 'product_id': '5'},
  {'product': 'Producto 6', 'price': '209', 'cant': '15', 'product_id': '6'},
  {'product': 'Producto 7', 'price': '49', 'cant': '3', 'product_id': '7'},
  {'product': 'Producto 8', 'price': '69', 'cant': '1', 'product_id': '8'},
  {'product': 'Producto 9', 'price': '109', 'cant': '9', 'product_id': '9'},
  {'product': 'Producto 10', 'price': '99', 'cant': '10', 'product_id': '10'},
];

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
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
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          "${products[index]['product']}",
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
                                "\$${products[index]['price']} MXN",
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
                              "${products[index]['cant']}",
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
