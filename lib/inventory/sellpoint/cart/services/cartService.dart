import 'package:beaute_app/inventory/stock/products/services/productsService.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {

  List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> get cart => _cart;
  double total_price = 0;
  void addProductToCart(int product_id) {
    try {
      final product = products_global.firstWhere(
            (prod) => prod['product_id'] == product_id,
        orElse: () => {},
      );
      if (product != null) {
        final stockAvailable = product['cant_cart']['cantidad'];
        if (stockAvailable <= 0) {
          print('No hay suficiente stock para este producto');

          return;
        }
        bool check = false;
        for (var item in _cart) {
          if (item['product_id'] == product_id) {
            if (item['cant_cart'] < stockAvailable) {
              item['cant_cart'] += 1;
            } else {
              print('No puedes agregar más de lo que hay en stock');
            }
            check = true;
            break;
          }
        }
        if (!check) {
          _cart.add({
            'product': product['product'],
            'price': product['price'].toDouble(),
            'cant_cart': 1.0,
            'product_id': product['product_id']
          });
        }
        notifyListeners();
      } else {
        print('Producto no encontrado en la lista global');
      }
    } catch (e) {
      print('Error al agregar producto: $e');
    }
    print(_cart);
  }
  void decrementProductInCart(int productId) {
    for (var item in _cart) {
      if (item['product_id'] == productId) {
        if (item['cant_cart'] > 1) {
          item['cant_cart'] -= 1;
        } else {
          _cart.remove(item);
        }
        break;
      }
    }
    notifyListeners();
  }
  int getProductCount(int productId) {
    final product = _cart.firstWhere(
          (item) => item['product_id'] == productId,
      orElse: () => {'cant_cart': 0.0},
    );
    return (product['cant_cart'] as double).toInt();
  }


}