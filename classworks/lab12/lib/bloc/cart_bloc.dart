import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState.fromItems([])) {
    on<AddProductEvent>((event, emit) {
      final items = List<Product>.from(state.items);
      items.add(event.product);

      emit(CartState.fromItems(items));
    });

    on<RemoveProductEvent>((event, emit) {
      final items = List<Product>.from(state.items);

      final index = items.indexWhere(
        (product) => product.id == event.productId,
      );

      if (index != -1) {
        items.removeAt(index);
      }

      emit(CartState.fromItems(items));
    });

    on<ClearCartEvent>((event, emit) {
      emit(CartState.fromItems([]));
    });
  }
}