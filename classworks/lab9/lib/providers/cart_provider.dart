import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  int get count => _items.length;

  int get totalPrice {
    int total = 0;

    for (final product in _items) {
      total += product.price;
    }

    return total;
  }

  bool contains(String id) {
    return _items.any((product) => product.id == id);
  }

  void toggle(Product product) {
    if (contains(product.id)) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }

    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}