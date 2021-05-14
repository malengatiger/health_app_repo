import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'geofence_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  debugPrint('$mm App main: FlutterLocalNotificationsPlugin initializing ...');

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  debugPrint(
      '$mm App main: 🍊 🍊 FlutterLocalNotificationsPlugin initialized 🍊 🍊 ');
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
      ),
      home: GeofencePage(),
    );
  }
}

Future<String> onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  debugPrint(
      '$mm onDidReceiveLocalNotification:🍏 title: $title 🍏 payload: $payload 🍏 body: $body ');
  return payload;
}

Future selectNotification(String payload) async {
  debugPrint('$mm selectNotification: 🍏 payload: $payload');
  return null;
}

const mm = '🔵 🔵 🔵 🔵 🔵 MaterialApp: ';
