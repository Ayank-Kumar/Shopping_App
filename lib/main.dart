///Multi Provider - changenotifierProvider aur changeNotifierProxyProvider -
///ye multiple providers ko combine krne ke liye.
///Ye Routes ki tarah hi apne widget ko call krte hai import krke.
///Args pass krte hai , jaise auth-provider ko token chahiye ho

///Home screen ka UI based on Auth_Provider,
///wo loading wala screen [jb token ho] futureBuider se, jb !auth aur login ki try krega.
///jb auth to andar ki screen Baki routes rakhe hue hai isnai

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_mania/Screens/Catalogue_Screen.dart';
import 'package:shopping_mania/Screens/Order_Screen.dart';
import 'package:shopping_mania/Screens/Splash_Screen.dart';

import './Provider/Cart_Provider.dart';
import './Provider/Order_Provider.dart';
import './Screens/Authorization_Screen.dart';
import './Screens/Edit_Products_Screen.dart';
import './Screens/product_Detail_Screen.dart';
import 'Provider/Auth_Provider.dart';
import 'Provider/Products_Provider.dart';
import 'Screens/Cart_Screen.dart';
import 'Screens/User_BackStore_Screen.dart';

void main() {
  runApp(const MyApp());
}

//hmne container banaya hai root widget ko . par lca to - all_Products wala bhi ho skta hai.
//and waise bhi homepage ko koi farak nhi prna chahiye products ke changes se
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //across screens effect aa raha ho , to sequentially pass karne ki jagah provider
        providers: [
          //jb bhi build kr rahe widget(screen bhi ek, provider bhi ek) - in sb mai current context dena hi hota hai
          ChangeNotifierProvider(create: (_) => Auth_Provider()),//kabhi use na ho to aise _ krke chhor do
          //topological sort mai ek incoming edge(Auth_Provider) and khud se ek outgoing (provider) .
          //wo provider jo khud kisi provider ke change ko listen kr rahe ho.
          ChangeNotifierProxyProvider<Auth_Provider, Products_Provider>(
            create: (ctx) => Products_Provider('', '', []),
            //ye aisi hi bs initialise krne ke liye. ise update hona hi hai
            //your previous state, your old state object , useful for maintaining our state
            update: (ctx, auth, prevProductsObject) => Products_Provider(
                auth.token,
                auth.userId,
                prevProductsObject != null ? prevProductsObject.items : []),
          ),
          ChangeNotifierProvider(create: (_) => Cart_Provider()),
          ChangeNotifierProxyProvider<Auth_Provider, Order_Provider>(
              create: (ctx) => Order_Provider('', '', []),
              update: (ctx, auth, prevOrdersObject) => Order_Provider(
                  auth.token,
                  auth.userId,
                  prevOrdersObject != null ? prevOrdersObject.orderList : []))
        ],
        //auth mai change (kahi se bhi) , to ye wala widget rebuild.
        child: Consumer<Auth_Provider>(
          //builder ki kya rebuild krna hai.
          //kbhi bhi build krne ke liye context to chahiye hi.
          //context is available throughout in statefull widget.
          //auth is the provider class object.
          //ye underscore  - koi widget pass on krna ho builder ko for further use.
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
                  .copyWith(
                      secondary: Colors.pinkAccent, tertiary: Colors.amber),
            ),

            //dynamic initial route mai issue aa raha tha.
            home: auth.isAuth
                ? Catalogue_Screen()
                : FutureBuilder(
                    //future : ki ki method / long time waiting code ko perform krna hai
                    //builder kya widhet dikhana hai dependingon the state of request.
                    future: auth.tryLogIn(),
              //isse issue ki - jb aap logout -> to notify listener -> ye rebuild
              // not authenticated -> future builder mai try login
              // data found on device -> again listen -> this time authenticated
              builder: (ctx, authResult) =>
                        authResult.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              AuthScreen.routeName: (ctx) => AuthScreen(),
              Catalogue_Screen.routeName: (ctx) => Catalogue_Screen(),
              Product_Detail_Screen.routeName: (ctx) => Product_Detail_Screen(),
              Cart_Screen.routeName: (ctx) => Cart_Screen(),
              Order_Screen.routeName: (ctx) => Order_Screen(),
              Products_Backstore_Screen.routeName: (ctx) =>
                  Products_Backstore_Screen(),
              Edit_Products_Screen.routeName: (ctx) => Edit_Products_Screen(),
            },
          ),
        ));
  }
}
