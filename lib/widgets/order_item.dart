import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderData;

  OrderItem({this.orderData});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    print(widget.orderData.products.toString());

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(widget.orderData.amount.toString()),
            subtitle: Text(DateFormat('dd/MM/yyyy hh:mm')
                .format(widget.orderData.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
              margin: EdgeInsets.all(10),
              height: min(widget.orderData.products.length * 20.0 + 20.0, 180),
              child: ListView(
                children:  widget.orderData.products
                    .map((prod) => Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(prod.title , style:
                              TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),),
                            Text('${prod.quantity}x \$${prod.price} ' , style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700
                            ),),
                          ],
                        ))
                    .toList()
              )
            )
        ],
      ),
    );
  }
}
