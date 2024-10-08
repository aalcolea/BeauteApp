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
}
