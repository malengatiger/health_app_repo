import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import 'functions_and_shit.dart';
import 'geofence_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  pp('$mm App main: FlutterLocalNotificationsPlugin initializing ...');

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  // final IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings(
  //         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  // final InitializationSettings initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //     macOS: initializationSettingsMacOS);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: selectNotification);

  pp('$mm App main: 🍊 🍊 FlutterLocalNotificationsPlugin initialized 🍊 🍊 ');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geofencer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: GeofencePage(),
      // home: GeofenceMap(),
    );
  }
}

Future<String> onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  pp('$mm onDidReceiveLocalNotification:🍏 title: $title 🍏 payload: $payload 🍏 body: $body ');
  return payload;
}

Future selectNotification(String payload) async {
  pp('$mm selectNotification: 🍏 payload: $payload');
  return null;
}

const mm = '🔵 🔵 🔵 🔵 🔵 MaterialApp: ';
