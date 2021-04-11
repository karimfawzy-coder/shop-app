import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/order_screen.dart';
import 'package:my_shop/screens/splash_screen.dart';
import 'package:my_shop/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // if we use dot value here lead to unnecessary rerender or bug
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            builder: (ctx, auth, previousProducts) => Products(
                auth.token,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),
          ),
          ChangeNotifierProvider(builder: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              builder: (ctx, auth, previousOrders) => Orders(
                  previousOrders == null ? [] : previousOrders.orders,
                  auth.token,
                  auth.userId)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                primaryColor: Colors.black,
                accentColor: Colors.cyanAccent,
                fontFamily: 'Lato',
              ),
              home: auth.isAuthenticated
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrderScreen.routeName: (ctx) => OrderScreen(),
                UserProductScreen.routeName: (ctx) => UserProductScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen()
              }),
        ));
  }
}
