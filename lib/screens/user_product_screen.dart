import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context , listen: false)
        .fetchDataAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    print('Buildingg....');
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              //go to add screen
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapShot) => snapShot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (ctx,productsData , _) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (_, index) => Column(
                              children: <Widget>[
                                UserProductItem(
                                  title: productsData.items[index].title,
                                  imageUrl: productsData.items[index].imageUrl,
                                  id: productsData.items[index].id,
                                ),
                                Divider(
                                  color: Theme.of(context).primaryColor,
                                  thickness: 2,
                                )
                              ],
                            )),
                  ),
                ),
              ),
      ),
    );
  }
}
