///Each Product ki information/blueprint. Ek function toggle krne ka database mai
/// Provider banaya kyunki do jagah kaam ek to product object mai , aur dusra fav items ki list dikhane mai
/// Fetching wgerah jo hoti hai wo user ke data se aati hai
/// to user ke data aur uspai lage filters se affect hoti hai

///Thora ulta store hai - userFav --> Diff Users --> Unke products
///Aapko product ke hm ka key toggle krne ke liye product tak pahuchna hoga aur http request mai token to dena hi hoga

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http ;
//jo provider usmai ye import.

class Product with ChangeNotifier{
  final String id ;
  final String title ;
  final String description ;
  final double price ;
  final String imageUrl ;
  bool isFavourite ; // ye to change hota rhega.

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
    }
      );
//for toggle favourite , make a field of it and taki it in as parameter just like any other field
  Future<void> ToggleFav(String? token,String? userId) async {
    this.isFavourite = !this.isFavourite ;
    notifyListeners() ;
    //put mai wo hashmap wala scene - mil gaya to update , nhi to wo url pai banayega and put krega . jaise yaha banayega
    final url = Uri.parse('https://shopping-mania-44366-default-rtdb.europe-west1.firebasedatabase.app/userFavourites/$userId/$id.json?auth=$token') ;
    try {
      final response = await http.put(
        url,
        //jruri nhi hmesha map . but json mai encode krke bhejna hoga
        body: json.encode(
          isFavourite
        ),
      );
    }catch (error) {
      throw error ;
    }
  }

}