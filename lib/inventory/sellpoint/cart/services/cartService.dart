import 'package:beaute_app/inventory/stock/products/services/productsService.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> get cart => _cart;
  double total_price = 0;

  void addProductToCart(int product_id){
    final productInCart = _cart.firstWhere(
          (prod) => prod['product_id'] == product_id,
      orElse: () => <String, dynamic>{},
    );
    if (productInCart.isNotEmpty){
      final stockDisponible = productInCart['stock'];
      if (productInCart['cant_cart'] < stockDisponible){
        productInCart['cant_cart'] += 1;
      }else{
        print('No puedes agregar más de lo disponible en stock');
      }
    }else{
      final product = products_global.firstWhere(
            (prod) => prod['product_id'] == product_id,
        orElse: () => <String, dynamic>{},
      );
      if (product.isNotEmpty){
        _cart.add({
          'product': product['product'],
          'price': product['price'],
          'cant_cart': 1.0,
          'product_id': product['product_id'],
          'stock': product['cant_cart']['cantidad'],
        });
      }else{
        print('Producto no encontrado en products_global');
      }
    }
    notifyListeners();
    print(_cart);
  }
  void decrementProductInCart(int productId){
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
  int getProductCount(int productId){
    final productInCart = _cart.firstWhere(
          (item) => item['product_id'] == productId,
      orElse: () => <String, dynamic>{},
    );
    return productInCart.isNotEmpty && productInCart['cant_cart'] is num ? (productInCart['cant_cart'] as num).toInt() : 0;
  }
}