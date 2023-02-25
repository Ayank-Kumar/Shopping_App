import 'package:flutter/material.dart';
import 'Product_BluePrint.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// with kya hai extend/ inherit krta hai - pr parent ka identifier leke iska object nhi bana skte.

class Products_Provider with ChangeNotifier {
  String? _token;

  String? userId;

  Products_Provider(this._token, this.userId, this._loadedProducts);

  List<Product> _loadedProducts = [
    /*
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
      'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
    */
  ];

  //getter method ko dikhane ke liye get
  List<Product> get items {
    return [..._loadedProducts];
  }

  List<Product> get FavItems {
    return _loadedProducts.where((element) => element.isFavourite).toList();
  }
//jaha pai parameter - (optional) kuchh na aane pai default value le skta hai . to usmai [] krke.
  Future<void> fetchInitial([bool filterByUser = false]) async {
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

  // [] - ye kya hai - ye ek new list mai copy krke given list ke item - us nye list ko return kr dega.
  // ... to bata hi hoga -- individually torne ke liye.
  //ye isliye kyunki _loaded khud hi pass kr denge - to ye referance hai -> iska use krke bahar se manipulate kr denge

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
