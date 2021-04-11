import 'package:flutter/material.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/order_item.dart' as ord;
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/order';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _orderFuture ;

  Future _obtainFutureOrders (){
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }
  @override
  void initState() {
    // TODO: implement initState
    _orderFuture = _obtainFutureOrders();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body: FutureBuilder(
          future:_orderFuture ,
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (dataSnapShot.error != null) {
              // error handling
              return Center(child: Text('An error occurred!'),);
            } else {
              return Consumer<Orders>(builder: (ctx, orderData, child) =>
                  ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (context, index) {
                        return ord.OrderItem(
                          orderData: orderData.orders[index],
                        );
                      }));
            }
          },
        ));
  }
}
