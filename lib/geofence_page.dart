import 'dart:async';
import 'dart:io';

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health_app_repo/events_page.dart';
import 'package:health_app_repo/geofence_location.dart';
import 'package:health_app_repo/geofencer.dart';
import 'package:health_app_repo/map.dart';
import 'package:health_app_repo/util/functions.dart';
import 'package:health_app_repo/util/util.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'functions_and_shit.dart';
import 'hive_db.dart';

class GeofencePage extends StatefulWidget {
  @override
  _GeofencePageState createState() => _GeofencePageState();
}

class _GeofencePageState extends State<GeofencePage>
    with SingleTickerProviderStateMixin
    implements GeofencerListener {
  late AnimationController _controller;
  static const mm = '🌸 🌸 🌸 🌸 🌸  GeofencePage: ';
  Geofencer _geofencer = geofencer;
  List<GeofenceLocation> _geofenceLocations = [];
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    initLog();
    logger.info('$mm ........... Geofence Builder has started ...');
    _checkConnectivity();
    _init();
  }

  late Stream<ActivityEvent> activityStream;
  ActivityEvent latestActivity = ActivityEvent.empty();
  List<ActivityEvent> _events = [];
  ActivityRecognition activityRecognition = ActivityRecognition.instance;
  StreamSubscription<ConnectivityResult>? _subscription;
  Position? _position;
  bool busy = false;
  List<GeofenceLocationEvent> _geofenceEvents = [];

  void _init() async {
    /// Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    } else {
      _startTracking();
    }
  }

  void _startTracking() {
    pp("$mm start activity tracking ..................");
    activityStream =
        activityRecognition.startStream(runForegroundService: true);
    activityStream.listen(onData);
  }

  void onData(ActivityEvent activityEvent) {
    pp("$mm onData: ActivityEvent fired: .................. "
        "🍎  ${activityEvent.toString()} - "
        "🍎  ${getFormattedDateShortWithTime(DateTime.now().toIso8601String(), context)}");

    setState(() {
      _events.add(activityEvent);
      latestActivity = activityEvent;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool connected = false;
  void _checkConnectivity() async {
    connected = await checkNetworkConnectivity();
    if (connected) {
      _listen();
      await _startFences();
      await _getEvents();
    }
    setState(() {});
  }

  void _listen() {
    pp('$mm ..... _listen: 🍐 🍐 🍐 listenToBackgroundLocation and onConnectivityChanged ....  🍐 ');
    _geofencer.listenToBackgroundLocation(this);
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      p('$mm Got a new connectivity status! ${result.toString()}');
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          connected = true;
        });
      } else {
        p('$mm 👿 👿 👿 Network unavailable');
        setState(() {
          connected = false;
        });
      }
    });
  }

  Future _getEvents() async {
    pp('$mm getting events from disk ...');
    _geofenceEvents = await LocalDB.getGeofenceEvents();
  }

  Future _startFences() async {
    pp('$mm ..... buildGeofence will be called  ....');
    setState(() {
      busy = true;
    });
    _position = await Geolocator.getCurrentPosition();
    _geofenceLocations = await LocalDB.getGeofenceLocations();
    await _geofencer.buildGeofences(
        locations: _geofenceLocations, listener: this);
    pp('$mm ..... startFences: 🍎 position from buildGeofence: ${_position!.latitude} ${_position!.longitude} 🍎');
    setState(() {
      busy = false;
    });
  }

  void _navigateToEvents() async {
    pp('$mm ..... _navigateToMap  ....');
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(milliseconds: 1000),
            child: EventsPage(
              events: _geofenceEvents,
            )));
  }

  void _navigateToMap() async {
    pp('$mm ..... _navigateToMap  ....');
    _geofenceLocations = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(milliseconds: 1000),
            child: GeofenceMap()));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[100],
        elevation: 0,
        title: Text(
          'Geofence Builder',
          style: TextStyle(
              fontWeight: FontWeight.w300, color: Colors.black, fontSize: 14),
        ),
        actions: [
          _geofenceEvents.isEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: 24,
                    color: Colors.indigo,
                  ),
                  onPressed: () {
                    _startFences();
                    _getEvents();
                  })
              : IconButton(
                  icon: Icon(
                    Icons.event,
                    size: 20,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _navigateToEvents();
                  }),
          IconButton(
              icon: Icon(
                Icons.map,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () {
                _navigateToMap();
              })
        ],
      ),
      backgroundColor: Colors.brown[100],
      body: busy
          ? Center(
              child: Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.pink,
                ),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 4,
                            child: _position == null
                                ? Text('Geofence is to be loaded ..',
                                    style: Theme.of(context).textTheme.caption)
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${_geofenceLocations.length}',
                                              style: Styles.blueBoldMedium,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Geofence Locations',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Network Connection'),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            connected
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.teal[600],
                                                        shape: BoxShape.circle),
                                                    width: 12,
                                                    height: 12,
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.pink[600],
                                                        shape: BoxShape.circle),
                                                    width: 12,
                                                    height: 12,
                                                  )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: 80,
                                                    child: Text('Latitude')),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  '${_position!.latitude}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: 80,
                                                    child: Text('Longitude')),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  '${_position!.longitude}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 28,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        enteredLocation == null
                            ? Container(
                                child: Text(
                                  'No entry recorded',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              )
                            : Card(
                                elevation: 8,
                                color: Colors.teal[700],
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Entered Geofence',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text('${enteredLocation!.name}'),
                                      Text(
                                        '${DateTime.now().toIso8601String()}',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 24,
                        ),
                        exitedLocation == null
                            ? Container(
                                child: Text(
                                  'No exit recorded',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              )
                            : Card(
                                color: Colors.pink,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Exited Geofence',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 24,
                        ),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Activity Recognition',
                                  style: Styles.tealBoldMedium,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${latestActivity.type}'),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Confidence',
                                      style: Styles.greyLabelSmall,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '${latestActivity.confidence}',
                                      style: Styles.pinkBoldMedium,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '${getFormattedDateLongWithTime(DateTime.now().toIso8601String(), context)}',
                                      style: Styles.greyLabelTiny,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  GeofenceLocation? enteredLocation, exitedLocation;
  Coordinate? backgroundLocation;

  @override
  onGeofenceEntry(GeofenceLocation geolocation) {
    pp('$mm onGeofenceEntry: geoLocation at ENTRY: 🔵  lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} 💚 💚 💚');
    setState(() {
      enteredLocation = geolocation;
      exitedLocation = null;
    });
  }

  @override
  onGeofenceExit(GeofenceLocation geolocation) {
    pp('$mm onGeofenceExit: geoLocation at EXIT:  🔵 lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} ❤️ ❤️ ❤️');
    setState(() {
      enteredLocation = null;
      exitedLocation = geolocation;
    });
  }

  @override
  onBackgroundLocation(Coordinate coordinate) {
    pp('$mm onBackgroundLocation: coordinates: 🥦 lat: ${coordinate.latitude} 🥦 lng: ${coordinate.longitude} 🥦 ');
    setState(() {
      backgroundLocation = coordinate;
    });
  }
}
