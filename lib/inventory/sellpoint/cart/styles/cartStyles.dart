import 'package:flutter/material.dart';

class Background extends StatefulWidget {
  final double widthItem1;
  final double widthItem2;
  const Background({super.key, required this.widthItem1, required this.widthItem2});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            alignment: Alignment.topLeft,
            width: widget.widthItem1,
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: const Color(0xFF4F2263).withOpacity(0.1), width: 2))
            ),
            child: Column(
              children: [
                Text(
                  'Producto',
                  style: TextStyle(
                    color: const Color(0xFF4F2263),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Divider()
              ],
            )
        ),
        Container(
            alignment: Alignment.topLeft,
            width: widget.widthItem2,
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: const Color(0xFF4F2263).withOpacity(0.1), width: 2))
            ),
            child: Column(
              children: [
                Text(
                  'Cant.',
                  style: TextStyle(
                    color: const Color(0xFF4F2263),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Divider()
              ],
            )
        ),
        Expanded(child: Container(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Text(
                  'Precio',
                  style: TextStyle(
                    color: const Color(0xFF4F2263),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Divider(color: Colors.grey,)
              ],
            )
        ),),
      ],
    );
  }
}
