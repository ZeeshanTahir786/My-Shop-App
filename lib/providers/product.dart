import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {this.id,
      this.title,
      this.price,
      this.description,
      this.imageUrl,
      this.isFavourite = false});

  void _setFavValue(bool newvalue) {
    isFavourite = newvalue;
    notifyListeners();
  }

  Future<void> toogleFavoriteStatus(String token) async {
    final url =
        'https://my-shop-app-c6e4a.firebaseio.com/products/$id.json?auth=$token';
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      final response = await http.patch(url,
          body: json.encode(({
            'isFavorite': isFavourite,
          })));
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
