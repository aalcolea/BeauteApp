import 'package:flutter/material.dart';

class ModifyAppointment extends StatefulWidget {
  const ModifyAppointment({super.key});

  @override
  State<ModifyAppointment> createState() => _ModifyAppointmentState();
}

class _ModifyAppointmentState extends State<ModifyAppointment> {
  final _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF4F2263), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.029,
                  top: MediaQuery.of(context).size.width * 0.027),
              child: Text(
                'Paciente',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.055),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.029,
                  bottom: MediaQuery.of(context).size.width * 0.034),
              child: Text('Tratamiento',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055)),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.026),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.026),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Fecha:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.026),
              child: TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'DD/M/AAAA',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () {},
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.024),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.026),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Hora:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width * 0.024),
              child: TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'HH:MM',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () {},
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.025,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(color: Colors.red, width: 1),
                        ),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.06)),
                    onPressed: () {},
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: MediaQuery.of(context).size.width * 0.085,
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                                color: Color(0xFF4F2263), width: 1),
                          ),
                          backgroundColor: const Color(0xFF4F2263),
                          surfaceTintColor: const Color(0xFF4F2263),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.026)),
                      onPressed: () {},
                      child: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.048),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
