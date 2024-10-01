import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  double totalCart = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.95,
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.045,
                bottom: MediaQuery.of(context).size.width * 0.02,
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.03
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Color(0xFF4F2263).withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                    final widthItem1 = constraints.maxWidth * 0.45;
                    final widthItem2 = constraints.maxWidth * 0.29;
                    return Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: widthItem1,
                          height: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFF4F2263).withOpacity(0.1), width: 2))
                          ),
                          child: Text(
                            'Producto',
                            style: TextStyle(
                              color: Color(0xFF4F2263),
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: widthItem2,
                          height: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFF4F2263).withOpacity(0.1), width: 2))
                          ),
                          child: Text(
                            'Cant.',
                            style: TextStyle(
                              color: Color(0xFF4F2263),
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          height: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            'Precio',
                            style: TextStyle(
                              color: Color(0xFF4F2263),
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                ),
                /*LayoutBuilder(
                  builder: (context, constraints) {
                    final widthItem1 = constraints.maxWidth * 0.45;
                    final widthItem2 = constraints.maxWidth * 0.29;
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Column(

                          );
                        },
                      ),
                    );
                  }
                )*/
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.03,
              right: MediaQuery.of(context).size.width * 0.03,
              top: MediaQuery.of(context).size.width * 0.01,
              bottom: MediaQuery.of(context).size.width * 0.01
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    color: Color(0xFF4F2263),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.1,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$totalCart',
                      style: TextStyle(
                        color: Color(0xFF4F2263),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.1,
                      ),
                    ),
                    Text(
                      'MXN ',
                      style: TextStyle(
                        color: Color(0xFF4F2263).withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.width * 0.17,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.045,
                bottom: MediaQuery.of(context).size.width * 0.02,
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.03
            ),
            decoration: BoxDecoration(
              color: Color(0xFF4F2263),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Pagar',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.08,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
