import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  String? _password;
  Timer? _authTimer;
  var _saveLogin = false;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['FIREBASE_API_KEY'].toString();
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        this._userId = responseData['localId'];
        this._token = responseData['idToken'];
        this._password = password;
        this._expiryDate = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn'],
            ),
          ),
        );
      }

      final prefs = await SharedPreferences.getInstance();

      // if (_saveLogin) {
      //   if (!prefs.containsKey('userLogin')) {
      //     final userLogin = jsonEncode(
      //       {
      //         'email': email,
      //         'password': password,
      //       },
      //     );
      //     await prefs.setString('userLogin', userLogin);
      //   }
      // } else {
      if (!_saveLogin) {
        _autoLogout();
      }

      final userData = jsonEncode(
        {
          'token': _token,
          'userId': _userId,
          'password': _saveLogin ? _password : '',
          'expiryDate': _expiryDate!.toIso8601String()
        },
      );
      await prefs.setString(
        'userData',
        userData,
      );

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password,
      {bool saveLogin = false}) async {
    _saveLogin = saveLogin;
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password,
      {bool saveLogin = false}) async {
    _saveLogin = saveLogin;
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        jsonDecode(prefs.getString('userData').toString());
    //as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());
    final userId = extractedUserData['userId'].toString();
    final password = extractedUserData['password'].toString();
    if (expiryDate.isBefore(DateTime.now())) {
      if (password != '') {
        _saveLogin = true;
        await signIn(userId, password);
      }
      return false;
    }
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(
        seconds: timeToExpiry,
      ),
      logOut,
    );
  }
}
