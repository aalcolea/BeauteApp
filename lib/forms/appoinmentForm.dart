import 'package:flutter/material.dart';

class AppointmentForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Nueva cita',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            decoration: InputDecoration(
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
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Fecha',
              hintText: 'DD/MM/AAAA',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () {
              // Aquí puedes integrar un picker de fecha
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Hora',
              hintText: 'HH:MM',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            onTap: () {
              // Aquí puedes integrar un picker de tiempo
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Tratamiento',
              border: OutlineInputBorder(),
              hintText: 'Describa el tratamiento...',
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Acción al presionar el botón de Crear cita
            },
            child: Text('Crear cita'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // ancho doble
            ),
          ),
        ],
      ),
    );
  }
}
