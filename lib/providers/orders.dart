import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_shop/widgets/order_item.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItemProv> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://my-shop-app-c6e4a.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extracteddata = json.decode(response.body) as Map<String, dynamic>;
    if (extracteddata == null) {
      return;
    }
    extracteddata.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(
            orderData['dateTime'],
          ),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (items) => CartItemProv(
                    title: items['title'],
                    id: items['id'],
                    price: items['price'],
                    quantity: items['quantity']),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItemProv> cartProducts, double total) async {
    final url =
        'https://my-shop-app-c6e4a.firebaseio.com/orders.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode(({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            "products": cartProducts
                .map((cp) => {
                      'id': cp.id,
                      "title": cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          })));
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
