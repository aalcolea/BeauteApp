import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beaute_app/globalVar.dart';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> sales = [];
List<Map<String, dynamic>> salesByProduct = [];
class SalesServices{
  final String baseURL = '${SessionManager.instance.baseURL}/ventas/carrito';//?fecha_inicio=2024-10-15&fecha_fin=2024-10-15
  Future<void> fetchSales() async{
    final response=  await http.get(Uri.parse(baseURL));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      print(data);
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

  Future<void> getSalesByProduct({String? fechaInicio, String? fechaFin}) async{
    String url = '$baseURL?fecha_inicio=${fechaInicio ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}&fecha_fin=${fechaFin ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      Map<String, Map<String, dynamic>> productosMap = {};
      data.expand((venta) => venta['detalles']).forEach((detalle) {
        final producto = detalle['producto'];
        final nombreProducto = producto['nombre'];
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
          };
        }
      });
      final productos = productosMap.entries.map((entry){
        return {
          'nombre': entry.key,
          'cantidad': entry.value['cantidad'],
          'precio': entry.value['precio'],
          'total': entry.value['total'],
        };
      }).toList();
      print('Productos vendidos: $productos');
    } else{
      throw Exception('Error al obtener los productos vendidos');
    }
  }
}