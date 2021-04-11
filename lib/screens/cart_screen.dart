import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/widgets/cart_item.dart' as widget;
import 'package:my_shop/widgets/order_button.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            color: Theme.of(context).backgroundColor,
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(
                          fontSize: 20, fontFamily: 'Anton', letterSpacing: 1),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)} ',
                        style: TextStyle(
                            letterSpacing: 1,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w800),
                      ),
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                    OrderButton(cart: cart)
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  return widget.CartItem(
                    id: cart.items.values.toList()[index].id,
                    title: cart.items.values.toList()[index].title,
                    quantity: cart.items.values.toList()[index].quantity,
                    price: cart.items.values.toList()[index].price,
                    productId: cart.items.keys.toList()[index],
                  );
                }),
          )
        ],
      ),
    );
  }
}

