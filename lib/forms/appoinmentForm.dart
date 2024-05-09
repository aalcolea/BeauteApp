import 'package:flutter/material.dart';

class AppointmentForm extends StatelessWidget {
  const AppointmentForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Nueva cita',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Cliente',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: <String>['Cliente 1', 'Cliente 2', 'Cliente 3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {},
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Fecha',
              hintText: 'DD/MM/AAAA',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () {
              // Aquí puedes integrar un picker de fecha
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Hora',
              hintText: 'HH:MM',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            onTap: () {
              // Aquí puedes integrar un picker de tiempo
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Tratamiento',
              border: OutlineInputBorder(),
              hintText: 'Describa el tratamiento...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {

            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // ancho doble
            ),
            child: const Text('Crear cita'),
          ),
        ],
      ),
    );
  }
}
