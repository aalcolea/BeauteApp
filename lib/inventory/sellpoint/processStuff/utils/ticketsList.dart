import 'package:beaute_app/inventory/sellpoint/processStuff/utils/ticketOptions.dart';
import 'package:flutter/material.dart';
import '../../../../../agenda/themes/colors.dart';
import '../../../stock/products/services/productsService.dart';

class Ticketslist extends StatefulWidget {

  final void Function(
      int
  ) onShowBlur;

  const Ticketslist({super.key, required this.onShowBlur});

  @override
  State<Ticketslist> createState() => _TicketslistState();
}

class _TicketslistState extends State<Ticketslist> {

  List<GlobalKey> ticketKeys = [];
  OverlayEntry? overlayEntry;
  double widgetHeight = 0.0;

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

  @override
  void initState() {
    super.initState();
    ticketKeys = List.generate(tickets.length, (index) => GlobalKey());
  }

  void colHeight (double colHeight) {
    widgetHeight = colHeight;
  }

  void showTicketOptions(int index) {
    removeOverlay();
    if (index >= 0 && index < tickets.length) {
      final key = ticketKeys[index];
      final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
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
            top: topPosition - 7,
            left: position.dx,
            width: size.width,
            child: IntrinsicHeight(
              child: TicketOptions(
                onClose: removeOverlay,
                columnHeight: colHeight,
                onShowBlur: widget.onShowBlur, columnH: null
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(overlayEntry!);
      widget.onShowBlur(1);
    } else {
      print("Invalid index: $index");
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    if (mounted) {
      widget.onShowBlur(0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              key: ticketKeys[index],
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
              child: GestureDetector(
                onLongPress: () {
                  widget.onShowBlur(1);
                  showTicketOptions(index);
                },
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
                        title: Column(
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
                      ),
                    );
                  }).toList(),
                ),
              )
          );
        },
      ),
    );
  }
}