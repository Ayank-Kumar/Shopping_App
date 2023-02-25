import 'dart:math';
import 'package:shopping_mania/Provider/Auth_Provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0); aise bhi kr skte hai
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.9),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green.shade500,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 15,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 40,
                          overflow: TextOverflow.visible,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

//jo bhi extend,mixin(with) wgerah krna ho - to wo yaha pai hoga statefull mai . ig
class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  //animation controller animations ko control krega , kb forward animation , kb backward animation.
  AnimationController?
      _controller; //sari animations ka ek se ho jaega - smart coded

  Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;

  Animation<Offset>? _slideAnimation;

  //ye actual animation aur kis type ke liye animation - <>
  //sare animation controller ko initialise initState mai hi - phle se pata ho.
  @override
  void initState() {
    // TODO: implement initState
    //vsync - gives a pointer to the widget , that only when this wudget is visible on the screen
    //you should do the animation, it''s for optimisation.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heightAnimation = Tween<Size>(
      begin: const Size(double.infinity, 260),
      //phla width ka dusra height ka , jb animate na krna ho kisi respect mai - to  doub... krke
      end: const Size(double.infinity, 320),
    ).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.0), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn),
    );
    //in dono ka same hona jaruri hai ye nested hai. coordeinated hona chahiye
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn));
    //gives you an object which knows how to animate between the values.imp - khud animate nhi krta

    //_heightAnimation!.addListener(() => setState(() {})) ;
    //ise dipose bhi krna hoga jo hmne manually listener banaya hai.

    super.initState();
    //wo with mixin wala - adds some useful method and lets our widget know when a frame update is due
    // (it happens periodically like ever 60 millisecond like that) .
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth_Provider>(context, listen: false)
            .signIn(_authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        await Provider.of<Auth_Provider>(context, listen: false)
            .signUp(_authData['email']!, _authData['password']!);
      }
    } catch (error) {
      //print('') ;
      //print(error.toString()) ;
      String errorMessage = 'Come back later';
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email could not be found!';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'invalid password entered!';
      } else if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Email already in use!';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid Email entered!';
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Authentication failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Okay'),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller!.duration!.inMilliseconds ;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      //ye builder wale - inmai yhi pattern - executes something and rebuilds a part of the UI when that something gets done
      child: AnimatedContainer(
        //since it itself controls the animation , you don't need a controller (to tell to go backward and forward)
        //ye khud detect kr leta hai container ke height mai change hua hai.automatically transitions
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        //ye child  -  inside the widget , would not get re-rendered every frame.
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                //fade nhi krte to upar bhi visible rhta hai
                AnimatedContainer(
                  //ye bhi align kyunki jb bara wala box 400 se , to ye 300 mai jata tej lgega
                  duration : Duration(milliseconds: 400) ,
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0 ,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0 ,
                ),
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      //upar se neeche aata hai (jo bhi direction - as per positive or negative value).
                      position: _slideAnimation!,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).primaryTextTheme.button!.color,
                    ),
                  ),
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 4),
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  ),
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
