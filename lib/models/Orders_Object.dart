///Ise Order ka Data/BluePrint milega and use Widget mai convert.
///Ek list tile jismai trailing icon aur ek expanded boolean field. Jb setState - to wo in dono ko change krega.
/// Animated Container animation ke saath UI change krta hai [bs itna hi].

import 'package:flutter/material.dart';

import '../Provider/Order_Provider.dart' show Order_Item;

class Orders_Object extends StatefulWidget {
  Order_Item ordered_Items;

  Orders_Object({required this.ordered_Items});

  //isko neeche use by using widget.var - krke


  @override
  State<Orders_Object> createState() => _Orders_ObjectState();
}

class _Orders_ObjectState extends State<Orders_Object>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title:
                Text('\$${widget.ordered_Items.tot_amount.toStringAsFixed(2)}'),
            trailing: !expanded
                ? IconButton(
                    icon: Icon(Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        expanded = expanded;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.expand_less),
                    onPressed: () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                  ),
          ),
          //ye change aisa hai ki hai to hmesha se hi , pr phle 0 height ka tha. ab aoni required height ka ho jayega to bs yhi
          // container ke andr ki koi cheez bar gayi hai
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            height: expanded
                ? widget.ordered_Items.itemsList.length * 20.0 + 10
                : 0,
            //iske bina transition mai pixel overflow ho jaa raha tha.
            child: SingleChildScrollView(
              child: Column(
                children: widget.ordered_Items.itemsList
                    .map(
                      (item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.title}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          Text(
                            '${item.quantity}x - \$${item.price}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
