import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../calendar/calendarSchedule.dart';
import 'package:beaute_app/forms/appoinmentForm.dart';

class DoctorAdmin extends StatefulWidget {
  const DoctorAdmin({super.key});

  @override
  State<DoctorAdmin> createState() => _DoctorAdminState();
}

class AddAppointmentModal {
  static void showAddAppointmentModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: AppointmentForm(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        );
      },
    );
  }
}

class _DoctorAdminState extends State<DoctorAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(
            right: 85,
          ),
          child: Container(
            width: null,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.person_pin,
                    size: 40,
                    color: Color(0xFF4F2263),
                  ),
                ),
                Text(
                  'Doctor1',
                  style: TextStyle(color: Color(0xFF4F2263), fontSize: 32),
                ),
              ],
            ),
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
        padding:
            const EdgeInsets.only(right: 15, left: 15, bottom: 100, top: 40),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
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
                              size: 60,
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        AddAppointmentModal.showAddAppointmentModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        splashFactory: InkRipple.splashFactory,
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
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
                              size: 60,
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
                child: AgendaSchedule(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
