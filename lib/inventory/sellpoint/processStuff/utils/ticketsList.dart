import 'package:beaute_app/inventory/sellpoint/processStuff/utils/ticketOptions.dart';
import 'package:flutter/material.dart';
import '../../../../../agenda/themes/colors.dart';
import '../../../stock/products/services/productsService.dart';
import '../services/salesServices.dart';

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
  bool isLoading = false;
  List<Map<String, dynamic>> tickets = [];
  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<int> tapedIndices = [];

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
    ticketKeys = List.generate(products_global.length, (index) => GlobalKey());
    fetchSales();
    print(fetchSales());
  }

  Future<void> fetchSales() async{
    setState(() {
      isLoading = true;
    });
    try{
      final salesService = SalesServices();
      final tickets2 = await salesService.fetchSales();
      setState(() {
        tickets = tickets2;
        tickets2.sort((a, b) => b['id'].compareTo(a['id']));
        ticketKeys = List.generate(tickets.length, (index) => GlobalKey());  // Actualiza ticketKeys
        cantHelper = List.generate(tickets.length, (index) => 0);
        isLoading = false;
      });
    }catch (e) {
      print('Error fetching sales: $e');
      isLoading = false;
    }
  }

  void colHeight (double colHeight) {
    widgetHeight = colHeight;
  }

  void showTicketOptions(int index) {
    if (index >= 0 && index < tickets.length) {
      removeOverlay();
      final key = ticketKeys[index];
      if (key.currentContext != null && key.currentContext!.findRenderObject() is RenderBox) {
        final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        final availableSpaceBelow = screenHeight - position.dy;

        double topPosition;

        if (availableSpaceBelow >= widgetHeight) {
          topPosition = position.dy;
        } else {
          topPosition = screenHeight - widgetHeight - MediaQuery.of(context).size.height * 0.03;
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
                  onShowBlur: widget.onShowBlur,
                  columnH: null,
                ),
              ),
            );
          },
        );
        Overlay.of(context).insert(overlayEntry!);
        widget.onShowBlur(1);
      } else {
        print("RenderBox is null or not valid for ticket $index");
      }
    } else {
      print("Invalid index or no tickets available");
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    for (var controller in aniControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
    if (mounted) {
      widget.onShowBlur(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final groupedTickets = groupByTicket(ticketProducts);
    return Container(
      color: AppColors2.calendarBg,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          return Container(
              key: ticketKeys[index],
              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03, bottom: MediaQuery.of(context).size.width * 0.03),
              decoration: BoxDecoration(
                color: AppColors2.calendarBg,
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
                  showTicketOptions(index);
                  widget.onShowBlur(2);
                },
                child: ExpansionTile(
                  iconColor: AppColors2.calendarBg,
                  collapsedIconColor: AppColors2.primaryColor,
                  backgroundColor: AppColors2.primaryColor,
                  collapsedBackgroundColor: Colors.transparent,
                  textColor: AppColors2.calendarBg,
                  collapsedTextColor: AppColors2.primaryColor,
                  tilePadding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.04,
                      right: MediaQuery.of(context).size.width * 0.02,
                      top: MediaQuery.of(context).size.width * 0.01,
                      bottom: MediaQuery.of(context).size.width * 0.015
                  ),
                  initiallyExpanded: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: AppColors2.primaryColor,
                      width: 2
                    )
                  ),
                  title: Text(
                    'Ticket ${tickets[index]['id']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
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
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                          Text(
                            '${tickets[index]['fecha']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.04),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Cantidad total: ',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04
                            ),
                          ),
                          Text(
                            '${tickets[index]['cantidad']} pzs',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.04),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Total: ',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04
                            ),
                          ),
                          Text(
                            '\$${tickets[index]['total']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.04),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04, top: MediaQuery.of(context).size.width * 0.04, left: MediaQuery.of(context).size.width * 0.04),
                      decoration: const BoxDecoration(
                        color: AppColors2.calendarBg,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                        border: Border(
                          top: BorderSide(color: AppColors2.primaryColor, width: 2)
                        )
                      ),
                      child: Column(
                        children: tickets[index]['detalles'].map<Widget>((detalle) {
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.06),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${detalle['producto']['nombre']}',
                                  style: TextStyle(
                                    color: AppColors2.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Cant.: ",
                                      style: TextStyle(
                                          color: AppColors2.primaryColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '${detalle['cantidad']} pzs',
                                      style: TextStyle(
                                          color: AppColors2.primaryColor,
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
                                          color: AppColors2.primaryColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '\$${detalle['precio']}',
                                      style: TextStyle(
                                        color: AppColors2.primaryColor,
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
                                          color: AppColors2.primaryColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '\$${detalle['cantidad'] * double.parse(detalle['precio'])}',
                                      style: TextStyle(
                                        color: AppColors2.primaryColor,
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
                      ),
                    )
                  ]
                ),
              )
          );
        },
      ),
    );
  }
}