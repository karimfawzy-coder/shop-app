import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  Map<String , CartItem> _items = {};

  Map<String , CartItem> get items {
    return{..._items};
  }
  int get itemCounts{
    return _items.length;
  }
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }
  // we will use productId as a key in map in cart item
  void addItem(String productId , String title, double price){
    if(_items.containsKey(productId)){
      // change quantity
      _items.update(productId, (existingCartItem) => CartItem(
        id: existingCartItem.id,
        title: existingCartItem.title,
        price: existingCartItem.price,
        quantity: existingCartItem.quantity +1,
      ));
      
    }else {
      // add an item
      // add a cart item to a map
      _items.putIfAbsent(productId, () => CartItem(
        id: DateTime.now().toString(),
        title: title,
        price: price,
        quantity: 1 , // we added it for a first time
      ));

    }
    notifyListeners();
  }

  void removeItem(String productId){
    _items.remove(productId);
    notifyListeners();
  }
  void removeSingleItem(String productId){
    if (!_items.containsKey(productId)){
      return;
    }
    if(_items[productId].quantity > 1){
      _items.update(productId, (existingCartItem) => CartItem(
        id: existingCartItem.id,
        title: existingCartItem.title,
        price: existingCartItem.price,
        quantity: existingCartItem.quantity - 1
      ));
    }else{
       _items.remove(productId);
    }
    notifyListeners();
  }
  void clear(){
    _items = {};
    notifyListeners();
  }
}
