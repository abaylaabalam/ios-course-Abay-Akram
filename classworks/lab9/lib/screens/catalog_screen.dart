import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  final List<Product> products = const [
    Product(
      id: '1',
      name: 'Домбыра',
      category: 'Аспап',
      price: 39900,
      icon: Icons.music_note,
    ),
    Product(
      id: '2',
      name: 'Шапан',
      category: 'Киім',
      price: 29900,
      icon: Icons.checkroom,
    ),
    Product(
      id: '3',
      name: 'Тақия',
      category: 'Киім',
      price: 8900,
      icon: Icons.face,
    ),
    Product(
      id: '4',
      name: 'Торсық',
      category: 'Ыдыс',
      price: 12500,
      icon: Icons.local_drink,
    ),
    Product(
      id: '5',
      name: 'Оюлы кесе',
      category: 'Ыдыс',
      price: 6500,
      icon: Icons.coffee,
    ),
    Product(
      id: '6',
      name: 'Киіз кілем',
      category: 'Үй',
      price: 42000,
      icon: Icons.grid_on,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DALA.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(22),
            color: Colors.black,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ҚАЗАҚ БҰЙЫМДАРЫ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '6 бұйым / DALA COLLECTION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              separatorBuilder: (context, index) {
                return const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                final product = products[index];
                final selected = cart.contains(product.id);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 65,
                        color: Colors.grey.shade100,
                        child: Icon(
                          product.icon,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.category,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${product.price} ₸',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          cart.toggle(product);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected
                              ? Colors.white
                              : Colors.black,
                          foregroundColor: selected
                              ? Colors.black
                              : Colors.white,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                        child: Text(
                          selected ? 'Убрать' : 'В корзину',
                          style: const TextStyle(fontSize: 12),
                        ),
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