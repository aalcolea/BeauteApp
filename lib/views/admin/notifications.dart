import 'package:beaute_app/models/notificationsForAssistant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/paintToNotifications.dart';
import '../../utils/sliverlist/notiCards.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  double? screenWidth;
  double? screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      width: MediaQuery.of(context).size.width,
      height: null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: screenWidth! < 370.00
                      ? MediaQuery.of(context).size.height * 0.027
                      : MediaQuery.of(context).size.height * 0.0255,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF4F2263),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth! < 370.00
                          ? MediaQuery.of(context).size.width * 0.75
                          : MediaQuery.of(context).size.width * 0.775,
                    ),
                    CustomPaint(
                      painter: TrianglePainter(),
                      size: Size(MediaQuery.of(context).size.width * 0.1,
                          MediaQuery.of(context).size.width * 0.065),
                    ),
                  ],
                ),

                ///--------------------------------------------------------------------------------
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                child: Text(
                                  'HOY',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.0035,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F2263),
                            ),
                          ),

                          ///
                          Column(
                            children: ListaSingleton.instance.notiforAssistant
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              return NotiCards(index: index);
                            }).toList(),
                          ),

                          ///
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.01,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                child: Text(
                                  'AYER',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.0035,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F2263),
                            ),
                          ),
                          Column(
                            children: ListaSingleton.instance.notiforAssistant
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              return NotiCards(index: index);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
