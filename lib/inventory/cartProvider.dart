import 'package:beaute_app/inventory/services/productsService.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {

  List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> get cart => _cart;
  double total_price = 0;

  void addElement(int product_id) {
    final product = products_global.firstWhere((prod) => prod['product_id'] == product_id);
    bool check = false;
    for (var item in _cart) {
      if (item['product_id'] == product_id) {
        item['cant_cart'] += 1;
        check = true;
        break;
      }
    }
    if (!check) {
      _cart.add({'product': product['product'], 'price': product['price'].toDouble(), 'cant_cart': product['cant_cart'].toDouble(), 'product_id': product['product_id']});
    }
    notifyListeners();
    print(_cart);
  }
  void decrementElement(int product_id) {
    for (var item in _cart) {
      if (item['product_id'] == product_id) {
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
}