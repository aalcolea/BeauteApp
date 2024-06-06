import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/notificationsForAssistant.dart';

class NotiCards extends StatefulWidget {
  final int index;

  const NotiCards({super.key, required this.index});

  @override
  State<NotiCards> createState() => _NotiCardsState();
}

class _NotiCardsState extends State<NotiCards> {
  int index = 0;

  @override
  void initState() {
    index = widget.index;
    super.initState();
  }

  //print(ListaSingleton.instance.notiforAssistant[0]);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.0025),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01),
              decoration: const BoxDecoration(
                color: Color(0xFF4F2263),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '¡Cita próxima!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width * 0.085,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.05,
                        height: MediaQuery.of(context).size.width * 0.05,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              decoration: const BoxDecoration(
                color: Color(0xFFC5B6CD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Prepárate para tu cita de hoy.',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      Text(
                        ListaSingleton.instance.notiforAssistant[index].name,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Hora: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      Text(
                        ListaSingleton.instance.notiforAssistant[index].hour,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
