import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health_app_repo/data_models/geofence_location.dart';
import 'package:health_app_repo/services/cron_service.dart';
import 'package:health_app_repo/services/hive_db.dart';
import 'package:health_app_repo/services/service_le_geofence.dart';
import 'package:health_app_repo/ui/activity_map.dart';
import 'package:health_app_repo/ui/events_page.dart';
import 'package:health_app_repo/ui/health_page.dart';
import 'package:health_app_repo/ui/map.dart';
import 'package:health_app_repo/util/functions.dart';
import 'package:health_app_repo/util/functions_and_shit.dart';
import 'package:health_app_repo/util/util.dart';
import 'package:page_transition/page_transition.dart';

class GeofencePage extends StatefulWidget {
  @override
  _GeofencePageState createState() => _GeofencePageState();
}

class _GeofencePageState extends State<GeofencePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🌸 🌸 🌸 🌸 🌸 GeofencePage: ';
  List<GeofenceLocation> _geofenceLocations = [];
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    cronService.startMyLocationScheduler(2, _onSchedule);
    initLog();
    logger.info('$mm ........... Geofence Builder has started ...');
    _checkConnectivity();
  }

  var _locationMessages = <String>[];

  void _onSchedule(String message) {
    pp('$mm Location message coming in: 💦  💦  💦 $message');
    setState(() {
      _locationMessages.add(message);
    });
  }

  StreamSubscription<ConnectivityResult>? _subscription;
  Position? _position;
  bool busy = false;
  List<GeofenceLocationEvent> _geofenceEvents = [];

  @override
  void dispose() {
    _controller.dispose();
    _subscription!.cancel();
    super.dispose();
  }

  bool connected = false;
  void _checkConnectivity() async {
    pp('$mm ....................................'
        ' checkNetworkConnectivity: 🍐 🍐 🍐');
    connected = await checkNetworkConnectivity();
    pp('$mm ....................................'
        ' checkNetworkConnectivity: 🍐 🍐 🍐 connected: 💪 $connected 💪 ');
    if (connected) {
      _listen();
      await _startFences();
      await _getEvents();
    }
    setState(() {});
  }

  void _listen() {
    pp('$mm ..... _listen: 🍐 🍐 🍐 listenToBackgroundLocation and onConnectivityChanged ....  🍐 ');
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
    pp('$mm getGeofenceEvents: getting events from local disk ...');
    _geofenceEvents = await localDB.getGeofenceEvents();
  }

  Future _startFences() async {
    pp('$mm ..... getting current position and building geofences from local disk ....');
    setState(() {
      busy = true;
    });

    await localDB.initializeHive();
    _position = await Geolocator.getCurrentPosition();
    _geofenceLocations = await localDB.getGeofenceLocations();
    pp('$mm _startFences: locations found 🛎 ${_geofenceLocations.length} geofences ...');
    if (_geofenceLocations.isEmpty) {
      _navigateToMap();
      return null;
    }
    var list = <GeofenceLocation>[];
    _geofenceLocations.forEach((element) async {
      if (element.name != null) {
        list.add(element);
      }
    });
    _geofenceLocations = list;
    pp('$mm _startFences: locations filtered: 🛎 ${_geofenceLocations.length} geofences 🛎 ...');
    await serviceLeGeofence.buildGeofences(locations: _geofenceLocations);

    pp('$mm ..... startFences: 🍎 '
        'current position of device: lat: ${_position!.latitude} '
        'lng: ${_position!.longitude} 🍎');

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
            child: EventsPage()));
    _startFences();
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

    await _getEvents();
    _startFences();
  }

  void _navigateToActivityMap() async {
    pp('$mm ..... _navigateToActivityMap  ....');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(milliseconds: 1000),
            child: ActivityMap()));

    _startFences();
  }

  void _navigateToHealthData() async {
    pp('$mm ..... _navigateToMap  ....');
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(milliseconds: 1000),
            child: HealthPage()));

    _startFences();
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
              }),
          IconButton(
              icon: Icon(
                Icons.map_outlined,
                size: 20,
                color: Colors.pink,
              ),
              onPressed: () {
                _navigateToActivityMap();
              }),
          IconButton(
              icon: Icon(
                Icons.directions_walk,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () {
                _navigateToHealthData();
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
                        Card(
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
                                                MainAxisAlignment.start,
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
                                                    fontWeight: FontWeight.w900,
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
                                                MainAxisAlignment.start,
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
                                                    fontWeight: FontWeight.w900,
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
                        SizedBox(
                          height: 24,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<Geofence>(
                              stream: serviceLeGeofence.geofenceStream,
                              builder: (context, snapshot) {
                                Geofence? geo;
                                if (snapshot.hasData) {
                                  geo = snapshot.data!;
                                  pp('${geo.status.toString()}');
                                }

                                if (geo != null) {
                                  if (geo.status.toString().contains('DWELL')) {
                                    var card = Card(
                                      elevation: 4,
                                      color: Colors.teal[700],
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Geofence Dwelled',
                                              style: Styles.whiteBoldMedium,
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              '${geo.id}',
                                              style: Styles.whiteSmall,
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '${getFormattedDateShortWithTime('${geo.timestamp!.toIso8601String()}', context)}',
                                              style: Styles.whiteSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    return card;
                                  }
                                  if (geo.status.toString().contains('ENTER')) {
                                    var card = Card(
                                      elevation: 4,
                                      color: Colors.amber[800],
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Geofence Entered',
                                              style: Styles.whiteBoldMedium,
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              '${geo.id}',
                                              style: Styles.whiteSmall,
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '${getFormattedDateShortWithTime('${geo.timestamp!.toIso8601String()}', context)}',
                                              style: Styles.whiteSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    return card;
                                  }
                                  if (geo.status.toString().contains('EXIT')) {
                                    var card = Card(
                                      elevation: 4,
                                      color: Colors.pink[700],
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Geofence Exited',
                                              style: Styles.whiteBoldMedium,
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              '${geo.id}',
                                              style: Styles.whiteSmall,
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '${getFormattedDateShortWithTime('${geo.timestamp!.toIso8601String()}', context)}',
                                              style: Styles.whiteSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    return card;
                                  }
                                }
                                return Text(
                                  'No Geofence Event Yet',
                                  style: Styles.greyLabelMedium,
                                );
                              }),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        StreamBuilder<ActivityEvent>(
                            stream: serviceLeGeofence.activityStream,
                            builder: (context, snapshot) {
                              ActivityEvent? act;
                              if (snapshot.hasData) {
                                act = snapshot.data;
                              }
                              if (act != null) {
                                return Card(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('${act.type}'),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              '${act.confidence.toString()}',
                                              style: Styles.pinkBoldSmall,
                                            ),
                                            SizedBox(
                                              height: 28,
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
                                );
                              }
                              return Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'No Activity Seen Yet',
                                    style: Styles.greyLabelMedium,
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Container(
                            height: 600,
                            child: ListView.builder(
                                itemCount: _locationMessages.length,
                                itemBuilder: (_, index) {
                                  var msg =
                                      '${_locationMessages.elementAt(index)}';
                                  return Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        msg,
                                        style: Styles.greyLabelSmall,
                                      ),
                                    ],
                                  );
                                }),
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

  onGeofenceEntry(GeofenceLocation geolocation) {
    pp('$mm onGeofenceEntry: geoLocation at ENTRY: '
        '🔵  lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} 💚 💚 💚');
    setState(() {
      enteredLocation = geolocation;
    });
  }

  onGeofenceExit(GeofenceLocation geolocation) {
    pp('$mm onGeofenceExit: geoLocation at EXIT:  '
        '🔵 lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} ❤️ ❤️ ❤️');
    setState(() {
      exitedLocation = geolocation;
    });
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Text('${activity.type}'),
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
                    '${activity.confidence}',
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
        ));
  }
}
