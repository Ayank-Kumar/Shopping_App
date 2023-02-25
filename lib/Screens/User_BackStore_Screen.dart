import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_mania/Screens/Edit_Products_Screen.dart';
import '../Provider/Products_Provider.dart';
import '../models/Product_List_Object.dart';
import '../models/Drawer.dart';

class Products_Backstore_Screen extends StatelessWidget {
  static const routeName = '/editing';

  @override
  Widget build(BuildContext context) {
    print('rebuild..') ;
    //agar build se nikal ke bhi wo same cheej ki ja skti hai to preferable
    //build mai hone se baar baar rebuild hoga

    //listen = false , taki hme provider ke fields,methods ka access mil jaye and hamara rebuild bhi na ho listen krne pai.
    final products = Provider.of<Products_Provider>(context, listen: false);
    //phle refresh indiactor uske andar scafffold. UI change hoga refresh indicator wala
    // hm ya to statefull bana le. ya fir aise hi statless ke andar statefull child.
    // sara rebuild nahi .sirf refresh indicator pai consumer of provider laga do. isliye refresh ko andar le gaya. aur uspai
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Page'),
        actions: <Widget>[
          IconButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, Edit_Products_Screen.routeName),
              icon: Icon(Icons.add))
        ],
      ),
      drawer: Main_Drawer(),
      //future builder ke bar mai http section mai bataya hai
      body: FutureBuilder(
        future: products.fetchInitial(true),
        //ye snapshot wgerah futurebuilder ki property.
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    //khali wo future<void> tha. ab () => krke to now it is - function jo future void return kre.
                    onRefresh: () => products.fetchInitial(true),
                    child: Consumer<Products_Provider>(
                      builder: (ctx,prodData,_) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: products.items.length,
                          itemBuilder: (ctx, i) => Product_List_Object(
                            title: products.items[i].title,
                            imageURl: products.items[i].imageUrl,
                            id: products.items[i].id,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
