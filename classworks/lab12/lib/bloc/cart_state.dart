import 'package:equatable/equatable.dart';
import '../models/product.dart';

class CartState extends Equatable {
  final List<Product> items;
  final int totalPrice;
  final int count;

  CartState({
    required List<Product> items,
    required this.totalPrice,
    required this.count,
  }) : items = List.unmodifiable(items);

  factory CartState.fromItems(List<Product> items) {
    int total = 0;

    for (final product in items) {
      total += product.price;
    }

    return CartState(
      items: items,
      totalPrice: total,
      count: items.length,
    );
  }

  @override
  List<Object> get props => [items, totalPrice, count];
}