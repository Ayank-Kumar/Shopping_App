///init state mai provider  se fetch initial kr rahe  -  to listen false wrna inf loop ho jata hai
///Bode mai refresh indicator use kiya hai (jismai upar se slide kr skte hai)
///baki list view builder order provider aur Order_Item widget ka.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Order_Provider.dart';
import '../models/Drawer.dart';
import '../models/Orders_Object.dart';

class Order_Screen extends StatefulWidget {
  static const routeName = '/Orders' ;
  //init State neeche kaam krta hai.
  @override
  State<Order_Screen> createState() => _Order_ScreenState();
}

class _Order_ScreenState extends State<Order_Screen> {
  @override
  void initState() {
    Provider.of<Order_Provider>(context,listen: false).fetchInitial();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final order_list = Provider.of<Order_Provider>(context) ;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Orders',
          textAlign: TextAlign.center,
        ),
      ),
      drawer: Main_Drawer(),
      body: RefreshIndicator(
        onRefresh: order_list.fetchInitial,
        child: ListView.builder(
          shrinkWrap: true,
            itemCount: order_list.listLength,
            itemBuilder: (ctx,idx) => Orders_Object(ordered_Items: order_list.orderList[idx]) ,
          ),
      ),
    );
  }
}
