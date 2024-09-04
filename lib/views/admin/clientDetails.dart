import 'package:beaute_app/styles/AppointmentStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ClientDetials extends StatefulWidget {
  const ClientDetials({super.key});

  @override
  State<ClientDetials> createState() => _ClientDetialsState();
}

class _ClientDetialsState extends State<ClientDetials> {

  late ScrollController sController;
  String currentLetter = '';
  double? screenWidth;
  double? screenHeight;
  int sliverrenderizados = 0;
  List<String> nombres = [
    'Alan Alcolea',
    'Banana Barrios',
    'Banana Barrios',
    'Colin Colon',
    'Colin Colon',
    'Colin Colon',
    'Colin Colon',
    'Colin Colon',
    'Dorito Duran',
    'Dorito Duran',
    'Ector Eslobaco',
    'Ector Eslobaco',
    'Facundo Ferros',
    'Facundo Ferros',
    'Galo Galindo',
    'Galo Galind',
    'Galo Galindo',
    'Galo Galindo',
  ];
  List<String> letras = [
    '#',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'Ñ',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  int sliversVisibles = 9;
  int result = 0;
  int indexatTop = 0;
  int indexatTopHelper = 0;
  int lastrenderIndex = 0;
  double _previousOffset = 0;
  bool scrollDirection = false; // false para abajo, true para arriba

  void _onScroll() {
    ///
    double currentOffset = sController.offset;
    if (currentOffset > _previousOffset) {
      scrollDirection = false;
    } else if (currentOffset < _previousOffset) {
      scrollDirection = true;
    }
    _previousOffset = currentOffset;
    ///

    int index = indexatTop;
    if(index == 0){
    }
    String newLetter = nombres[index][0].toUpperCase();

    if (newLetter != currentLetter) {
      setState(() {
        currentLetter = newLetter;
      });
    }
  }

  int totalNamesWhitLetter(String letra) {
    return nombres.where((nombre) => nombre.startsWith(letra)).length;
  }
  
  @override
  void initState() {
    // TODO: implement initState
    sController = ScrollController();
    sController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sController.removeListener(_onScroll);
    sController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.045,
                  ),
                  child: FieldsToWrite(
                    preffixIcon: Icon(
                      CupertinoIcons.search,
                      size: MediaQuery.of(context).size.width * 0.07,
                    ),
                    labelText: 'Buscar...',
                    readOnly: false,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.025,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: Icon(Icons.person_add_alt_outlined,
                      size: MediaQuery.of(context).size.width * 0.11),
                ),
              ),
            ],
          ),

          ///
          Expanded(
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(child: Column(
                    children: [
                      Container(
                        //MediaQuery.of(context).size.width * 0.105 // 0.075 + 0.03
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.025,
                            right: MediaQuery.of(context).size.width * 0.03,
                            top: MediaQuery.of(context).size.width * 0.03,
                            bottom: MediaQuery.of(context).size.width * 0.03
                            ),
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.025,
                          bottom: MediaQuery.of(context).size.width * 0.01,
                          top: MediaQuery.of(context).size.width * 0.01,

                        ),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F2263),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          currentLetter == '' ? 'A' : currentLetter,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          //physics: const BouncingScrollPhysics(),
                          controller: sController,
                          slivers: [
                            // false para abajo, true para arriba
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    sliverrenderizados = index;
                                    result = sliverrenderizados - sliversVisibles;
                                    //print('sliverrenderizados $sliverrenderizados');
                                    //print('sliversVisibles $sliversVisibles');
                                    //print('result $result');
                                    if (result < 0) {
                                      indexatTop = 0;
                                    } else {
                                      if(scrollDirection == false){
                                        indexatTop = sliverrenderizados - sliversVisibles;
                                      } else if(scrollDirection == true){
                                      }

                                    }
                                    String currentLetter = nombres[index][0].toUpperCase();
                                  String previousLetter = index > 0 ? nombres[index - 1][0].toUpperCase() : '';
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (currentLetter != previousLetter) ...[
                                        /// Container de color morado que tiene la letra
                                        Visibility(
                                          visible: currentLetter == 'A' ? false : true,
                                          child: Container(
                                          //MediaQuery.of(context).size.width * 0.105 // 0.075 + 0.03gi
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.width * 0.025,
                                              right: MediaQuery.of(context).size.width * 0.03,
                                              bottom: MediaQuery.of(context).size.width * 0.03),
                                          padding: EdgeInsets.only(
                                            left: MediaQuery.of(context).size.width * 0.025,
                                            bottom: MediaQuery.of(context).size.width * 0.01,
                                            top: MediaQuery.of(context).size.width * 0.01,

                                          ),
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4F2263).withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            currentLetter,
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),),

                                      ],
                                      ListTile(
                                        key: ValueKey(nombres[index]),
                                        title: Text(
                                          nombres[index],
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width * 0.05,
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  textAlign: TextAlign.end,
                                                  '9999 XXXX XXXX',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                                  ),
                                                ),
                                                Text(
                                                  textAlign: TextAlign.end,
                                                  'correogen@gmail.com',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height * 0.003,
                                              color: const Color(0xFF4F2263),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                },
                                childCount: nombres.length,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),

                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.065),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: letras.map((letra) {
                        return Expanded(child: GestureDetector(
                            onTap: () {
                              scrollToLetter(letra);
                            },
                            child: Text(
                              letra,
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.036,
                                  fontWeight: FontWeight.bold,
                                  color: currentLetter == letra
                                      ? const Color(0xFF4F2263)
                                      : Colors.grey),
                            )));
                        }).toList()))
                  ])))
        ]));
  }

  void scrollToLetter(String letra) {
    // Implementar la lógica para desplazarse a la letra seleccionada.
  }
}
