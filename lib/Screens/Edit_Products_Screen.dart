import 'package:flutter/material.dart';
import 'package:shopping_mania/Screens/User_BackStore_Screen.dart';
import 'package:shopping_mania/models/Drawer.dart';
import '../Provider/Product_BluePrint.dart';
import '../Provider/Products_Provider.dart';
import 'package:provider/provider.dart';

class Edit_Products_Screen extends StatefulWidget {
  static const routeName = '/editor';

  @override
  State<Edit_Products_Screen> createState() => _Edit_Products_ScreenState();
}

class _Edit_Products_ScreenState extends State<Edit_Products_Screen> {
  final _sec_Node = FocusNode();
  final _third_Node = FocusNode();
  final _imgUrlController = TextEditingController();

  // ye form state dalna bhul gaya tha. iske bina method nhi milta
  final _forms = GlobalKey<FormState>();

  Product initial = Product(
      id: '',
      title: '',
      description: '',
      price: 0,
      imageUrl: ''
  );

  @override
  void dispose() {
    _sec_Node.dispose();
    _third_Node.dispose();
    _imgUrlController.dispose();
    super.dispose();
  }

  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageURL': '',
  };

  @override
  void initState() {
    //.of(context) -> mai context chahiye hota hai - aur init state kisi widget se aisa jura hua nhi hota
    //to basically -> init state mai aise .of(ctx)wale kaam nhi krte.
    //to unke liye - Future.delayed(Duration.zero).whenComplete(() => YAHA PAI );
    super.initState();
  }

  bool first = true;
  bool loading = false;

//ye dono function yhi - that what do you want to get done every time / initial once.
  // ye bhi build ke phle chalta hai - init state aur didChangeDependancy - dono hi stateful widget mai aate hai.
  //ye didChange har rebuild pai chalta hai - baki change kaise bhi aa raha ho statefullness ke karan
  @override
  void didChangeDependencies() {
    if (first) {
      final prod_id = ModalRoute
          .of(context)!
          .settings
          .arguments;
      if (prod_id != null) {
        initial = Provider
            .of<Products_Provider>(context, listen: false)
            .items
            .firstWhere((element) => element.id == prod_id);
        _initValues = {
          'title': initial.title,
          'price': initial.price.toString(),
          'description': initial.description,
          'imageURL': '',
        };
        _imgUrlController.text = initial.imageUrl;
      }
    }
    first = false;
    // ye bs isliye hai ki hr baar rebuild na ho , jb jb update sahi mai krna ho tb change ho.
    super.didChangeDependencies();
  }

//stateful mai build ke bahar bhi context mil jata hai provider,modalRoute ke liye.

//jo bhi time le raha ho use asynchronous kr do - taki blocking of code na ho .
// aur async hone ke baad ab wo later moment pai future return krega jiske baad wo to-do list mai jur jayega
  Future<void> saveForm() async {

    //ye sare textfield ke validate wale chalayega
    _forms.currentState!.validate();
    //ye sare textfield ke onSaved: chalayega.
    _forms.currentState!.save();

    setState(() {
      loading = true;
    });

    try{
        if(initial.id.isEmpty){
          //jo jyada time lene wala hai aapka - uske aage await . ab iske neeche wala iske finish hone pai hi execute krenge.
          await Provider.of<Products_Provider>(context, listen: false)
              .addProduct(initial);
          // await bhi tabhi use jb bahar async likha ho.
        }else{
          await Provider.of<Products_Provider>(context, listen: false).updateProduct(initial.id, initial);
        }
    } catch (error) {
      //await nhi kroge to neeche wala execute hota chala jayega.
      await showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
              title: Text(
                'Oops, something went wrong!',
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              content: Text(
                'Please check your content or try again later ',
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .tertiary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context)
                          .pushReplacementNamed(
                          Products_Backstore_Screen.routeName),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .secondary,
                    ),
                  ),
                ),
              ],
            ),
      );
      // ab yaha  pai kya neechewala chal ke screen se hi bahar le ja raha hai. To isse phle
      //ki dialog box apna appear kre hm us screen se out ja chuke hai aur wo kbhi occur hi nhi kiya.
    } finally {
      Navigator.of(context).pushReplacementNamed(Products_Backstore_Screen.routeName);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit products'),
        actions: <Widget>[
          IconButton(
            onPressed: () => saveForm(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      drawer: Main_Drawer(),
      body: loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Scrollbar(
        child: Form(
          key: _forms,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  //ispai cursor hover krke dekh lo kya leta hai as input
                  initialValue: _initValues['title'],
                  decoration: InputDecoration(
                    label: Text(
                      'Title',
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .tertiary),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                  {
                    FocusScope.of(context).requestFocus(_sec_Node),
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please provide a string';
                    }
                    return null;
                  },
                  // ye jo value enter ki hogi
                  onSaved: (value) {
                    initial = Product(
                        id: initial.id,
                        title: value as String,
                        description: initial.description,
                        price: initial.price,
                        imageUrl: initial.imageUrl,
                        isFavourite: initial.isFavourite);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  initialValue: _initValues['price'],
                  decoration: InputDecoration(
                    label: Text(
                      'Price',
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .tertiary),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(),
                  focusNode: _sec_Node,
                  onFieldSubmitted: (_) =>
                  {
                    FocusScope.of(context).requestFocus(_third_Node),
                  },
                  validator: (value) {
                    if (double.tryParse(value as String) == null) {
                      return 'Please provide a number';
                    }
                    if (double.parse(value as String) <= 0) {
                      return 'Please provide a positive price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    initial = Product(
                        id: initial.id,
                        title: initial.title,
                        description: initial.description,
                        price: double.parse(value as String),
                        imageUrl: initial.imageUrl,
                        isFavourite: initial.isFavourite);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  initialValue: _initValues['description'],
                  decoration: InputDecoration(
                    label: Text(
                      'Description',
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .tertiary),
                    ),
                  ),
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  focusNode: _third_Node,
                  onSaved: (value) {
                    initial = Product(
                        id: initial.id,
                        title: initial.title,
                        description: value as String,
                        price: initial.price,
                        imageUrl: initial.imageUrl,
                        isFavourite: initial.isFavourite);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                              color: Colors.greenAccent, width: 2.0),
                        ),
                        child: _imgUrlController.text.isEmpty
                            ? const Text('Enter a URL')
                            : FittedBox(
                          child:
                          Image.network(_imgUrlController.text),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Image URL'),
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        textAlignVertical: TextAlignVertical.bottom,
                        controller: _imgUrlController,
                        onSaved: (value) {
                          initial = Product(
                              id: initial.id,
                              title: initial.title,
                              description: initial.description,
                              price: initial.price,
                              imageUrl: value as String,
                              isFavourite: initial.isFavourite);
                        },
                        validator: (value) {
                          if (!value!.startsWith('http')) {
                            return 'Please provide a valid URL';
                          }
                          if (!value.endsWith('.jpg') &&
                              !value.endsWith('.png') &&
                              !value.endsWith('.jpeg')) {
                            return 'Please provide a valid URL';
                          }
                          return null;
                        },
                        onEditingComplete: () {
                          setState(() {});
                          saveForm();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
