///Whi drawer widget hai jo Slide hoke left se aata hai. Drawer mai bhi appBar hota hai
///Achhe se Code Reusability nahi kari hai [List Tile ko extract kr dena chahiye]
/// Sari screens import kara li hai and different list tile mai unpai Nav.of(ctx).pushReplaceNamed(Screen.rName) ;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_mania/Screens/User_BackStore_Screen.dart';

import '../Provider/Auth_Provider.dart' ;
import '../Screens/Catalogue_Screen.dart';
import '../Screens/Order_Screen.dart' ;

class Main_Drawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
        children: [
          AppBar(
            title: const Text('Main Drawer'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed(Catalogue_Screen.routeName) ,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart_checkout_outlined),
            title: const Text('Orders'),
            onTap: () => Navigator.of(context).pushReplacementNamed(Order_Screen.routeName) ,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('My Products'),
            onTap: () => Navigator.of(context).pushReplacementNamed(Products_Backstore_Screen.routeName) ,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.of(context).pop() ;
              Navigator.of(context).pushReplacementNamed('/') ; //- '/' is the general home route
              Provider.of<Auth_Provider>(context,listen:false).logOut() ;
            }
          ),
        ],
      ),
    );
  }
}
