///jb orderNow pai dabao - to setState mai ordering true krke re-render
/// jb tk loading - order Provider ka method use for adding Order_Item.
/// Jb ho jaye to list empty aur notify listeners.
/// Cart Provider chahiye taki data/list mil jaye. Saath mai Cart Object widget se render kr lenge.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Cart_Provider.dart';
import '../Provider/Order_Provider.dart';
import '../models/Cart_Object.dart';

class Cart_Screen extends StatefulWidget {
  static const routeName = '/cartOne';

  @override
  State<Cart_Screen> createState() => _Cart_ScreenState();
}

class _Cart_ScreenState extends State<Cart_Screen> {
  bool ordering = false ;

  @override
  Widget build(BuildContext context) {
    final cart_usage = Provider.of<Cart_Provider>(context);
    //jb bhi provider change honge inmai se - to ye rebuild honge, kyunki listen to by default krta hai
    final order_list = Provider.of<Order_Provider>(context) ;
    //print('rebuilt'+' ${cart_usage.itemsCount}'+' ${cart_usage.items.length}') ;
    return Scaffold(
        appBar: AppBar(
          title: Text('Cart'),
        ),
        body: Column(
          children: [
            Card(
              margin: EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Chip(
                      label: Text('\$${cart_usage.total_Cost.ceil()}'),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    ordering ? CircularProgressIndicator(color: Colors.deepOrange) : TextButton(
                      child: Text(
                        'ORDER NOW',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      onPressed: () async {
                        try{
                          setState(() {
                            ordering = true ;
                          });
                          await order_list.addOrder(  Order_Item(id: DateTime.now().toString(), itemsList: cart_usage.items.values.toList(), tot_amount: cart_usage.total_Cost) ) ;
                          //error aate hi catch pai chala jayega.
                          cart_usage.clearItems() ;
                        }catch(error){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('The Order could not be placed',textAlign: TextAlign.center,),
                            ),
                          ) ;
                        }
                        setState(() {
                          ordering = false ;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              //ListView.builder ko khud apne size ka kuchh pata nhi hota. usko kisi se constrain krna parta hai
              child: ListView.builder(
                itemCount: cart_usage.items.length,
                //List mai convert krne ke baad hi ye index use kr paa rahe . aise kh raha ki null pai nahi kr skte.
                itemBuilder: (ctx, i) => Cart_Object(
                    cart_bluePrint:
                        cart_usage.items.values.toList()[i] as Cart_BluePrint),
              ),
            ),
          ],
        ),);
  }
}
