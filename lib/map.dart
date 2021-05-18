import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:health_app_repo/functions_and_shit.dart';
import 'package:health_app_repo/geofence_location.dart';
import 'package:health_app_repo/services/hive_db.dart';
import 'package:health_app_repo/util/functions.dart';
import 'package:health_app_repo/util/snack.dart';

import 'services/geocoding_service.dart';

class GeofenceMap extends StatefulWidget {
  @override
  _GeofenceMapState createState() => _GeofenceMapState();
}

class _GeofenceMapState extends State<GeofenceMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition? _myCurrentCameraPosition;
  static const mm = '💙 💙 💙 💙 💙 💙 Map: ';
  List<GeofenceLocation> _geofenceLocations = [];
  var _key = GlobalKey<ScaffoldState>();
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCurrentLocation();
    _getGeofenceLocations();
  }

  Position? _currentPosition;
  void _getCurrentLocation() async {
    pp('$mm .......... get current location ....');
    _currentPosition = await Geolocator.getCurrentPosition();
    if (_currentPosition == null) {
      pp('$mm  👿 👿 👿 👿.......... _currentPosition is null ....');
      return;
    }
    pp('$mm .......... get current location .... found: ${_currentPosition!.toJson()}');
    _myCurrentCameraPosition = CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: 14.4746,
    );
    setState(() {});
  }

  Set<Marker> _markers = HashSet();
  Set<Circle> _circles = HashSet();

  void _getGeofenceLocations() async {
    pp('$mm _getGeofenceLocations ... .....................');
    _geofenceLocations = await localDB.getGeofenceLocations();
    if (_geofenceLocations.isEmpty) {
      AppSnackBar.showSnackBar(
          scaffoldKey: _key,
          message:
              'Please long press on the map to create a geofence.The geofences will have a standard radius of 200 metres',
          textColor: Colors.white,
          backgroundColor: Colors.black);
      return;
    }
    _addMarkers();
  }

  void _addMarker(GeofenceLocation loc) async {
    pp('$mm _addMarker ... GeofenceLocation: 🍎 ${loc.toJson()} 🍎 ');
    _markers.add(Marker(
        markerId: MarkerId(loc.locationId!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          _onMarkerTapped(loc);
        },
        infoWindow: InfoWindow(title: loc.name),
        position: LatLng(loc.latitude!, loc.longitude!)));

    _addCircle(loc);
    var pos = CameraPosition(
        target: LatLng(loc.latitude!, loc.longitude!), zoom: 16.0);

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(pos));
    setState(() {});
  }

  void _addCircle(GeofenceLocation loc) async {
    pp('$mm _addCircle ... GeofenceLocation: 🍎 ${loc.toJson()} 🍎 ');
    _circles.add(Circle(
      center: LatLng(loc.latitude!, loc.longitude!),
      radius: 150.0,
      strokeColor: Colors.pink,
      strokeWidth: 2,
      circleId: CircleId('${loc.locationId}'),
      onTap: () {
        _onMarkerTapped(loc);
      },
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearEverything() async {
    pp('$mm _clearEverything ....  ');
    _geofenceLocations.clear();
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
              Navigator.pop(context, _geofenceLocations);
            }),
        title: Text(
          'Geofence Map',
          style: Styles.whiteSmall,
        ),
        actions: [
          IconButton(icon: Icon(Icons.clear), onPressed: _clearEverything)
        ],
      ),
      body: _myCurrentCameraPosition == null
          ? Center(
              child: Container(
                child: Text(
                  'Waiting for location ...',
                  style: Styles.greyLabelMedium,
                ),
              ),
            )
          : GoogleMap(
              mapType: MapType.hybrid,
              myLocationEnabled: true,
              markers: _markers,
              circles: _circles,
              initialCameraPosition: _myCurrentCameraPosition!,
              onLongPress: _onLongPress,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
    );
  }

  Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  void _onLongPress(LatLng latLng) async {
    pp('$mm onLongPress latLng: 🍎 lat: ${latLng.latitude} lng: ${latLng.longitude}');
    var placeMark = await GeocodingService.getPlacemark(
        latitude: latLng.latitude, longitude: latLng.longitude);
    var loc = GeofenceLocation(
        locationId: DateTime.now().toIso8601String(),
        name: placeMark == null
            ? 'Geofence  🍎 ${_geofenceLocations.length + 1}'
            : '${placeMark.street} ${placeMark.locality} x${_random.nextInt(100)}',
        latitude: latLng.latitude,
        longitude: latLng.longitude);

    pp('$mm onLongPress: adding geofenceLocation: ✅  ✅  ✅ ${loc.toJson()} ');
    _geofenceLocations.add(loc);
    _addMarker(loc);
    await localDB.addGeofenceLocation(loc);
    setState(() {});
  }

  Map<MarkerId, Marker> _zMarkers = Map();

  Future<void> _addMarkers() async {
    pp('💜 💜 💜 💜 💜 💜 _addMarkers, after clearing sets ....... 💜 💜 💜 💜 💜 💜 ..............');
    setState(() {
      _markers.clear();
      _circles.clear();
    });

    _geofenceLocations.forEach((geofenceLocation) {
      final MarkerId markerId = MarkerId('${geofenceLocation.locationId}');
      final Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: LatLng(
          geofenceLocation.latitude!,
          geofenceLocation.longitude!,
        ),
        infoWindow: InfoWindow(
            title: geofenceLocation.name, snippet: 'Geofence Center'),
        onTap: () {
          _onMarkerTapped(geofenceLocation);
        },
      );
      _zMarkers[markerId] = marker;
      _circles.add(Circle(
          center:
              LatLng(geofenceLocation.latitude!, geofenceLocation.longitude!),
          strokeWidth: 4,
          strokeColor: Colors.black,
          circleId: CircleId('${DateTime.now().microsecondsSinceEpoch}')));
    });

    _zMarkers.forEach((key, value) {
      _markers.add(value);
    });

    pp('$mm 🍎 ${_circles.length} 🍎 circles should be drawn on map ....');
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

  void _onMarkerTapped(GeofenceLocation geofenceLocation) {
    pp('$mm _onMarkerTapped: geofenceLocation: lat: ${geofenceLocation.latitude} lng:  ${geofenceLocation.longitude}');
    _addCircle(geofenceLocation);
    setState(() {});
  }
}
