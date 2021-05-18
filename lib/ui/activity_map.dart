import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:health_app_repo/data_models/geofence_location.dart';
import 'package:health_app_repo/services/hive_db.dart';
import 'package:health_app_repo/util/functions.dart';
import 'package:health_app_repo/util/functions_and_shit.dart';

class ActivityMap extends StatefulWidget {
  @override
  _ActivityMapState createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _myCurrentCameraPosition =
      CameraPosition(target: LatLng(0.0, 0.0));
  static const mm = '😎 😎 😎 😎 😎 😎  ActivityMap: ';
  List<ActivityEvent> _activityEvents = [];
  var _key = GlobalKey<ScaffoldState>();
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCurrentLocation();
    _getActivityEvents();
  }

  Position? _currentPosition;
  void _getCurrentLocation() async {
    pp('$mm .......... get current location ....');
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      if (_currentPosition == null) {
        pp('$mm  👿 👿 👿 👿.......... _currentPosition is null ....');
        return;
      }
      pp('$mm .......... get current location .... found: ${_currentPosition!.toJson()}');
    } catch (e) {
      pp('$mm Current position is fucked!');
    }
    if (_myCurrentCameraPosition != null) {
      _myCurrentCameraPosition = CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14.4746,
      );
      setState(() {});
    }
  }

  Set<Marker> _markers = HashSet();
  Set<Circle> _circles = HashSet();

  void _getActivityEvents() async {
    pp('$mm _getActivityEvents ... .....................');
    _activityEvents = await localDB.getActivities();
    _addMarkers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearEverything() async {
    pp('$mm _clearEverything ....  ');
    _activityEvents.clear();
    _markers.clear();
    await localDB.deleteGeofenceLocations();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, _activityEvents);
            }),
        title: Text(
          'Activity Map',
          style: Styles.whiteSmall,
        ),
        actions: [
          IconButton(icon: Icon(Icons.clear), onPressed: _clearEverything)
        ],
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationEnabled: true,
        markers: _markers,
        circles: _circles,
        initialCameraPosition: _myCurrentCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
      ),
    );
  }

  Map<MarkerId, Marker> _zMarkers = Map();

  Future<void> _addMarkers() async {
    pp('$mm _addMarkers, after clearing sets ....... 💜 💜 💜 💜 💜 💜 ..............');
    setState(() {
      _markers.clear();
    });

    _activityEvents.forEach((event) {
      if (event.latitude != null) {
        final MarkerId markerId = MarkerId('${event.eventId}');
        final Marker marker = Marker(
          markerId: markerId,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: LatLng(
            event.latitude!,
            event.longitude!,
          ),
          infoWindow: InfoWindow(title: event.type, snippet: event.date),
          onTap: () {
            _onMarkerTapped(event);
          },
        );
        _zMarkers[markerId] = marker;
      }
    });

    _zMarkers.forEach((key, value) {
      _markers.add(value);
    });

    pp('$mm 🍎 ${_markers.length} 🍎 markers should be drawn on map ....');
    setState(() {});

    if (_markers.isEmpty) {
      return null;
    }
    final CameraPosition _first = CameraPosition(
      target: LatLng(_markers.elementAt(0).position.latitude,
          _markers.elementAt(0).position.longitude),
      zoom: 15.4,
    );

    var googleMapController = await _mapController.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(_first));
    setState(() {});
  }

  void _onMarkerTapped(ActivityEvent event) {
    pp('$mm _onMarkerTapped: ActivityEvent: lat: ${event.toJson()} ');

    setState(() {});
  }
}
