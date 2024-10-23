import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beaute_app/globalVar.dart';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> sales = [];
class SalesServices{
  final String baseURl = '${SessionManager.instance.baseURL}/ventas/carrito';//?fecha_inicio=2024-10-15&fecha_fin=2024-10-15
  Future<void> fetchSales() async{
    final response=  await http.get(Uri.parse(baseURl));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      var formatter = new DateFormat('dd-MM-yyyy');
      sales = data.map((sales){
        DateTime fecha = DateTime.parse(sales['created_at']);
        return {
          'id' : sales['id'],
          'total' : sales['total'],
          'fecha' : formatter.format(fecha),
          'cantidad' : sales['cantidad'],

        };
      }).toList();
      print('hola data $sales');
    }else{
      throw Exception('Error al obtener las ventas de la API');
    }
  }
}