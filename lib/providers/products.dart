import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_shop/models/http_exception.dart';

import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken  ,this._items , this.userId);
  List<Product> get items {
    // if(_showFavouritesOnly)
    //   {
    //     return items.where((product) => product.isFavorite).toList();
    //   }
    return [..._items];
  }

  List<Product> get favItem {
    return items.where((product) => product.isFavorite).toList();
  }

  // var _showFavouritesOnly = false;
  //
  // void showFavouriteOnly(){
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }
  // void showAll(){
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }


  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = items
        .indexWhere((pro) => pro.id == id); // it will return index of product
    if (productIndex >= 0) {
      final url =
          'https://flutter-updates-62792-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch( url, body: json.encode({
        'title' : newProduct.title,
        'description' : newProduct.description,
        'price' : newProduct.price,
        'imageUrl' : newProduct.imageUrl,
      }));
      items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> addProduct(Product product) async {
    // Important note
    // in the recent versions we should use this
    // final url  = Uri.https('YOUR DOMAIN' ,  / products.json)
    final url =
        'https://flutter-updates-62792-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl' : product.imageUrl,
            'creatorId' : userId,
          }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchDataAndSetProducts([bool filterByUser = false]) async{
    final filterString = filterByUser? 'orderBy="creatorId"&equalTo="$userId"' : '' ;
    var url =
        'https://flutter-updates-62792-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try{
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String , dynamic>;
      if(extractedData == null){
        return;
      }
       url =
          'https://flutter-updates-62792-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken';

      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      print(json.decode(favouriteResponse.body));
      List<Product> loadedProducts= [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          description: prodData['description'],
          isFavorite: favouriteData ==null ? false : favouriteData[prodId] ?? false,
          // prodId == null it take the value after ??
        ));
      });
      _items = loadedProducts;
      notifyListeners();

    }catch(error){
      throw error;
    }

  }

  Future<void> removeProduct(String productId) async {
    final url =
        'https://flutter-updates-62792-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken';
    final exiProdIndex = items.indexWhere((product) => product.id == productId);
    var exiProduct = items[exiProdIndex];
    items.removeAt(exiProdIndex);
    notifyListeners();
    final response = await http.delete(url);
    if(response.statusCode >=400){
      items.insert(exiProdIndex, exiProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    exiProduct = null;

  }
}
