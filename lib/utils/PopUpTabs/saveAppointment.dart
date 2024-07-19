import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/appointmentModel.dart';

void showConfirmationDialog(BuildContext context, Appointment appointment, TextEditingController dateController, TextEditingController timeController, Function refreshAppointments) {
  Future<void> saveAppointment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No existe el token');
      }
      DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(dateController.text);
      DateTime selectedTime = DateFormat.jm().parse(timeController.text);
      DateTime updatedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      final response = await http.put(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/editAppoinment/${appointment.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': DateFormat('yyyy-MM-dd').format(updatedDateTime),
          'time': DateFormat('HH:mm:ss').format(updatedDateTime),
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        refreshAppointments();
        Navigator.of(context).pop();
      } else {
        throw Exception('Error al actualizar el appointment');
      }
    } catch (e) {
      print('Error saving appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la cita')),
      );
    }
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Edición'),
        content: Text('¿Está seguro de que desea guardar los cambios?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: saveAppointment,
            child: Text('Guardar'),
          ),
        ],
      );
    },
  );
}