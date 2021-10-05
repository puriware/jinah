import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:puri_expenses/models/user.dart';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  String? _userEmail;
  String? _password;
  Timer? _authTimer;

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
        this._userEmail = email;
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

      final userData = jsonEncode(
        {
          'token': _token,
          'userId': _userId,
          'email': _userEmail,
          'password': _password,
          'expiryDate': _expiryDate!.toIso8601String()
        },
      );
      if (prefs.containsKey('userData')) {
        await prefs.remove('userData');
      }
      await prefs.setString(
        'userData',
        userData,
      );

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String limit,
  ) async {
    var userData = User(
      userId: _userId,
      firstName: firstName,
      lastName: lastName,
      limit: double.tryParse(limit),
    );
    await _authenticate(email, password, 'signUp');
    if (_userId != null) await addUserData(userData);
  }

  Future<void> addUserData(User userData) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/users.json',
      {'auth': _token},
    );
    try {
      await http.post(
        url,
        body: jsonEncode(
          {
            'userId': userId,
            'firstName': userData.firstName,
            'lastName': userData.lastName,
            'limit': userData.limit,
            'avatar': userData.avatar,
            'created': userData.created != null
                ? userData.created!.toIso8601String()
                : DateTime.now().toIso8601String(),
            'updated': userData.updated != null
                ? userData.updated!.toIso8601String()
                : DateTime.now().toIso8601String(),
          },
        ),
      );
    } catch (error) {
      throw error;
    }
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return;
    }

    final extractedUserData =
        jsonDecode(prefs.getString('userData').toString());
    //as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());
    final email = extractedUserData['email'].toString();
    final password = extractedUserData['password'].toString();
    if (expiryDate.isBefore(DateTime.now())) {
      await signIn(email, password);
    } else {
      _token = extractedUserData['token'].toString();
      _userId = extractedUserData['userId'].toString();
      _userEmail = extractedUserData['email'].toString();
      _expiryDate = expiryDate;
      notifyListeners();
    }
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
}
