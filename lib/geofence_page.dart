import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health_app_repo/geofencer.dart';

class GeofencePage extends StatefulWidget {
  @override
  _GeofencePageState createState() => _GeofencePageState();
}

class _GeofencePageState extends State<GeofencePage>
    with SingleTickerProviderStateMixin
    implements GeofencerListener {
  AnimationController _controller;
  static const mm = '🌸 🌸 🌸 🌸 🌸  GeofencePage: ';
  Geofencer _geofencer = geofencer;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _startFences();
    _listen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listen() {
    debugPrint(
        '$mm ..... _listen: 🍐 🍐 🍐 listenToBackgroundLocation ....  🍐 ');
    _geofencer.listenToBackgroundLocation(this);
  }

  Position _position;
  void _startFences() async {
    debugPrint('$mm ..... buildGeofence will be called  ....');
    _position = await _geofencer.buildGeofence(this);
    debugPrint(
        '$mm ..... startFences: 🍎 position from buildGeofence: ${_position.latitude} ${_position.longitude} 🍎');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Geofencer',
          style: TextStyle(
              fontWeight: FontWeight.w100, color: Colors.white, fontSize: 14),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _startFences();
              })
        ],
      ),
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: _position == null
                      ? Text('Geofence to be loaded',
                          style: Theme.of(context).textTheme.headline3)
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 24,
                              ),
                              Text(
                                'Geofence Location',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Latitude'),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${_position.latitude}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Longitude'),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${_position.longitude}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 24,
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
                      color: Colors.teal[700],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Entered Geofence',
                          style: TextStyle(color: Colors.white),
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
            ],
          )
        ],
      ),
    );
  }

  Geolocation enteredLocation, exitedLocation;
  Coordinate backgroundLocation;

  @override
  onGeofenceEntry(Geolocation geolocation) {
    debugPrint(
        '$mm onGeofenceEntry: geoLocation at ENTRY: 🔵  lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} 💚 💚 💚');
    setState(() {
      enteredLocation = geolocation;
      exitedLocation = null;
    });
  }

  @override
  onGeofenceExit(Geolocation geolocation) {
    debugPrint(
        '$mm onGeofenceExit: geoLocation at EXIT:  🔵 lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} ❤️ ❤️ ❤️');
    setState(() {
      enteredLocation = null;
      exitedLocation = geolocation;
    });
  }

  @override
  onBackgroundLocation(Coordinate coordinate) {
    debugPrint(
        '$mm onBackgroundLocation: coordinates: 🥦 lat: ${coordinate.latitude} 🥦 lng: ${coordinate.longitude} 🥦 ');
    setState(() {
      backgroundLocation = coordinate;
    });
  }
}
