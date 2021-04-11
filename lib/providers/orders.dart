import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double amount;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.products,
    @required this.amount,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String authToken;
  final String userID;

  Orders(this._orders, this.authToken , this.userID);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-updates-62792-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken';
    final response = await http.get(url);
    final extractData = json.decode(response.body) as Map<String, dynamic>;
    if(extractData ==null){
      return;
    }
    final List<OrderItem> loadedOrders = [];
    extractData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['totalAmount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((prod) => CartItem(
                    id: prod['id'],
                    title: prod['title'],
                    quantity: prod['quantity'],
                    price: prod['price'],
                  ))
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> products, double totalAmount) async {
    // it will add an item at the end of list
    //  _orders.add
    // we want to order it
    // it will add an pro in the beginning
    final url =
        'https://flutter-updates-62792-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken';
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'totalAmount': totalAmount,
          'dateTime': timeStamp.toIso8601String(),
          'products': products
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: totalAmount,
            dateTime: timeStamp,
            products: products));
    notifyListeners();
  }
}
