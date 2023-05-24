/// Sare different process for Cart Items , sb changes la rahe Map mai to notify listeners.
/// App wise changes bas[updation]. Aur unke basis pai jo jo screen isko listen wo rebuilt - Cart_Screen hi
/// Order database mai changes order provider kar raha , isko use krege Cart Screen mai

///Yaha pai Map Liya instead of List, kyunki search krna tha constant data changes ke liye.
/// id as key [to search in Map] and also keep id in CartItemBluePrint - i believe this value id is redundant.

import 'package:flutter/foundation.dart';
/// provider mai ye foundation wala import
/// listener mai wo provider wala import.

/// Almost all field aise hi _krke private kar do, fir getter se access

class Cart_BluePrint {
  final String id;

  final String title;

  final int quantity;

  final double price;

  Cart_BluePrint(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class Cart_Provider with ChangeNotifier {
  //field private using _
  Map<String, Cart_BluePrint> _items = {};

  //getter using same name methdod.
  Map<String, Cart_BluePrint> get items {
    return {..._items};
  }

  double get total_Cost {
    double _total_Cost = 0.0;
    _items.forEach((key, value) {
      _total_Cost += value.price * value.quantity;
    });
    return _total_Cost;
  }

  //getter mai last mai semicolon nhi aa raha.

  int get itemsCount {
    return _items.length;
  }

  ///Add[from catalogue screen]/update[+ button] se
  void addItems(String id, String title, double price) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (original) => Cart_BluePrint(
              id: original.id,
              title: original.title,
              quantity: original.quantity + 1,
              price: original.price));
    }else {
      _items.putIfAbsent(id, () => Cart_BluePrint(id: id, title: title, quantity: 1, price: price));
    }
    notifyListeners();
  }

  ///Cart Item ko dlt hi kr rahe hai. jaise dismissible se.
  void removeItem(String id){
    _items.remove(id) ;
    notifyListeners() ;
  }

  ///Jb Order kar denge to fir clean
  void clearItems(){
    _items.clear() ;
    notifyListeners() ;
  }

  ///agar 0 ho jaye to remove bhi
  void ReduceQuantity(String id){

      _items.update(
        id,(orig) => Cart_BluePrint(
                id: id,
                title: orig.title,
                quantity: orig.quantity - 1,
                price: orig.price
            ),
      );
      _items.removeWhere((key, value) => value.quantity<=0) ;

      notifyListeners();
    }

  }
