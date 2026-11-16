import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final url = Uri.parse(
      'https://fakestoreapi.com/products',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (data is! List) {
          throw const FormatException('Invalid data');
        }

        return data.map((item) {
          return Product.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
        }).toList();
      }

      if (response.statusCode == 404) {
        throw Exception('404 — Тауарлар табылмады');
      }

      if (response.statusCode >= 500) {
        throw Exception('500 — Серверде қате пайда болды');
      }

      throw Exception(
        'Сұраныс қатесі: ${response.statusCode}',
      );
    } on TimeoutException {
      throw Exception('Сервер 10 секунд ішінде жауап бермеді');
    } on http.ClientException {
      throw Exception('Интернетке қосылу мүмкін болмады');
    } on FormatException {
      throw Exception('Серверден қате мәлімет келді');
    }
  }
}