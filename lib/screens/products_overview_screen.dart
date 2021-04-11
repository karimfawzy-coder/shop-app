import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/badge.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';

enum FilterOptions { favourite, all }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavProducts = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    // Provider.of<Products>(context , listen: false).fetchDataAndSetProducts();

    // Future.delayed(Duration.zero).then((_){
    //   Provider.of<Products>(context , listen: false).fetchDataAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context, listen: false)
          .fetchDataAndSetProducts()
          .then((_) {
            setState(() {
             _isLoading= false;
            });

      });
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<Products>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedOption) {
              setState(() {
                if (selectedOption == FilterOptions.favourite) {
                  //productsContainer.showFavouriteOnly();
                  _showOnlyFavProducts = true;
                } else {
                  // productsContainer.showAll();
                  _showOnlyFavProducts = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favourite'),
                value: FilterOptions.favourite,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.all,
              )
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCounts.toString(),
            ),
            // it will not rebuilt
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : ProductsGrid(showFavProducts: _showOnlyFavProducts),
    );
  }
}
