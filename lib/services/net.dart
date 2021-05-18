import 'dart:async';
import 'dart:convert';

import 'package:health_app_repo/util/util.dart';
import 'package:http/http.dart' as http;

class NetUtil {
  static var client = http.Client();
  static const Map<String, String> xHeaders = {
    'Content-type': 'application/json',
    'Accept': '*/*',
  };

  static const timeOutInSeconds = 30, bb = 'NetUtil 🔵  🔵  🔵  🔵  🔵 ';

  static Future post({required String apiRoute, required Map bag}) async {
    var url = await getBaseUrl();
    String token = 'availableNot';
    // try {
    //   token = await Auth.getAuthToken();
    // } catch (e) {
    //   p('Firebase auth token not available ');
    // }
    var mHeaders = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    var dur = Duration(seconds: timeOutInSeconds);
    apiRoute = url + apiRoute;
    print('$bb: POST:  ................................... 🔵 '
        '🔆 calling backend: 💙 $apiRoute 💙');
    var mBag;
    if (bag != null) {
      mBag = jsonEncode(bag);
    }
    if (mBag == null) {
      p('$bb 👿 Bad moon rising? 👿 bag is null, may not be a problem ');
    }
    p(mBag);
    var start = DateTime.now();
    try {
      var uriResponse =
          await client.post(Uri.parse(apiRoute), body: mBag, headers: mHeaders);
      var end = DateTime.now();
      p('$bb RESPONSE: 💙 status: ${uriResponse.statusCode} 💙 body: ${uriResponse.body}');

      if (uriResponse.statusCode == 200) {
        p('$bb 💙 statusCode: 👌👌👌 ${uriResponse.statusCode} 👌👌👌 💙 '
            'for $apiRoute 🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
        try {
          var mJson = json.decode(uriResponse.body);
          return mJson;
        } catch (e) {
          return uriResponse.body;
        }
      } else {
        p('$bb 👿👿👿👿👿👿👿👿👿 Bad moon rising ...POST failed! 👿👿  fucking status code: '
            '👿👿 ${uriResponse.statusCode} 👿👿');
        throw Exception(
            '🚨 🚨 Status Code 🚨 ${uriResponse.statusCode} 🚨 body: ${uriResponse.body}');
      }
    } finally {
      // client.close();
    }
  }

  static Future get({required String apiRoute}) async {
    var url = await getBaseUrl();
    // var token = await Auth.getAuthToken();
    var mHeaders = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    apiRoute = url + apiRoute;
    p('$bb GET:  🔵 '
        '🔆 .................. calling backend: 💙 $apiRoute  💙');
    var start = DateTime.now();
    // var dur = Duration(seconds: mTimeOut == null ? timeOutInSeconds : mTimeOut);
    try {
      var uriResponse =
          await client.get(Uri.parse(apiRoute), headers: mHeaders);
      var end = DateTime.now();
      p('$bb RESPONSE: 💙 status: ${uriResponse.statusCode} 💙 body: ${uriResponse.body}');

      if (uriResponse.statusCode == 200) {
        p('$bb 💙 statusCode: 👌👌👌 ${uriResponse.statusCode} 👌👌👌 💙 '
            'for $apiRoute 🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
        try {
          var mJson = json.decode(uriResponse.body);
          return mJson;
        } catch (e) {
          return uriResponse.body;
        }
      } else {
        p('$bb 👿👿👿👿👿👿👿 Bad moon rising ....GET failed! 👿👿 fucking status code: '
            '👿👿 ${uriResponse.statusCode} 👿👿');
        throw Exception(
            '🚨 🚨 Status Code 🚨 ${uriResponse.statusCode} 🚨 body: ${uriResponse.body}');
      }
    } finally {
      // client.close();
    }
  }

  static Future getWithNoAuth(
      {required String apiRoute, required int mTimeOut}) async {
    var url = await getBaseUrl();
    var mHeaders = {'Content-Type': 'application/json'};
    apiRoute = '$url$apiRoute';
    p('$bb getWithNoAuth:  🔆 calling backend:  ............apiRoute: 💙 '
        '$apiRoute  💙');
    var start = DateTime.now();
    try {
      var uriResponse =
          await client.get(Uri.parse(apiRoute), headers: mHeaders);
      var end = DateTime.now();
      p('$bb RESPONSE: 💙 status: ${uriResponse.statusCode} 💙 body: ${uriResponse.body}');
      if (uriResponse.statusCode == 200) {
        p('$bb 💙 statusCode: 👌👌👌 ${uriResponse.statusCode} 👌👌👌 💙 '
            'for $apiRoute 🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
        try {
          var mJson = json.decode(uriResponse.body);
          return mJson;
        } catch (e) {
          return uriResponse.body;
        }
      } else {
        p('$bb 👿👿👿👿👿👿👿👿👿 Bad moon rising ....  fucking status code: '
            '👿👿 ${uriResponse.statusCode} 👿👿');
        throw Exception(
            '🚨 🚨 Status Code 🚨 ${uriResponse.statusCode} 🚨 body: ${uriResponse.body}');
      }
    } finally {
      client.close();
    }
  }
}
