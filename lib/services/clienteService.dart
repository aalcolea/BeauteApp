import 'dart:convert';

import 'package:http/http.dart' as http;

class ClientService {
  final String baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/deleteClient/';

  Future<void> deleteClient(int id) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('Cliente eliminado con éxito');
      } else {
        print('Error al eliminar el cliente: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchAppointmentByUser(int id) async {
    final String url = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/getAppoinmentsByUser/$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        return {
          'error': jsonDecode(response.body)['message'],
        };
      } else {
        return {
          'error': 'Error en la solicitud: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'error': 'Ha ocurrido un error: $e',
      };
    }
  }
}
