import 'package:flutter/material.dart';
import '../../../../../agenda/themes/colors.dart';

List<Map<String, dynamic>> tickets = [
  {'ticketID':1, 'fecha':'17-10-2024', 'cant':15, 'total': 300},
  {'ticketID':2, 'fecha':'20-10-2024', 'cant':10, 'total': 1500},
  {'ticketID':3, 'fecha':'12-10-2024', 'cant':5, 'total': 600},
  {'ticketID':4, 'fecha':'15-10-2024', 'cant':20, 'total': 700},
];

List<Map<String, dynamic>> ticketProducts = [
  {'ticketID':1, 'producto':'Shampoo para calvos', 'cant':10, 'precio_uni':100},
  {'ticketID':1, 'producto':'Botox de nalgas', 'cant':5, 'precio_uni':50},
  {'ticketID':2, 'producto':'Jirafa amarilla', 'cant':10, 'precio_uni':50},
  {'ticketID':3, 'producto':'Crema para pies', 'cant':2, 'precio_uni':500},
  {'ticketID':3, 'producto':'Agua de horchata', 'cant':10, 'precio_uni':25},
  {'ticketID':4, 'producto':'Agua de jamaica', 'cant':5, 'precio_uni':25},
];

Map<int, List<Map<String, dynamic>>> groupByTicket(List<Map<String, dynamic>> ticketProducts) {
  Map<int, List<Map<String, dynamic>>> groupedTickets = {};
  for (var product in ticketProducts) {
    if (!groupedTickets.containsKey(product['ticketID'])) {
      groupedTickets[product['ticketID']] = [];
    }
    groupedTickets[product['ticketID']]!.add(product);
  }
  return groupedTickets;
}

Widget buildTicketsList(BuildContext context) {
  final groupedTickets = groupByTicket(ticketProducts);
  return ListView.builder(
    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03),
    itemCount: groupedTickets.keys.length,
    itemBuilder: (context, index) {
      final ticketID = groupedTickets.keys.elementAt(index);
      final categoryTickets = groupedTickets[ticketID]!;
      final ticket = tickets.firstWhere((t) => t['ticketID'] == ticketID, orElse: () => {});
      return ExpansionTile(
        iconColor: AppColors.calendarBg,
        collapsedIconColor: AppColors.calendarBg,
        backgroundColor: AppColors.primaryColor,
        collapsedBackgroundColor: AppColors.primaryColor,
        tilePadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, right: MediaQuery.of(context).size.width * 0.02),
        childrenPadding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.0),
        shape: const Border(
          bottom: BorderSide(
              color: AppColors.calendarBg, width: 2
          )
        ),
        collapsedShape: const Border(
            bottom: BorderSide(
                color: AppColors.calendarBg, width: 2
            )
        ),
        initiallyExpanded: false,
        title: Text(
          'Ticket $ticketID',
          style: TextStyle(
            color: AppColors.calendarBg,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Fecha: ',
                  style: TextStyle(
                    color: AppColors.calendarBg,
                  ),
                ),
                Text(
                  '${ticket['fecha']}',
                  style: TextStyle(
                      color: AppColors.calendarBg,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.035),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Cantidad total: ',
                  style: TextStyle(
                      color: AppColors.calendarBg,
                  ),
                ),
                Text(
                  '${ticket['cant']} pzs',
                  style: TextStyle(
                      color: AppColors.calendarBg,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.035),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Total: ',
                  style: TextStyle(
                      color: AppColors.calendarBg,
                  ),
                ),
                Text(
                  '\$${ticket['total']}',
                  style: TextStyle(
                      color: AppColors.calendarBg,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.035),
                ),
              ],
            ),
          ],
        ),
        children: categoryTickets.map((product) {
          return Container(
            color: AppColors.calendarBg,
            child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06),
                title: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['producto'],
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
                                color: AppColors.primaryColor,
                                fontSize: MediaQuery.of(context).size.width * 0.035),
                          ),
                          Text(
                            '${product['cant']} pzs',
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
                                color: AppColors.primaryColor,
                                fontSize: MediaQuery.of(context).size.width * 0.035),
                          ),
                          Text(
                            '\$${product['precio_uni']}',
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
                                color: AppColors.primaryColor,
                                fontSize: MediaQuery.of(context).size.width * 0.035),
                          ),
                          Text(
                            '${product['cant'] * product['precio_uni']}',
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
                )
            ),
          );
        }).toList(),
      );
    },
  );
}