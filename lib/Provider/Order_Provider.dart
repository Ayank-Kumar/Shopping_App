///achha provider blueprint hi rakhte hai widgets thori rakhenge. blueprint ko widget wale import krake transform karenge.
///always auth [for manipulation] through attaching token in restAPI. USers ko milta hai token.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Cart_Provider.dart';

///Each Order_Item blueprint will consist of list of Cart_Items and orderId.
class Order_Item {
  final String id;
  final List<Cart_BluePrint> itemsList;
  final double tot_amount;

  Order_Item(
      {required this.id, required this.itemsList, required this.tot_amount});
}

class Order_Provider with ChangeNotifier {
  String? _token ;
  String? _userId ;
  List<Order_Item> _orderList = [];
  Order_Provider(this._token,this._userId,this._orderList) ;

  List<Order_Item> get orderList {
    return [..._orderList];
  }

  int get listLength {
    return _orderList.length ;
  }

  ///UserId path ka part [data mai usr wali file] aur token final key for unlocking/authentication. All combined make up the restAPI.
  ///Orders stored in map format. Ye Order Screen pai run with user auth data (for restAPI).
  Future<void> fetchInitial() async {
    final url = Uri.parse('https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_token');

    try {
      final response = await http.get(url);
      final stored_Items = json.decode(response.body) as Map<String, dynamic>;
      List<Order_Item> fetchedItems = [];
      if(stored_Items.isEmpty) return ;

      stored_Items.forEach((key, value) {
        fetchedItems.add(
          Order_Item(
              id: key,
              itemsList: (value['products'] as List<dynamic>)
                  .map(
                    (details) => Cart_BluePrint(
                        id: details['product_id'],
                        title: details['title'],
                        quantity: details['quantity'],
                        price: details['price']
                    ),
                  ).toList(),
              tot_amount: double.parse(value['tot_amount']) ),
        );
      });
      //print('yaha tak 2') ;
      _orderList = fetchedItems;
      notifyListeners();
    } catch (error) {
      //print(error) ;
      throw Error();
    }
  }

  /// Jo abhi ka Order_Item - usko http.post (orders/user.id) wali directory mai
  /// Jb post krte to json data store with a name - whi ID ho gyi order ki.A check ki Cart_Item List khali to nhi.

  /// Yaha pai --> post kr diya , for app provider mai list change krke notify listener. I think redundant
  /// Jb Orders Screen mai jayoge - to wo waise bhi fetch initial se lake list update
  /// [joki aapke database mai changes krne se ho gyi]. To ye app wala waha jake waise bhi update
  Future<void> addOrder(Order_Item order_item) async {
    final url = Uri.parse(
        'https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_token');
    try {
      if (order_item.itemsList.isEmpty) throw Error();
      final response = await http.post(
        url,
        body: json.encode({
          'tot_amount': order_item.tot_amount.toStringAsFixed(2),
          //yaha pai kya krte hai item ko leke usko tor ke
          //sbko individually krne ke baad unko list mai return
          'products': order_item.itemsList
              .map((cp) => {
                    'product_id' : cp.title,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      );
      //agar sb kuchh theek chalta hai tb ispai aata hai
      _orderList.add(Order_Item(
          id: json.decode(response.body)['name'],
          itemsList: order_item.itemsList,
          tot_amount: order_item.tot_amount));
      notifyListeners();
    } catch (error) {
      //print(error);
      //yaha pai dialog box throw nhi , ye widget area nhi hai , ek class hai bas.
      throw error;
    }
  }
}
