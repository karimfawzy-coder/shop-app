import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String id;

  UserProductItem({this.imageUrl, this.title , this.id});

  @override
  Widget build(BuildContext context) {
    final scaffold =Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(    // there a problem because it take a space as it possible
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName , arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async{
                try{
               await   Provider.of<Products>(context , listen: false).removeProduct(id);
                }catch(e){
                  scaffold.showSnackBar(SnackBar(content: Text('Deleting Failed' , textAlign: TextAlign.center,) ,));
                }
              },
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}
