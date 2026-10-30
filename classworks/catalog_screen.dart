import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool isGrid = false;
  int nextId = 0;

  final List<Product> initialProducts = [
    Product(
      id: '1',
      name: 'Домбыра',
      category: 'Аспап',
      price: '39 900 ₸',
      rating: 4.9,
      icon: Icons.music_note,
    ),
    Product(
      id: '2',
      name: 'Шапан',
      category: 'Киім',
      price: '29 900 ₸',
      rating: 4.8,
      icon: Icons.checkroom,
    ),
    Product(
      id: '3',
      name: 'Тақия',
      category: 'Киім',
      price: '8 900 ₸',
      rating: 4.7,
      icon: Icons.checkroom,
    ),
    Product(
      id: '4',
      name: 'Торсық',
      category: 'Ыдыс',
      price: '12 500 ₸',
      rating: 4.6,
      icon: Icons.local_drink,
    ),
    Product(
      id: '5',
      name: 'Оюлы кесе',
      category: 'Ыдыс',
      price: '6 500 ₸',
      rating: 4.8,
      icon: Icons.coffee,
    ),
    Product(
      id: '6',
      name: 'Қамшы',
      category: 'Дәстүр',
      price: '14 900 ₸',
      rating: 4.7,
      icon: Icons.category,
    ),
    Product(
      id: '7',
      name: 'Киіз кілем',
      category: 'Үй',
      price: '42 000 ₸',
      rating: 4.9,
      icon: Icons.grid_on,
    ),
    Product(
      id: '8',
      name: 'Күміс білезік',
      category: 'Әшекей',
      price: '18 900 ₸',
      rating: 4.8,
      icon: Icons.diamond,
    ),
  ];

  late List<Product> products;

  @override
  void initState() {
    super.initState();
    products = List.from(initialProducts);
  }

  Future<void> refreshProducts() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    );

    if (!mounted) return;

    final names = [
      'Құрақ көрпе',
      'Оюлы сөмке',
      'Асық жиынтығы',
    ];

    final newProduct = Product(
      id: 'new-$nextId',
      name: names[nextId % names.length],
      category: 'Жаңа',
      price: '9 900 ₸',
      rating: 5.0,
      icon: Icons.shopping_bag,
    );

    setState(() {
      products.insert(0, newProduct);
      nextId++;
    });
  }

  void deleteProduct(Product product) {
    final index = products.indexWhere(
      (item) => item.id == product.id,
    );

    if (index == -1) return;

    setState(() {
      products.removeAt(index);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} өшірілді'),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            if (!mounted) return;

            if (products.any((item) => item.id == product.id)) {
              return;
            }

            setState(() {
              final position = index > products.length
                  ? products.length
                  : index;

              products.insert(position, product);
            });
          },
        ),
      ),
    );
  }

  void resetCatalog() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      products = List.from(initialProducts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DALA.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isGrid ? 'List view' : 'Grid view',
            icon: Icon(
              isGrid ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ҚАЗАҚ БҰЙЫМДАРЫ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${products.length} бұйым  /  ${isGrid ? "GRID" : "LIST"}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? emptyCatalog()
                : RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    onRefresh: refreshProducts,
                    child: isGrid
                        ? gridCatalog()
                        : listCatalog(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget listCatalog() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 0.7,
        );
      },
      itemBuilder: (context, index) {
        final product = products[index];

        return Dismissible(
          key: ValueKey(product.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (direction) {
            deleteProduct(product);
          },
          child: ProductTile(product: product),
        );
      },
    );
  }

  Widget gridCatalog() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return ProductGridCard(
          product: products[index],
        );
      },
    );
  }

  Widget emptyCatalog() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 65,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          const Text(
            'Catalog is Empty',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Барлық бұйымдар өшірілді',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: resetCatalog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
            child: const Text('Reset Catalog'),
          ),
        ],
      ),
    );
  }
}