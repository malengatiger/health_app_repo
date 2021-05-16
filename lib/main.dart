import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';
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
    // return MaterialApp(
    //   title: 'Geofencer',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     primarySwatch: Colors.indigo,
    //     textTheme: GoogleFonts.ralewayTextTheme(
    //       Theme.of(context).textTheme,
    //     ),
    //   ),
    //   // home: HealthPage(),
    //   home: GeofencePage(),
    //   // home: GeofenceMap(),
    // );
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: WillStartForegroundTask(
          onWillStart: () {
            // You can add a foreground task start condition.
            return true;
          },
          notificationOptions: NotificationOptions(
              channelId: 'geofence_service_notification_channel',
              channelName: 'Geofence Service Notification',
              channelDescription:
                  'This notification appears when the geofence service is running in the background.',
              channelImportance: NotificationChannelImportance.LOW,
              priority: NotificationPriority.LOW),
          notificationTitle: 'Geofence Service is running',
          notificationText: 'Tap to return to the app',
          child: GeofencePage()),
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
