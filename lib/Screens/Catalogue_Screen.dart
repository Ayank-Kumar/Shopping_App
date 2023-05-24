///init state - initiall load=true ke liye built , fir jaise hi aa jaye , to again setState load=false

///enum of fav - value to two option of popmenubutton.
///jo select uske according favourite ko value deke setState.

///aakhir mai cart ka symbol - click krne pai navigate aur ye CartProvider ko sunega akela - via consumer.
///ki uske according apne pai dot rakhna ya nahi. Although hr baar ho raha wo redundant.

///Ya to loading, Ya fir GridBuilder usin Product Widget, info from Prod Provider
///List dene ke liye ChangeNotifierProvider.value - ye was helpful in recycling widget in fav-all transition

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Badge_Widget.dart';
import '../Provider/Cart_Provider.dart';
import '../Provider/Products_Provider.dart';
import '../models/Drawer.dart';
import '../models/Product_Object.dart';
import 'Cart_Screen.dart';

enum Fav { yes, no }

class Catalogue_Screen extends StatefulWidget {
  static const routeName = '/each';

  @override
  State<Catalogue_Screen> createState() => _Catalogue_ScreenState();
}

class _Catalogue_ScreenState extends State<Catalogue_Screen> {
  bool Favorites = false;
  bool load = false;

  @override
  void initState() {
    //ye andar build mai daal diya tha to baar baar run krke fetch wali whi initial screen render kr de raha tha.
    setState(() {
      load = true;
    });
    Provider.of<Products_Provider>(context, listen: false)
        .fetchInitial()
        .then((value) {
      setState(() {
        load = false;
      });
    });

    super.initState();
  }

  //jb jb build call.
  @override
  Widget build(BuildContext context) {
    final cart_Usage = Provider.of<Cart_Provider>(context);
    final products_Object = Provider.of<Products_Provider>(context);

    //ye .items wo getter hai
    var loadedProducts =
        Favorites ? products_Object.FavItems : products_Object.items;
    //hmne dono jagah final use kiya hai - type nhi diya . since type inference hota hai.

    //aapka hota kya hai isse aap provider class ki cheeze access kr pate ho.
    return Scaffold(
      //backgroundColor: Colors.blueGrey.withOpacity(0.25),
      appBar: AppBar(
        title: const Text('Hope'),
        actions: <Widget>[
          PopupMenuButton(
              icon: const Icon(Icons.more_vert_outlined),
              onSelected: (Fav s) {
                setState(() {
                  if (s == Fav.yes) {
                    Favorites = true;
                  } else {
                    Favorites = false;
                  }
                });
              },
              itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      child: Text("All Item\'s"),
                      value: Fav.no,
                    ),
                    const PopupMenuItem(
                      child: Text("Favourites"),
                      value: Fav.yes,
                    ),
                  ]),
          Consumer<Cart_Provider>(
            builder: (ctx, cart, ch) => Badge_Widget(//name clash ho raha tha badge widget ke karan
              value: cart_Usage.itemsCount,
              child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.deepOrangeAccent,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(Cart_Screen.routeName);
                },
              ),
            ),
          ),
        ],
      ),
      //isko alag le gaye . kyunki ye rebuild krenge listen krke - ispai effect aata hai allProduct ke list ka.
      drawer: Main_Drawer(),
      body: load
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: loadedProducts.length,
              //in a list widget is recycled by flutter during rebuild by changeNotifierProvider
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                //List mai yhi sahi rhta hai - usmai kya hai - widget baar baar rebuild hota hai. aapne koi filter lagaya - usmai kuchh ,kuchh nhi
                // to jo nhi wo dispose baki rebuild. ab dobara bina filter ke kro to jo dispose wo aa hi nhi skte

                //value mai kya ki widget se koi lena dena nhi,bs data se - widget rhta hai . baad mai kabhi need to wapis aake mil jayega
                value: loadedProducts[i],
                //jb koi use hi na ho raha ho context ka - to aise _ mai leke chhor do.
                child: Product_Object(),
              ),
            ),
    );
  }
}
