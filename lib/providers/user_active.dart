import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class UserActive with ChangeNotifier {
  User? _activeUser;
  final String? authToken;
  final String? userId;

  UserActive(this._activeUser, {this.authToken, this.userId});

  User? get userActive {
    return _activeUser;
  }

  Future<void> fetchAndSetUser() async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    if (authToken != null) {
      var url = Uri.https(
        apiDB,
        '/users/$userId.json',
        {
          'auth': authToken,
          'orderBy': '"userId"',
          'equalTo': '"$userId"',
        },
      );
      final response = await http.get(url);
      if (response.body.isNotEmpty) {
        final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
        if (extractedData.isEmpty) {
          return null;
        }
        final List<User> loadedUsers = [];
        extractedData.forEach((userID, userData) {
          loadedUsers.add(
            User(
              id: userID,
              userId: userData['userId'],
              firstName: userData['firstName'],
              lastName: userData['lastName'],
              limit: userData['limit'],
              avatar: userData['avatar'],
              created: DateTime.parse(userData['created'].toString()),
              updated: DateTime.parse(userData['updated'].toString()),
            ),
          );
        });
        _activeUser = loadedUsers[0];
        notifyListeners();
      }
    }
  }

  Future<void> addUserData(User userData) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    final url = Uri.https(
      apiDB,
      '/users.json',
      {'auth': authToken},
    );
    try {
      final response = await http.post(
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
      final res = jsonDecode(response.body);
      final newUserData = User(
        id: res['name'],
        userId: userData.userId,
        firstName: userData.firstName,
        lastName: userData.lastName,
        limit: userData.limit,
        avatar: userData.avatar,
        created: userData.created != null ? userData.created! : DateTime.now(),
        updated: userData.updated != null ? userData.updated! : DateTime.now(),
      );
      _activeUser = newUserData;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateUserData(User userData) async {
    await dotenv.load(fileName: ".env");
    final apiDB = dotenv.env['FIREBASE_DB'].toString();
    if (_activeUser!.id == userData.id) {
      final url = Uri.https(
        apiDB,
        '/users/${userData.id}.json',
        {'auth': authToken},
      );
      try {
        await http.patch(
          url,
          body: jsonEncode(
            {
              'firstName': userData.firstName,
              'lastName': userData.lastName,
              'limit': userData.limit,
              'avatar': userData.avatar,
              'updated': DateTime.now().toIso8601String(),
            },
          ),
        );
        _activeUser = userData;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }
}
