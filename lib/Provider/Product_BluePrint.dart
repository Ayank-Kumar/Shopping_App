import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http ;
import 'dart:convert';
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