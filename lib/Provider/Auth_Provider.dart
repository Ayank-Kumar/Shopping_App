import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth_Provider with ChangeNotifier {
  String? _token;
  DateTime? _dateEnd;
  String? _userId;
  Timer? _expiryTimer;

  bool get isAuth {
    if (token != null) {
      //print(true) ;
      return true;
    }
    // print(false) ;
    return false;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_token != null &&
        _dateEnd != null &&
        _dateEnd!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> base(String email, String password, String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true}),
      );
      final res = json.decode(response.body);
      //print(res) ;
      if (res['error'] != null) {
        //print('thrown') ;
        throw Exception(res['error']['message']);
        //ye error throw hoga and neeche catch kiya jayega.
      }
      _token = res['idToken'];
      _dateEnd = DateTime.now().add(
        Duration(
          seconds: int.parse(res['expiresIn']),
        ),
      );
      _userId = res['localId'];
      //print('notifying') ;
      autoLogOut();
      notifyListeners();
      //instance is basically the tunnel to your in device a storage.
      final pref = await SharedPreferences.getInstance();
      //json data is a string - it is finally enclosed by a string only.
      final _userAuthData = json.encode({
        'token': _token,
        'userId': _userId,
        'dateEnd': _dateEnd!.toIso8601String()
        //ye prescribed format , isse conversion.parsing smooth
      });
      pref.setString('userAuthData', _userAuthData);
      //print('notified') ;
    } catch (error) {
      //print(error) ;
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAo0CTj4kLZZaVzigFPiL0trMEz6GCzKNU';
    return base(email, password, url);
    //hme ye return krwana tha , phle return nhi tha. to jo future error wo return nhi.
    // unused peeche call krne walo tk nhi pahuchega error.
  }

  Future<void> signIn(String email, String password) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAo0CTj4kLZZaVzigFPiL0trMEz6GCzKNU';
    return base(email, password, url);
  }

  Future<void> logOut() async {//on device interaction wala bhi async code.

    //phle tha ye application wala data -> ab on device wala bhi clear krna hai
    // taki token na rh jaye and dobara login na ho jaye
    _userId = null;
    _token = null;
    _dateEnd = null;
    //jb logout to chalta hua timer band.
    if (_expiryTimer != null) {
      _expiryTimer!.cancel();
      _expiryTimer = null;
    }
    //clear krke main rebuild - to signup/signin mai to app wala token hi use ho raha  - wo log out .
    notifyListeners();
    //trylogin wala (system) clear krne ke liye bhi
    final pref = await SharedPreferences.getInstance() ;
    pref.clear() ; //sara on-device clear - yaha pai chlega
  }

  void autoLogOut() {
    //apna timer chalu krne se phle koi aur timer chal raha ho to usko band
    if (_expiryTimer != null) {
      _expiryTimer!.cancel();
    }
    //jo difference hai to dot ke phle wale se dot ke baad wala minus.
    //in seconds mai (kisi mai bhi kr skte ho). yaha pai hme seconds (jo ki int mai aayega) uski need thi
    int expiryFromNow = _dateEnd!.difference(DateTime.now()).inSeconds;
    //jb aapko future mai execute krna ho to aap function ka pointer bhej do.
    _expiryTimer = Timer(Duration(seconds: expiryFromNow), logOut);
  }

  Future<bool> tryLogIn() async {
    final retPref = await SharedPreferences.getInstance();

    if (!retPref.containsKey('userAuthData')) {
      //iska mtlb kabhi login,signup nhi kiya hai
      return false;
    }

    //method dekh hi skte ho - hashmap wale - to hashmap data structure mai store kr rahe hai
    //token to hai , pr check ki wo expire to nhi hogaya.
    final _userData = json.decode(retPref.getString('userAuthData') as String)
        as Map<String, dynamic>;
    //json encode krke json mai (string)
    //json ko decode krne ke liye json chahiye (string) - decode krke jo niklega wo to map hai na hamara.
    final _expiryDate = DateTime.parse(_userData['dateEnd']);

    if (_expiryDate.isBefore(DateTime.now())) return false;
    //mtlb token bhi valid hai expire nhi hua hai

    //apna bhai data bhar lo isse . request dalne se phle
    _token = _userData['token'];
    _userId = _userData['userId'];
    _dateEnd = _expiryDate;

    notifyListeners(); //apka app(main.dart) rebuild (iska consumer uspai)- is baar catalogue screen pai.
    // (jo hmne condition daal rakhi uske according)

    autoLogOut(); //dobara se timer start.

    return true; //ye condition ke liye
  }
}
