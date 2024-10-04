import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, dynamic>> products_global = [];
class ProductService {
  final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/productos';

  Future<void> fetchProducts(int categoryId) async {
    final String url = '$baseURL?category_id=$categoryId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      products_global.clear();

      products_global = data.map((product) {
        double price = 0.0;
        if (product['precio'] is String) {
          price = double.tryParse(product['precio']) ?? 0.0;
        } else if (product['precio'] is num) {
          price = (product['precio'] as num).toDouble();
        }

        return {
          'product': product['nombre'],
          'price': price,
          'cant_cart': product['stock'],
          'product_id': product['id'],
        };
      }).toList();
    } else {
      throw Exception('Error al obtener los productos de la API');
    }
  }

  Future<void> createProduct({required String nombre, required double precio, required String codigoBarras, String? descripcion, int? categoryId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    try {
      final Uri uri = Uri.parse(baseURL);
      final http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nombre'] = nombre;
      request.fields['precio'] = precio.toString();
      request.fields['codigo_barras'] = codigoBarras;
      if(descripcion != null){
        request.fields['descripcion'] = descripcion;
      }
      if(categoryId != null){
        request.fields['category_id'] = categoryId.toString();
      }
      final http.StreamedResponse response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      if (response.statusCode == 201) {
        print('Producto creado exitosamente');
      } else {
        final responseData = jsonDecode(responseBody.body);
        throw Exception(responseData['message'] ?? 'Error al crear el producto');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error al crear el producto: $e');
    }
  }
}
