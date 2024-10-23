import 'package:flutter/material.dart';
import '../../../../../agenda/themes/colors.dart';
import '../services/salesServices.dart';

class SalesList extends StatefulWidget {

  final void Function(
      int
      ) onShowBlur;

  const SalesList({super.key, required this.onShowBlur});

  @override
  State<SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {

  bool isLoading = false;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchSales();
    print(fetchSales());
  }

  Future<void> fetchSales() async{
    setState(() {
      isLoading = true;
    });
    try{
      final salesService = SalesServices();
      //await salesService.fetchSales();
      final products2 = await salesService.getSalesByProduct();
      setState(() {
        products = products2;
        print('products: $products');
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
      color: AppColors.calendarBg,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
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
                                '${products[index]['total'].toStringAsFixed(2)}',
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
                                '${products[index]['fecha']}',
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
      ),
    );
  }
}