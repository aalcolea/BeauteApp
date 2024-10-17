import 'package:flutter/material.dart';
import '../../../../../agenda/themes/colors.dart';

List<Map<String, dynamic>> sales = [
  {'catID':1, 'producto':'Shampoo para calvos', 'cant':10, 'precio_uni':100, 'fecha':'17-10-2024'},
  {'catID':1, 'producto':'Botox de nalgas', 'cant':5, 'precio_uni':50, 'fecha':'17-10-2024'},
  {'catID':2, 'producto':'Jirafa amarilla', 'cant':10, 'precio_uni':50, 'fecha':'17-10-2024'},
  {'catID':3, 'producto':'Crema para pies', 'cant':2, 'precio_uni':500, 'fecha':'17-10-2024'},
  {'catID':3, 'producto':'Agua de horchata', 'cant':10, 'precio_uni':25, 'fecha':'17-10-2024'},
  {'catID':3, 'producto':'Agua de jamaica', 'cant':5, 'precio_uni':25, 'fecha':'17-10-2024'},
];

Map<int, List<Map<String, dynamic>>> groupByCategory(List<Map<String, dynamic>> sales) {
  Map<int, List<Map<String, dynamic>>> groupedSales = {};
  for (var sale in sales) {
    if (!groupedSales.containsKey(sale['catID'])) {
      groupedSales[sale['catID']] = [];
    }
    groupedSales[sale['catID']]!.add(sale);
  }
  return groupedSales;
}

Widget buildTodaySalesList(BuildContext context) {
  final groupedSales = groupByCategory(sales);
  return ListView.builder(
    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
    itemCount: groupedSales.keys.length,
    itemBuilder: (context, index) {
      final catID = groupedSales.keys.elementAt(index);
      final categorySales = groupedSales[catID]!;
      return ExpansionTile(
        tilePadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, right: MediaQuery.of(context).size.width * 0.02),
        childrenPadding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04, left: MediaQuery.of(context).size.width * 0.02),
        shape: Border(
          top: BorderSide(
              color: AppColors.primaryColor.withOpacity(0.7), width: 2
          )
        ),
        collapsedShape: Border(
            top: BorderSide(
                color: AppColors.primaryColor.withOpacity(0.7), width: 2
            )
        ),
        initiallyExpanded: true,
        title: Text(
          'Categoría $catID',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
        ),
        children: categorySales.map((sale) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.0075,
                horizontal: MediaQuery.of(context).size.width * 0.0247),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale['producto'],
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
                      style: TextStyle(
                          color: AppColors.primaryColor.withOpacity(0.5),
                          fontSize: MediaQuery.of(context).size.width * 0.035),
                    ),
                    Text(
                      '${sale['cant']} pzs',
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
                      '\$${sale['precio_uni']}',
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
                      '${sale['cant'] * sale['precio_uni']}',
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
                      '${sale['fecha']}',
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
          );
        }).toList(),
      );
    },
  );
}