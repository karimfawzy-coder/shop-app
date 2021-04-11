import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:provider/provider.dart';
class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? Center(child: CircularProgressIndicator(),) : Text(
        'ORDER NOW',
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      textColor: Theme.of(context).primaryColor,
      splashColor: Theme.of(context).accentColor,
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : () async {
        setState(() {
          _isLoading = true;
        });
       await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.items.values.toList(),
          widget.cart.totalAmount,
        );
       setState(() {
         _isLoading = false;
       });
        widget.cart.clear();
      },
    );
  }
}
