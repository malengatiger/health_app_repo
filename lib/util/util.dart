import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

import 'functions_and_shit.dart';

Future<String> getBaseUrl() async {
  await DotEnv.load(fileName: '.env');
  String devURL = DotEnv.env['devURL']!;
  String prodURL = DotEnv.env['prodURL']!;
  String status = DotEnv.env['status']!;
  if (status == null) {
    throw Exception('Development or Production Status unknown or unavailable');
  }
  p('🔵 🔵 Properties Data from dot.env file; 🔆 devURL: $devURL 🔵 🔆 prodURL: $prodURL 🔵 🔵 ');
  if (status == 'dev') {
    return devURL;
  } else {
    return prodURL;
  }
}

bool firebaseInitialized = false;

String lorem =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

String dummy =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ";

//Color baseColor = Color(0xFFCADCED);
//Color secondaryColor = Colors.brown[100];

Random _rand = Random(new DateTime.now().millisecondsSinceEpoch);
Color? get baseColor => _getBaseColor();
Color? get secondaryColor => _getSecondaryColor();

/*
  GOOD COLOR COMBINATIONS
  Colors.pink[50]  Colors.brown[100];
  Colors.teal[50] Colors.brown[100];
  Colors.amber[50] Colors.brown[100];
  Colors.indigo[50]
 */
Color? _getBaseColor() {
  List<Color> colors = [];
  colors.add(Colors.blue.shade50);
  colors.add(Colors.grey.shade50);
  colors.add(Colors.pink.shade50);
  colors.add(Colors.teal.shade50);
  colors.add(Colors.red.shade50);
  colors.add(Colors.green.shade50);
  colors.add(Colors.amber.shade50);
  colors.add(Colors.indigo.shade50);
  colors.add(Colors.lightBlue.shade50);
  colors.add(Colors.deepPurple.shade50);
  colors.add(Colors.deepOrange.shade50);
  colors.add(Colors.brown.shade50);
  colors.add(Colors.cyan.shade50);

  int index = _rand.nextInt(colors.length - 1);
//  return Color(0xFFCADCED);
  return Colors.blueGrey[100];
}

Color? _getSecondaryColor() {
  List<Color> colors = [];
  colors.add(Colors.brown.shade100);
  colors.add(Colors.grey.shade100);
  colors.add(Colors.pink.shade50);
  colors.add(Colors.teal.shade100);
  colors.add(Colors.red.shade100);
  colors.add(Colors.green.shade100);
  colors.add(Colors.amber.shade100);
  colors.add(Colors.indigo.shade100);
  colors.add(Colors.lime.shade100);
  colors.add(Colors.deepPurple.shade100);
  colors.add(Colors.deepOrange.shade100);
  colors.add(Colors.brown.shade100);

  int index = _rand.nextInt(colors.length - 1);
  return Colors.brown[50];
}

List<BoxShadow> customShadow = [
  BoxShadow(
      color: Colors.white.withOpacity(0.5),
      spreadRadius: -3,
      offset: Offset(-3, -3),
      blurRadius: 20),
  BoxShadow(
      color: Colors.blue[900]!.withOpacity(0.2),
      spreadRadius: 2,
      offset: Offset(5, 5),
      blurRadius: 12),
];

void p(dynamic message) {
  print(message);
}

Future<bool> checkNetworkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    pp('📡 📡 checkNetworkConnectivity: 🍎 Connected to MOBILE network 🌀');
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    pp('📡 📡 checkNetworkConnectivity: 🍎 Connected to WIFI network 🌀');
    return true;
  } else {
    return false;
  }
}
