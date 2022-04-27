import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
      "https://flutter-db-87c89-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken",
    );
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((ordId, ordData) {
      loadedOrders.add(
        OrderItem(
          id: ordId,
          amount: ordData["amount"],
          dateTime: DateTime.parse(ordData["dateTime"]),
          products: (ordData["products"] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item["id"],
                  title: item["title"],
                  quantity: item["quantity"],
                  price: item["price"],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    //   final url = Uri.parse(
    //     "https://flutter-db-87c89-default-rtdb.firebaseio.com/orders.json",
    //   );
    //   try {
    //     final response = await http.post(
    //       url,
    //       body: json.encode({
    //         "amount": total,
    //         "products": cartProducts,
    //         "dateTime": DateTime.now(),
    //       }),
    //     );
    //     final newOrder = OrderItem(
    //         amount: total,
    //         products: cartProducts,
    //         dateTime: DateTime.now(),
    //         id: json.decode(response.body)["name"]);
    //     _orders.insert(0, newOrder);
    //   } catch (error) {
    //     print(error);
    //     throw error;
    //   }
    //   notifyListeners();

    final url = Uri.parse(
      "https://flutter-db-87c89-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken",
    );
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        "amount": total,
        "dateTime": timestamp.toIso8601String(),
        "products": cartProducts
            .map((cp) => {
                  "id": cp.id,
                  "title": cp.title,
                  "quantity": cp.quantity,
                  "price": cp.price,
                })
            .toList()
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
      ),
    );
    notifyListeners();
  }
}