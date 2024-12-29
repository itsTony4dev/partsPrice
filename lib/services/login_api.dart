import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LoginApi {
  static const baseURL = "http://localhost:3000/user/";
  static Map<String, String> cookies = {};

  static Future<bool> login(Map<String, String> user) async {
    var url = Uri.parse("${baseURL}login");
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user),
      );

      String? rawCookie = res.headers['set-cookie'];
      if (rawCookie != null) {
        int index = rawCookie.indexOf(';');
        String cookie =
            (index == -1) ? rawCookie : rawCookie.substring(0, index);
        cookies[cookie.split('=')[0]] = cookie.split('=')[1];
      }

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        await getSession();
        return data['message'] == 'Login successful';
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<Map<String, dynamic>> getSession() async {
    var url = Uri.parse("${baseURL}session");
    try {
      final res = await http.get(
        url,
        headers: {
          'Cookie': _formatCookies(),
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {'username': 'Guest'};
      }
    } catch (e) {
      debugPrint(e.toString());
      return {'username': 'Guest'};
    }
  }

  static String _formatCookies() {
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  static Future<int> signup(Map user) async {
    var url = Uri.parse("${baseURL}register");

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user),
      );

      debugPrint(res.body);

      return res.statusCode;
    } catch (e) {
      debugPrint(e.toString());
      return 500;
    }
  }

  static Future<bool> logout() async {
    var url = Uri.parse("${baseURL}logout");
    try {
      final res = await http.post(
        url,
        headers: {
          'Cookie': _formatCookies(),
        },
      );
      cookies.clear();
      return res.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
