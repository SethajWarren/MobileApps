import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String desc;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.desc,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    // final url = Uri.parse(
    //   "https://flutter-db-87c89-default-rtdb.firebaseio.com/products/$id",
    // );
    // final curStat = isFavorite;
    // final newStat = !isFavorite;
    // isFavorite = newStat;
    // notifyListeners();
    // final response = await http.patch(url,
    //     body: json.encode({
    //       "isFavorite": newStat,
    //     }));
    // if (response.statusCode >= 400) {
    //   isFavorite = curStat;
    //   notifyListeners();
    //   throw HttpException("Could not unfavorite product");

    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
      "https://flutter-db-87c89-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token",
    );
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
