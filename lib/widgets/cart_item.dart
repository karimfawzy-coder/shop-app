import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  CartItem({this.id, this.title, this.price, this.quantity, this.productId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
       return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are You sure?'),
                  content:
                      Text('Do you want to remove the item from the cart ?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('NO'),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text('YES'),
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                    ),
                  ],
                ));
      },
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      child: Card(
        color: Theme.of(context).backgroundColor,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total \$${price * quantity} x'),
            trailing: Text('$quantity'),
          ),
        ),
      ),
    );
  }
}
