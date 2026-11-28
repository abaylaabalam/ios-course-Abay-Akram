import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'cart_screen.dart';

const List<Product> products = [
  Product(
    id: 1,
    name: 'Домбыра',
    price: 39900,
    icon: Icons.music_note,
  ),
  Product(
    id: 2,
    name: 'Шапан',
    price: 29900,
    icon: Icons.checkroom,
  ),
  Product(
    id: 3,
    name: 'Тақия',
    price: 8900,
    icon: Icons.face,
  ),
  Product(
    id: 4,
    name: 'Торсық',
    price: 12500,
    icon: Icons.water_drop_outlined,
  ),
  Product(
    id: 5,
    name: 'Оюлы кесе',
    price: 6500,
    icon: Icons.local_cafe_outlined,
  ),
  Product(
    id: 6,
    name: 'Киіз кілем',
    price: 42000,
    icon: Icons.grid_view,
  ),
];

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    final username = authState is AuthSuccess
        ? authState.username
        : 'Қонақ';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DALA.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Себет',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                icon: Badge(
                  isLabelVisible: state.count > 0,
                  label: Text('${state.count}'),
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 26,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сәлем, $username!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Біздің тауарлар',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: products.length,
              separatorBuilder: (context, index) {
                return const Divider(height: 20);
              },
              itemBuilder: (context, index) {
                final product = products[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 75,
                        color: const Color(0xFFF2F2F2),
                        child: Icon(
                          product.icon,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${product.price} ₸',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                            AddProductEvent(product),
                          );
                        },
                        child: const Text('Қосу'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}