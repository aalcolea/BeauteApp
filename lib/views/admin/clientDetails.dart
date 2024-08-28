import 'package:beaute_app/styles/AppointmentStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClientDetials extends StatefulWidget {
  const ClientDetials({super.key});

  @override
  State<ClientDetials> createState() => _ClientDetialsState();
}

class _ClientDetialsState extends State<ClientDetials> {
  late ScrollController sController;
  List<String> nombres = ['Banana Barrios', 'Alan Alcolea', 'Colin Colon'];
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

  @override
  void initState() {
    // TODO: implement initState
    sController = ScrollController();
    super.initState();
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
                    right: MediaQuery.of(context).size.width * 0.025),
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
              color: Colors.grey.withOpacity(0.35),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: sController,
                      itemCount: nombres.length,
                      itemBuilder: (context, index) {
                        String currentLetter = nombres[index][0].toUpperCase();
                        String previousLetter = index > 0
                            ? nombres[index - 1][0].toUpperCase()
                            : '';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentLetter != previousLetter) ...[
                              Divider(color: Colors.black),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  currentLetter,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            ListTile(
                              title: Text(nombres[index]),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Column(
                    children: letras.map((letra) {
                      return GestureDetector(
                        onTap: () {
                          scrollToLetter(letra);
                        },
                        child: Text(
                          letra,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          )

          ///

          ///
        ],
      ),
    );
  }

  void scrollToLetter(String letra) {
    // Implementar la lógica para desplazarse a la letra seleccionada.
  }
}
