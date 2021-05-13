import 'package:flutter/material.dart';
import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';
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
    debugPrint('$mm ..... _listen: 🍐 🍐 🍐 listenToBackgroundLocation ....');
    _geofencer.listenToBackgroundLocation(this);
  }

  void _startFences() async {
    debugPrint('$mm ..... startFences will happen soon ....');
    var result = await _geofencer.buildGeofences(this);
    debugPrint(
        '$mm ..... startFences: 🍎 result from buildGeofences: $result 🍎');
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
    );
  }

  @override
  onGeofenceEntry(Geolocation geolocation) {
    debugPrint(
        '$mm onGeofenceEntry: geoLocation at ENTRY: 🔵  lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} 💚 💚 💚');
  }

  @override
  onGeofenceExit(Geolocation geolocation) {
    debugPrint(
        '$mm onGeofenceExit: geoLocation at EXIT:  🔵 lat: ${geolocation.latitude} 🔵 lng: ${geolocation.longitude} ❤️ ❤️ ❤️');
  }

  @override
  onBackgroundLocation(Coordinate coordinate) {
    debugPrint(
        '$mm onBackgroundLocation: coordinates: 🥦 lat: ${coordinate.latitude} 🥦 lng: ${coordinate.longitude} 🥦 ');
  }
}
