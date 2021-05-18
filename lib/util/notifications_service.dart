import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:health_app_repo/ui/notif_receiver.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'functions_and_shit.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

const MethodChannel platform =
    MethodChannel('boha.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

late NotificationService notificationService;

class NotificationService {
  late BuildContext context;

  NotificationService(BuildContext context) {
    this.context = context;
    pp('$mm NotificationService construction: 🍊 🍊 context passed in: ${context.toString()}');
    _startConfiguring();
  }

  void requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future _startConfiguring() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    pp('$mm _startConfiguring: 🍊 🍊 notificationAppLaunchDetails.toString() : ${notificationAppLaunchDetails.toString()} 🍊 🍊 ');
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) =>
          _onShitHappening(id, title!, body!, payload!),
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    pp('$mm _startConfiguring: 🍊 🍊 initializationSettings.toString() : ${initializationSettings.toString()} 🍊 🍊 ');

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectedNotificationPayload = payload;
      selectNotificationSubject.add(payload);
    });

    pp('$mm _startConfiguring: 🍊 🍊 FlutterLocalNotificationsPlugin initialized 🍊 🍊 ');
    _configureLocalTimeZone();
    _configureDidReceiveLocalNotificationSubject();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
    pp('$mm _configureLocalTimeZone: timeZoneName: 🌍 🌍 🌍 🌍  $timeZoneName 🌍 🌍 🌍 🌍');
  }

  void _configureDidReceiveLocalNotificationSubject() {
    pp('$mm _configureDidReceiveLocalNotificationSubject starting .....  🍊 🍊 🍊 🍊 ');
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => NotifReceiver(
                      payload: receivedNotification.payload!,
                    ),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void configureSelectNotificationSubject(BuildContext context) {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, '/secondPage');
    });
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

  static const mm = '🏈 🏈 🏈 🏈 🏈 NotificationService: ';

  Future _onShitHappening(int id, String title, String body, String payload) {
    pp('$mm _onShitHappening: title: $title body: $body payload: $payload ...');
    dynamic cc = "hey";
    return cc;
  }
}
