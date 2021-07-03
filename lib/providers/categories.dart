import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/category_item.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

class Categories with ChangeNotifier {
  // final uuid = Uuid();
  List<CategoryItem> _items = [];

  final String? authToken;
  final String? userId;

  Categories(this._items, {this.authToken, this.userId});

  List<CategoryItem> get items {
    return [..._items];
  }

  String categoryName(String id) {
    return _items.firstWhere((cat) => cat.id == id).name.toString();
  }

  Future<void> fetchAndSetCategories() async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    if (authToken != null) {
      var url = Uri.https(
        apiDB,
        '/categories.json',
        {
          'auth': authToken,
          'orderBy': '"userId"',
          'equalTo': '"$userId"',
        },
      );
      final response = await http.get(url);
      if (response.body.isNotEmpty) {
        final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
        if (extractedData.isEmpty) {
          return null;
        }
        final List<CategoryItem> loadedCategories = [];
        extractedData.forEach((categoryID, categoryData) {
          loadedCategories.add(
            CategoryItem(
              id: categoryID,
              userId: categoryData['userId'],
              name: categoryData['name'],
              description: categoryData['description'],
              created: DateTime.parse(categoryData['created'].toString()),
              updated: DateTime.parse(categoryData['updated'].toString()),
            ),
          );
        });
        _items = loadedCategories;
        if (_items.length <= 0) initData();
        notifyListeners();
      }
    }
  }

  Future<void> addCategoryItem(CategoryItem newCategory) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/categories.json',
      {'auth': authToken},
    );
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'userId': userId,
            'name': newCategory.name,
            'description': newCategory.description,
            'created': newCategory.created != null
                ? newCategory.created!.toIso8601String()
                : DateTime.now().toIso8601String(),
            'updated': newCategory.updated != null
                ? newCategory.updated!.toIso8601String()
                : DateTime.now().toIso8601String(),
          },
        ),
      );
      final res = jsonDecode(response.body);
      final newCategoryItem = CategoryItem(
        id: res['name'],
        userId: newCategory.userId,
        name: newCategory.name,
        description: newCategory.description,
        created:
            newCategory.created != null ? newCategory.created! : DateTime.now(),
        updated:
            newCategory.updated != null ? newCategory.updated! : DateTime.now(),
      );
      _items.add(newCategoryItem);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateCategoryItem(CategoryItem newCategoryItem) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final prodIndex =
        _items.indexWhere((prod) => prod.id == newCategoryItem.id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        apiDB,
        '/categories/${newCategoryItem.id}.json',
        {'auth': authToken},
      );
      try {
        await http.patch(
          url,
          body: jsonEncode(
            {
              'name': newCategoryItem.name,
              'description': newCategoryItem.description,
              'updated': DateTime.now().toIso8601String(),
            },
          ),
        );
        _items[prodIndex] = newCategoryItem;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteCategoryItem(String id) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/categories/$id.json',
      {'auth': authToken},
    );
    final existingCategoryItemIndex =
        _items.indexWhere((prod) => prod.id == id);
    var existingCategoryItem = _items[existingCategoryItemIndex];
    _items.removeAt(existingCategoryItemIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(
        existingCategoryItemIndex,
        existingCategoryItem,
      );
      notifyListeners();
      throw HttpException('Could not delete CategoryItem.');
    }
    //existingCategoryItem = null;
  }

  CategoryItem findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void initData() async {
    var uncategorized = CategoryItem(
      id: null,
      userId: userId,
      name: 'Uncategorized',
      description: 'for data without categories',
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    var foodAndDrink = CategoryItem(
      id: null,
      userId: userId,
      name: 'Food & Drink',
      description: 'for data food and drink',
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    await addCategoryItem(uncategorized);
    await addCategoryItem(foodAndDrink);
  }
}
