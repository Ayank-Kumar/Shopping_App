import 'package:flutter/material.dart';
import 'package:shopping_mania/Provider/Products_Provider.dart';
import '../Provider/Product_BluePrint.dart';
import 'package:provider/provider.dart';
import '../Provider/Cart_Provider.dart';
import '../Screens/product_Detail_Screen.dart';
import '../Provider/Auth_Provider.dart';

class Product_Object extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Product product = Provider.of<Product>(context, listen: false);
    //ye .of hi generic type hota hai
    Cart_Provider cart_Usage =
        Provider.of<Cart_Provider>(context, listen: false);
    Auth_Provider auth_provider =
        Provider.of<Auth_Provider>(context, listen: false);
    //optimisation ye ki yaha pai ek baar data le aaye . And aapka pura widget rebuild nhi ho raha
    //To jo subPart hai - uspai laga do.
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(Product_Detail_Screen.routeName, arguments: product.id),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: GridTile(
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.contain,
              ),
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black45,
              leading: Consumer<Product>(
                builder: (ctx, prod, child) => IconButton(
                  icon: prod.isFavourite
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border_outlined),
                  onPressed: () async {
                    //usi method mai listener hai.
                    try {
                      prod.ToggleFav(auth_provider.token, auth_provider.userId);
                      //await Provider.of<Products_Provider>(context,listen:false).updateProduct(prod.id, prod) ;
                    } catch (error) {
                      throw error;
                    }
                  },
                  color: Theme.of(context).colorScheme.secondary,
                ),
                //child: Ye  ki aapko apne consumer widget ke andar ko cheez change nhi krwani to uska yaha declare kr do
                // aur isko referance leke jaha widget ke andar hoga usko rebuild nhi krega,
              ),
              title: FittedBox(
                child: Text(
                  product.title,
                  textAlign: TextAlign.center,
                ),
              ),
              trailing: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    cart_Usage.addItems(
                        product.id, product.title, product.price);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black87,
                        content: Text('The item has been added to your cart!'),
                        duration: Duration(seconds: 2),
                        //ek hi action  unlike other areas like appBar
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            cart_Usage.deleteItems(product.id);
                          },
                        ),
                      ),
                    );
                  },
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ),
      ),
    );
  }
}
