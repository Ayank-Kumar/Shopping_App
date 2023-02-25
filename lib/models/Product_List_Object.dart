import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_mania/Screens/Edit_Products_Screen.dart';
import '../Provider/Products_Provider.dart';

class Product_List_Object extends StatelessWidget {

  final imageURl;
  final title;
  final id ;

  Product_List_Object({required this.title, required this.imageURl,required this.id});

  @override
  Widget build(BuildContext context) {
    final scaf = ScaffoldMessenger.of(context) ;
    final products = Provider.of<Products_Provider>(context) ;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageURl),
          radius: 25.0,
        ),
        title: Text(title),
        trailing: Container(
          width: MediaQuery.of(context).size.width * 0.33,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Edit_Products_Screen.routeName,arguments: id) ;
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.green,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final prod_id = products.findById(id).id ;
                  try{
                    await products.deleteProduct(prod_id);
                  } catch (error){
                    scaf.showSnackBar(
                      SnackBar(
                        content: Text('Deleting Failed!',textAlign: TextAlign.center,),
                      )
                    ) ;
                  }
                  //ye jb call hoga to as part of that function notifyListeners() call ho jayega.
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
