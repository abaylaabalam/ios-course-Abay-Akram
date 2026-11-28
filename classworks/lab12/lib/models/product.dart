import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final int price;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });

  @override
  List<Object> get props => [id, name, price, icon];
}