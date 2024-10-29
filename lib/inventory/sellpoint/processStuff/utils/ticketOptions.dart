import 'package:flutter/material.dart';
import '../../../themes/colors.dart';

class TicketOptions extends StatefulWidget {

  final VoidCallback onClose;
  final Function(double) columnHeight;
  final void Function(
      int
      ) onShowBlur;
  final dynamic columnH;

  const TicketOptions({super.key, required this.onClose, required this.columnH, required this.onShowBlur, required this.columnHeight,
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
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02,
                      top: MediaQuery.of(context).size.width * 0.009,
                      bottom: MediaQuery.of(context).size.width * 0.009,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02, horizontal: MediaQuery.of(context).size.width * 0.0247),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola',
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
                                style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                              ),
                              Text(
                                'cant',//products_global[index]['cant_cart'] == null ? 'Agotado' : '${products_global[index]['cant_cart']['cantidad']}',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.035
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Precio: ",
                                style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  '\$precio MXN',//"\$${products_global[]['price']} MXN",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                  ),
                                ),
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
                color: AppColors.whiteColor,
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
                                  color: AppColors.primaryColor
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors.primaryColor.withOpacity(0.1),
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
                                  color: AppColors.primaryColor
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors.primaryColor.withOpacity(0.1),
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
                                  color: AppColors.redDelete
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
