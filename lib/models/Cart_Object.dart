import 'package:flutter/material.dart';
import '../Provider/Cart_Provider.dart';
import 'package:provider/provider.dart';

class Cart_Object extends StatelessWidget {
  Cart_BluePrint cart_bluePrint;

  Cart_Object({required this.cart_bluePrint});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart_Provider>(context);
    return Dismissible(
      key: ValueKey(cart_bluePrint.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cartProvider.removeItem(cart_bluePrint.id);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('This item will get deleted from your cart!'),
            actions: [
              Card(
                color: Colors.blue.withOpacity(0.85),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
        );
      },
      background: Container(
        padding: const EdgeInsets.only(right: 20.0),
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 25.0,
        ),
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.all(8.0),
      ),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  '\$${cart_bluePrint.price}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ),
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.75),
          ),
          title: Text(
            '${cart_bluePrint.title}',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          subtitle:
              Text('\$${(cart_bluePrint.price * cart_bluePrint.quantity)}'),
          trailing: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                    width: 2.0, color: Theme.of(context).colorScheme.primary)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => cartProvider.deleteItems(cart_bluePrint.id),
                  splashColor: Colors.black,
                  splashRadius: 18.0,
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.red,
                    size: 25.0,
                  ),
                ),
                Text(
                  '${cart_bluePrint.quantity}x',
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.93),
                      fontWeight: FontWeight.w900),
                ),
                IconButton(
                  onPressed: () => cartProvider.addItems(cart_bluePrint.id,
                      cart_bluePrint.title, cart_bluePrint.price),
                  splashColor: Colors.black,
                  splashRadius: 22.0,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 25.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
