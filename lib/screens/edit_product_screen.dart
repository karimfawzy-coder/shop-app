import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _editedProduct = Product(
    id: null,
    description: "",
    price: 0,
    imageUrl: '',
    title: '',
  );

  // default value in textField
  var _initValues = {
    'title': '',
    'description': '',
    'imageUrl': '',
    'price': '',
  };


  @override
  void dispose() {
    // TODO: implement dispose
    // clear it to avoid memory leak
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (_imageUrlController.text.isEmpty ||
        (!_imageUrlController.text.startsWith('http') &&
            !_imageUrlController.text.startsWith('https')) ||
        (!_imageUrlController.text.endsWith('.png') &&
            !_imageUrlController.text.endsWith('.jpg') &&
            !_imageUrlController.text.endsWith('.jpeg'))) {
      return;
    }

    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
     await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);

    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
       await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An Error occurred'),
                  content: Text('Something went Wrong'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OKAY'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      }
      // finally{ // always run should run no matter failed or succeeded
      //   setState(() {
      //     _isLoading = true;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final product = Provider.of<Products>(context).findById(productId);
        _editedProduct = product;
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          // 'imageUrl': _editedProduct.imageUrl, not allowed because we have a controller on it
          'imageUrl': '',
          'price': _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done_outline,
              color: Colors.white,
            ),
            onPressed: _submitForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return ' Please Enter a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          title: value,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return ' Please Enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please Enter a valid price';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please Enter a price greater than a zero';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          title: _editedProduct.title,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return ' Please Enter a Description';
                        }
                        if (value.length < 10) {
                          return 'Please Enter at least 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          title: _editedProduct.title,
                        );
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black)),
                          child: _imageUrlController.text.isEmpty
                              ? Text(
                                  'Enter Image Url',
                                )
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {
                                _submitForm();
                              });
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return ' Please Enter a Image URL';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please Enter a valid URL';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please Enter a valid URL';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value,
                                title: _editedProduct.title,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
