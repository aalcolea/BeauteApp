import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beaute_app/globalVar.dart';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> sales = [];
List<Map<String, dynamic>> salesByProduct = [];

class SalesServices{

  final String baseURL = '${SessionManager.instance.baseURL}/ventas/carrito';//?fecha_inicio=2024-10-15&fecha_fin=2024-10-15

  Future<List<Map<String,dynamic>>> fetchSales() async{
    final response=  await http.get(Uri.parse(baseURL));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);

      var formatter = new DateFormat('dd-MM-yyyy');
      return sales = data.map((sales){
        DateTime fecha = DateTime.parse(sales['created_at']);
        return {
          'id' : sales['id'],
          'total' : sales['total'],
          'fecha' : formatter.format(fecha),
          'cantidad' : sales['cantidad'],
          'detalles' : sales['detalles'],

        };
      }).toList();
      print('hola data $sales');
    }else{
      throw Exception('Error al obtener las ventas de la API');
    }
  }

  Future<List<Map<String,dynamic>>> getSalesByProduct({String? fechaInicio, String? fechaFin}) async{
    String url = '$baseURL?fecha_inicio=${fechaInicio ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}&fecha_fin=${fechaFin ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      Map<String, Map<String, dynamic>> productosMap = {};
      var formatter = new DateFormat('dd-MM-yyyy');
      data.expand((venta) => venta['detalles']).forEach((detalle) {
        final producto = detalle['producto'];
        final nombreProducto = producto['nombre'];
        DateTime fecha = DateTime.parse(producto['created_at']);
        final int cantidad = int.tryParse(detalle['cantidad'].toString()) ?? 0;
        final double precio = double.tryParse(detalle['precio'].toString()) ?? 0.0;
        if (productosMap.containsKey(nombreProducto)) {
          productosMap[nombreProducto]!['cantidad'] += cantidad;
          productosMap[nombreProducto]!['total'] += cantidad * precio;
        }else{
          productosMap[nombreProducto] = {
            'cantidad': cantidad,
            'precio': precio,
            'total': cantidad * precio,
            'fecha': formatter.format(fecha),
          };
        }
      });
      return productosMap.entries.map((entry){
        return {
          'nombre': entry.key,
          'cantidad': entry.value['cantidad'],
          'precio': entry.value['precio'],
          'total': entry.value['total'],
          'fecha': entry.value['fecha']
        };
      }).toList();
    } else{
      throw Exception('Error al obtener los productos vendidos');
    }
  }
}