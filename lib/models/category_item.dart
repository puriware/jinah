import 'package:flutter/material.dart';

class CategoryItem {
  final String? id;
  final String? userId;
  final String? name;
  final String? description;
  final DateTime? created;
  final DateTime? updated;

  CategoryItem({
    @required this.id,
    @required this.userId,
    @required this.name,
    @required this.description,
    @required this.created,
    @required this.updated,
  });
}
