import 'package:flutter/foundation.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:geolocator/geolocator.dart';

final Geofencer geofencer = Geofencer.instance;

abstract class GeofencerListener {
  onGeofenceEntry(Geolocation geolocation);
  onGeofenceExit(Geolocation geolocation);
  onBackgroundLocation(Coordinate coordinate);
}

class Geofencer {
  static const mm = '💦💦💦💦  Geofencer: ';

  Geofencer._privateConstructor() {
    Geofence.initialize();
    debugPrint(
        '$mm Geofencer has been initialized : 🌺 ${DateTime.now().toIso8601String()} 🌺');
  }

  static final Geofencer instance = Geofencer._privateConstructor();

  Future buildGeofences(GeofencerListener listener) async {
    debugPrint('$mm will be building geofences: requesting permission ...');
    Geofence.requestPermissions();
    var pos = await getCurrentPosition();
    var location = Geolocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        radius: 200,
        id: 'myLocation');
    await Geofence.addGeolocation(location, GeolocationEvent.entry)
        .then((onValue) {
      //scheduleNotification("Georegion added", "Your geofence has been added!");
      debugPrint('$mm Geofence has been added for ENTRY: 💙 💙 💙 ');
    }).catchError((error) {
      print("failed with $error");
      throw Exception('😈 👿 We are fucked, Boss! $error');
    });
    await Geofence.addGeolocation(location, GeolocationEvent.exit)
        .then((onValue) {
      //scheduleNotification("Georegion added", "Your geofence has been added!");
      debugPrint('$mm Geofence has been added for EXIT:  ❤️ ❤️ ❤️');
    }).catchError((error) {
      print("failed with $error");
      throw Exception('😈 👿 We are fucked, Boss! $error');
    });

    Geofence.startListening(GeolocationEvent.entry, (entry) {
      //scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
      debugPrint(
          '$mm Geofence has been fired for ENTRY:  🛎 🛎 🛎 🛎 lat: ${entry.latitude} lng: ${entry.longitude}');
      listener.onGeofenceEntry(entry);
    });

    Geofence.startListening(GeolocationEvent.exit, (exit) {
      //scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
      debugPrint(
          '$mm Geofence has been fired for EXIT:  🛎 🛎 🛎 🛎  lat: ${exit.latitude} lng: ${exit.longitude}');
      listener.onGeofenceEntry(exit);
    });

    return '✅ ✅ Geofence has been added for both enter and exit ✅ ✅ listeners set up 🔺🔺🔺';
  }

  void listenToBackgroundLocation(GeofencerListener listener) {
    Geofence.backgroundLocationUpdated.stream.listen((event) {
      // scheduleNotification("You moved significantly", "a significant location change just happened.");
      debugPrint(
          '$mm Geofence backgroundLocationUpdated: 🔷 🔷 🔷 🔷  ${event.latitude} ${event.longitude}');
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
    debugPrint(
        '$mm Position via Geolocator: 🌀 🌀 latitude: ${pos.latitude} 🌀 🌀 longitude: ${pos.longitude}');

    return pos;
  }
}