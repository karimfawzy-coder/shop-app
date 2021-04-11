import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Auth with ChangeNotifier {
  String _token;

  DateTime _expireDate;
  String _userId;
  Timer _authTimer;

  String get userId {
    return _userId;
  }

  bool get isAuthenticated {
    return token != null;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(String email, String password,
      String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyC6jH1aAHoh0SPFnwR2waASravLIGAkKS8";

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now().add(Duration(
        seconds: int.parse(responseData['expiresIn']),
      ));
      _autoLogout();
      notifyListeners();
      // it is an access to shared preferences
      final preference = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expireDate.toIso8601String(),

      });
      preference.setString('userData', userData);
    }

    catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
  Future<bool> tryAutoLogin() async{
    final prefs =await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      print('faild contain key');
      return false;
    }
   final extractedData = json.decode(prefs.getString('userData')) as Map<String,Object> ;
   final expiryDate = DateTime.parse(extractedData['expiryDate']);
   if(expiryDate.isBefore(DateTime.now())){
     print('faild expire date');

     return false;
   }
   _token = extractedData['token'];
   _userId = extractedData['userId'];
   _expireDate = expiryDate;
   notifyListeners();
 print('valid token');
   _autoLogout();
   return true;

  }

  void logOut() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final pref = await SharedPreferences.getInstance();
    pref.remove('userData'); // should do to not remove other data that i need better than clean
    // pref.clear()
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpire = _expireDate
        .difference(DateTime.now())
        .inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
