import 'package:flutter/material.dart';
import '../../../../../agenda/themes/colors.dart';

List<Map<String, dynamic>> sales = [
  {'producto':'Shampoo para calvos', 'cant':10, 'precio_uni':100, 'fecha':'01-10-2024'},
  {'producto':'Botox de nalgas', 'cant':5, 'precio_uni':50, 'fecha':'13-06-2024'},
  {'producto':'Jirafa amarilla', 'cant':10, 'precio_uni':50, 'fecha':'16-01-2024'},
  {'producto':'Crema para pies', 'cant':2, 'precio_uni':500, 'fecha':'24-08-2024'},
  {'producto':'Agua de horchata', 'cant':10, 'precio_uni':25, 'fecha':'17-05-2024'},
];

Widget buildSalesList(BuildContext context) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
    itemCount: sales.length,
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
                        "${sales[index]['producto']}",
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
                            '${sales[index]['cant']} pzs',
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
                            '\$${sales[index]['precio_uni']}',
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
                            '${sales[index]['cant'] * sales[index]['precio_uni']}',
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
                            '${sales[index]['fecha']}',
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
              color: AppColors.primaryColor.withOpacity(0.7),
              thickness: MediaQuery.of(context).size.width * 0.004,
            ),
          ],
        ),
      );
    },
  );
}