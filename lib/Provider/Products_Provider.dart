///authentication ka alag storage hota hai , realtime database ka alag

///db at url [jis end point pai restAPI jayegi] stores
///orders --> users ke aur unke order_Items
///Products --> multi prod - hr prod ke saath uske creator ki userID
///userFav(ismai multi-users aur unke andar hr product ke aage fav ya nahi - hr prduct ke aage kyunki koi bhi user kisi bhi prod ko anytime fav kr skta hai )

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Product_BluePrint.dart';

// with kya hai extend/ inherit krta hai - pr parent ka identifier leke iska object nhi bana skte.

class Products_Provider with ChangeNotifier {
  String? _token;

  String? userId;

  Products_Provider(this._token, this.userId, this._loadedProducts);

  /// hmne neeche sb isi mai change kiye hai kyunki screens/widgets isi list ke blueprint se banayegi
  /// to ye change krke notify listener
  List<Product> _loadedProducts = [];

  //getter method ko dikhane ke liye get
  List<Product> get items {
    return [..._loadedProducts];
  }

  List<Product> get FavItems {
    return _loadedProducts.where((element) => element.isFavourite).toList();
  }

  ///fetch all [Ye to app wale list mai database se lake notify listener call kr dega] OR
  ///by user - [Ye product mai hi reach krke token[hr user ka chalega] se authenticate krke
  ///filter logic ka regex laga diya(list of Product to retrieve pai)

  ///products ka apna end point, userFav ka apna end point. since do different directory
  ///userFav chahiye tha - ki jb product ke bPrint ki list banaye to usmai fav wali field
  ///(all data would be required by Widget to build).
  ///Aur fav user se attach naki product se (isliye alag se userFav rakha)
  Future<void> fetchInitial([bool filterByUser = false]) async {
    //jaha pai parameter - (optional) kuchh na aane pai default value le skta hai . to usmai [] krke.
    final filterString = filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '' ;
    //filtering krne ke liye rule bhi hone chahiye waise database ke firebase mai - jaise yaha indexing by userId
    final url = Uri.parse(
        'https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_token$filterString');
    // this filtering can be added before or after the token
    final favUrl = Uri.parse(
        'https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/userFavourites/$userId.json?auth=$_token');
    try {
      final response = await http.get(url);
      final prod = json.decode(response.body);

      //for each userId - it will be a map of - numerous prod id and their fav value (truth or false) .
      if (prod.isEmpty) return;

      final favResponse = await http.get(favUrl);
      final favProd = json.decode(favResponse.body);
      //print(favProd) ;

      List<Product> initialProd = [];
      prod.forEach((prodId, value) {
        initialProd.add(
          Product(
              id: prodId,
              title: value['title'],
              description: value['description'],
              price: value['price'],
              imageUrl: value['imageUrl'],
              isFavourite: favProd != null ? favProd[prodId] ?? false : false),
          //favProd tb null hoga jb url se - mtlb user Id ka hi koi entry na ho
          //kbhi kiya bhi ho user nai - tb bhi kya pata us prduct ki entry kabhi ki na ho (true ya false irrelevant) - tb wo null.
        );
      });
      _loadedProducts = initialProd;
      notifyListeners();
    } catch (error) {
      print(error) ;
      throw error;
    }
  }

  ///product data json mai encode krke post.  Fir return mai name dete hai
  ///usko pakar ke apna Product banake list mai add aur notify listener.
  Future<void> addProduct(Product product) async {
    //hme farak nhi parta na - bs ek future return ho jaye apne kaam ke liye. us future ke returning item ka use krte hue kuchh karna thodi hai.
    final url = Uri.parse(
        'https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_token');
    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'userId' : userId,
            }))
        .then((response) {
      //yaar ye then isliye use kr rahe hai taaki - jb database mai dl jaye to database khud ek id generate krega . (aur wo database ki generated id bahut bariya hoti hai)
      //jaise hi usse response aa jaye aap uske apne widget ki bhi id bana do - uski database ki id store ho gyi aapke paas apke source code/frontend ka widget mai.
//aur waise bhi aap yhi chahoge ki dono jagah aligned ho - apne frontend se hi id ka use krke database mai search kr do.
      final new_Product = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _loadedProducts.add(new_Product);
      notifyListeners();
      //sari dependencies jo ise listen kr rhi hogi - us sb ko signal - khali wo rebuild.
    }).catchError((error) {
      //aapko widget mai handle krna ho to throw krdo aur widget mai handle kr lo.
      throw error;
      //ya fir yhi handle kr lijiye.
    });
  }

  ///db mai delete http.dlt(products mai us product ki id)
  ///aur app mai list.where(id matches) - usko remove fir notify listener.

  ///Yaha pai kya app se dlt , fir try to dlt from db - if error to wapis add jo app wala dlt
  ///i think aise ki phle try db se dlt , ho gaya to app se bhi dlt
  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_token');

    var index = _loadedProducts.indexWhere((element) => element.id == id);
    Product? prod_Obj = _loadedProducts[index];

    try {
      _loadedProducts.remove(prod_Obj);
      notifyListeners();
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw Error();
      }
    } catch (_) {
      _loadedProducts.add(prod_Obj);
      notifyListeners();
      throw Error();
    }
    prod_Obj = null;
  }

  ///simple http.patch us product [ye json encoded] ki id mai jake update.
  Future<void> updateProduct(String id, Product updated) async {
    //ye khali abject uthaoge ,to wo copy usse change nahi la paoge.
    final url = Uri.parse(
        'https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_token');
    await http.patch(url,
        body: json.encode({
          'title': updated.title,
          'description': updated.description,
          'price': updated.price,
          'imageUrl': updated.imageUrl,
        }),);

    var index = _loadedProducts.indexWhere((element) => element.id == id);
    // Ye indexWhere bhi achha function
    _loadedProducts[index] = updated;
    notifyListeners();
  }

  Product findById(String id) {
    return items.firstWhere((element) => element.id == id);
  }
}
