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
  return Container(
    color: AppColors.calendarBg,
    child: ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: groupedTickets.keys.length,
      itemBuilder: (context, index) {
        final ticketID = groupedTickets.keys.elementAt(index);
        final categoryTickets = groupedTickets[ticketID]!;
        final ticket = tickets.firstWhere((t) => t['ticketID'] == ticketID, orElse: () => {});
        return Container(
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03, bottom: MediaQuery.of(context).size.width * 0.03),
          decoration: BoxDecoration(
            color: AppColors.calendarBg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black54.withOpacity(0.2),
                offset: const Offset(4, 4),
                blurRadius: 2,
                spreadRadius: 0.1,
              )
            ],
          ),
          child: ExpansionTile(
            iconColor: AppColors.primaryColor,
            collapsedIconColor: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            tilePadding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, right: MediaQuery.of(context).size.width * 0.02),
            initiallyExpanded: false,
            shape: const Border(
                bottom: BorderSide(color: Colors.transparent)
            ),
            title: Text(
              'Ticket $ticketID',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.045,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Fecha: ',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      '${ticket['fecha']}',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.035),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Cantidad total: ',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      '${ticket['cant']} pzs',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.035),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      '\$${ticket['total']}',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.035),
                    ),
                  ],
                ),
              ],
            ),
            children: categoryTickets.map((product) {
              return Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.03),
                color: Colors.transparent,
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
          ),
        );
      },
    ),
  );
}