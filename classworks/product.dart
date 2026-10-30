import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String price;
  final double rating;
  final IconData icon;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.icon,
  });
}