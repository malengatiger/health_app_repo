import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app_repo/util/notifications_service.dart';

import 'functions_and_shit.dart';
import 'geofence_page.dart';

const mm = '🖐🏽🖐🏽🖐🏽🖐🏽🖐🏽🖐🏽 Material App: ';

void main() async {
  pp('$mm App main: FlutterLocalNotificationsPlugin initializing ...');
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    notificationService = NotificationService(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
          onWillStart: () {
            // You can add a foreground task start condition.
            pp('$mm App main: 🍊 🍊 WillStartForegroundTask 🔵 onWillStart 🍊 🍊 \n WHAT the fuck DOES THIS code DO???');
            return true;
          },
          notificationOptions: NotificationOptions(
              channelId: 'geofence_service_notification_channel',
              channelName: 'Geofence Builder Notification',
              channelDescription:
                  'This notification appears when the Geofence Builder service is running in the background.',
              channelImportance: NotificationChannelImportance.LOW,
              priority: NotificationPriority.LOW),
          notificationTitle: 'Geofence Builder is RUNNING!',
          notificationText: 'Tap here to navigate to the app',
          taskCallback: _taskCallback,
          child: GeofencePage()),
    );
  }

  void _taskCallback(DateTime timestamp) {
    pp('$mm _taskCallback: 🍊 🍊 timestamp: ${timestamp.toIso8601String()} 🍊 🍊  what do we do now, Senor?');
  }
}
