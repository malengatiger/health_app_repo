import 'package:flutter_geofence/geofence.dart';
import 'package:geolocator/geolocator.dart';

import 'functions_and_shit.dart';
import 'geofence_location.dart';

final Geofencer geofencer = Geofencer.instance;

abstract class GeofencerListener {
  onGeofenceEntry(GeofenceLocation geolocation);
  onGeofenceExit(GeofenceLocation geolocation);
  onBackgroundLocation(Coordinate coordinate);
}

class Geofencer {
  static const mm = '💦💦💦💦  Geofencer: ';

  Geofencer._privateConstructor() {
    Geofence.initialize();
    pp('$mm Geofencer has been initialized : 🌺 ${DateTime.now().toIso8601String()} 🌺');
  }

  static final Geofencer instance = Geofencer._privateConstructor();

  Future buildGeofences(
      {required List<GeofenceLocation> locations,
      required GeofencerListener listener}) async {
    for (var loc in locations) {
      await buildGeofence(geofenceLocation: loc, listener: listener);
    }
  }

  Future buildGeofence(
      {required GeofenceLocation geofenceLocation,
      required GeofencerListener listener}) async {
    pp('$mm will be building geofences: requesting permission ...');
    Geofence.requestPermissions();
    var location = Geolocation(
        latitude: geofenceLocation.latitude!,
        longitude: geofenceLocation.longitude!,
        radius: 200,
        id: '${geofenceLocation.locationId}');

    await Geofence.addGeolocation(location, GeolocationEvent.entry)
        .then((onValue) {
      //scheduleNotification("Georegion added", "Your geofence has been added!");
      pp('$mm Geofence has been added for ENTRY: 💙 💙 💙 ');
    }).catchError((error) {
      pp("failed with $error");
      throw Exception('😈 👿 We are fucked, Boss! $error');
    });
    await Geofence.addGeolocation(location, GeolocationEvent.exit)
        .then((onValue) {
      //scheduleNotification("Georegion added", "Your geofence has been added!");
      pp('$mm Geofence has been added for EXIT:  ❤️ ❤️ ❤️');
    }).catchError((error) {
      pp("failed with $error");
      throw Exception('😈 👿 We are fucked, Boss! $error');
    });

    Geofence.startListening(GeolocationEvent.entry, (entry) {
      //scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
      pp('$mm Geofence has been fired for ENTRY:  🛎 🛎 🛎 🛎 lat: ${entry.latitude} lng: ${entry.longitude}');
      listener.onGeofenceEntry(geofenceLocation);
    });

    Geofence.startListening(GeolocationEvent.exit, (exit) {
      //scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
      pp('$mm Geofence has been fired for EXIT:  🛎 🛎 🛎 🛎  lat: ${exit.latitude} lng: ${exit.longitude}');
      listener.onGeofenceEntry(geofenceLocation);
    });

    pp('✅ ✅ Geofence has been added for both enter and exit ✅ ✅ listeners set up 🔺🔺🔺');
    return null;
  }

  void listenToBackgroundLocation(GeofencerListener listener) {
    Geofence.backgroundLocationUpdated.stream.listen((event) {
      // scheduleNotification("You moved significantly", "a significant location change just happened.");
      pp('$mm Geofence backgroundLocationUpdated: 🔷 🔷 🔷 🔷  ${event.latitude} ${event.longitude}');
      listener.onBackgroundLocation(event);
    });
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('😈 👿 Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('😈 👿 Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          '😈 👿 Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var pos = await Geolocator.getCurrentPosition();
    pp('$mm Position via Geolocator: 🌀 🌀 latitude: ${pos.latitude} 🌀 🌀 longitude: ${pos.longitude}');

    return pos;
  }
}
