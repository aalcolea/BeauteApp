import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../calendar/calendarSchedule.dart';
import '../../forms/clientForm.dart';
import '../../utils/drSelectbox.dart';
import 'drAdmin.dart';

class AssistantAdmin extends StatefulWidget {
  const AssistantAdmin({super.key});

  @override
  State<AssistantAdmin> createState() => _AssistantAdminState();
}

class addClientModal {
  static void showClientModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: const ClientForm(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        );
      },
    );
  }
}

class _AssistantAdminState extends State<AssistantAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(
            right: 60,
          ),
          child: Container(
            width: null,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: const DoctorSelectbox(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: Color(0xFF4F2263),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              size: 40,
              color: Color(0xFF4F2263),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        //modifica el container del calendario
        padding: EdgeInsets.only(
            right: 15,
            left: 15,
            bottom: MediaQuery.of(context).size.height * 0.075,
            top: 25),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height *
                                0.07 /*60*/,
                            bottom: MediaQuery.of(context).size.height * 0.07),
                        elevation: 10,
                        surfaceTintColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                              color: Color(0xFF4F2263), width: 2),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_note,
                              size: 40,
                              color: Color(0xFF8AB6DD),
                            ),
                            Text(
                              'Para hoy',
                              style: TextStyle(
                                color: Color(0xFF8AB6DD),
                                fontSize: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/citaScreen');
                          //AddAppointmentModal.showAddAppointmentModal(context);
                        },
                        style: ElevatedButton.styleFrom(
                          splashFactory: InkRipple.splashFactory,
                          padding: const EdgeInsets.only(
                              left: 34, right: 34, top: 5, bottom: 5),
                          elevation: 10,
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                                color: Color(0xFF4F2263), width: 2),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.note_add_outlined,
                                size: 40,
                                color: Color(0xFF8AB6DD),
                              ),
                              Text(
                                'Crear cita',
                                style: TextStyle(
                                  color: Color(0xFF8AB6DD),
                                  fontSize: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      ElevatedButton(
                        onPressed: () {
                          addClientModal.showClientModal(context);
                        },
                        style: ElevatedButton.styleFrom(
                          splashFactory: InkRipple.splashFactory,
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 5, right: 5),
                          elevation: 10,
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                                color: Color(0xFF4F2263), width: 2),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_add_alt_outlined,
                                size: 40,
                                color: Color(0xFF8AB6DD),
                              ),
                              Text(
                                'Agregar Cliente',
                                style: TextStyle(
                                  color: Color(0xFF8AB6DD),
                                  fontSize: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4F2263),
                    width: 2,
                  ),
                ),
                child: const AgendaSchedule(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
