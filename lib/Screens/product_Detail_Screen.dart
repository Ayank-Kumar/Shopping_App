import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/Products_Provider.dart';

class Product_Detail_Screen extends StatelessWidget {
  //phle se default constructor de rakha hota hai.
  //final String title ;
  //usko hatake apna to error dega use hata do
  //Product_Detail( { required this.title} ) ;
  static const String routeName = '/details';

  @override
  Widget build(BuildContext context) {
    //Ye sb build method ke andar.
    final product_id = ModalRoute.of(context)?.settings.arguments as String;
    final product_title = Provider.of<Products_Provider>(context, listen: false)
        .findById(product_id);
    //Products use kr raha tha Products_Provider ki jagah.
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(title: Text(product_title.title),centerTitle: true),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Hero(
                    tag: product_id,
                    child: Image.network(
                      product_title.imageUrl,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Starting at \$${product_title.price} ',
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '${product_title.description}',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 500.0),//just to show appBar hiding
            ]),
          ),
        ],
      ),
    );
  }
}
