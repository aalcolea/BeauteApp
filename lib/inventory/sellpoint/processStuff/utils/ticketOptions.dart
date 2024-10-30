import 'package:flutter/material.dart';
import '../../../../agenda/themes/colors.dart';
import '../../../themes/colors.dart';

class TicketOptions extends StatefulWidget {
  final double heigthCard;
  final List<dynamic> ticketInfo;
  final VoidCallback onClose;
  final Function(double) columnHeight;
  final void Function(int) onShowBlur;
  final dynamic columnH;

  const TicketOptions({super.key, required this.onClose, required this.columnH, required this.onShowBlur, required this.columnHeight, required this.heigthCard, required this.ticketInfo,
  });

  @override
  State<TicketOptions> createState() => _TicketOptionsState();
}

class _TicketOptionsState extends State<TicketOptions> {

  final GlobalKey _columnKey = GlobalKey();
  double _columnHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeight();
    });
  }

  void _calculateHeight() {
    final RenderBox? renderBox =
    _columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _columnHeight = renderBox.size.height;
        widget.columnHeight(_columnHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: Column(
          key: _columnKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  widget.onClose();
                },
                child: Container(
                    height: widget.heigthCard,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02,
                      top: MediaQuery.of(context).size.width * 0.009,
                      bottom: MediaQuery.of(context).size.width * 0.009,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors3.whiteColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02, horizontal: MediaQuery.of(context).size.width * 0.0247),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ticket ${widget.ticketInfo[0]}',
                                style: TextStyle(
                                  color: AppColors3.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Fecha: ${widget.ticketInfo[1]}",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Cantidad total: ${widget.ticketInfo[2]} pzs",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Importe: ",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                              Text(
                                "\$${widget.ticketInfo[3]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                  bottom: MediaQuery.of(context).size.width * 0.02,
                  top: MediaQuery.of(context).size.width * 0.02
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors3.whiteColor,
              ),
              child: Column(
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {

                            },
                            style: const ButtonStyle(
                              alignment: Alignment.centerLeft,
                            ),
                            child: const Text(
                              'Editar producto',
                              style: TextStyle(
                                  color: AppColors3.primaryColor
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors3.primaryColor.withOpacity(0.1),
                    thickness: MediaQuery.of(context).size.width * 0.004,
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              widget.onClose();
                              widget.onShowBlur(1);
                            },
                            style: const ButtonStyle(
                                alignment: Alignment.centerLeft
                            ),
                            child: const Text(
                              'Modificar stock',
                              style: TextStyle(
                                  color: AppColors3.primaryColor
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors3.primaryColor.withOpacity(0.1),
                    thickness: MediaQuery.of(context).size.width * 0.004,
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              widget.onClose();
                              widget.onShowBlur(1);
                            },
                            style: const ButtonStyle(
                                alignment: Alignment.centerLeft
                            ),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(
                                  color: AppColors3.redDelete
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }
}
