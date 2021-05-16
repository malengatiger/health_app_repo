import 'package:health_app_repo/geofence_location.dart';
import 'package:health_app_repo/util/util.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class LocalDB {
  static const APP_ID = 'anchorAppID';
  static bool dbConnected = false;
  static int cnt = 0;

  static String databaseName = 'anchor001a';
  static Box? geoLocationBox;
  static Box? geoLocationEventBox;

  static const aa = '🔵 🔵 🔵 🔵 🔵 LocalDB(Hive): ';

  static Future initializeHive() async {
    if (geoLocationBox == null) {
      p('$aa Connecting to Hive, getting document directory on device ... ');
      final appDocumentDirectory =
          await path_provider.getApplicationDocumentsDirectory();

      Hive.init(appDocumentDirectory.path);
      p('$aa Hive local data will be stored here ... '
          ' 🍎 🍎 ${appDocumentDirectory.path}');

      geoLocationBox = await Hive.openBox("geoLocationBox");
      geoLocationEventBox = await Hive.openBox("geoLocationEventBox");
      p('$aa Hive geoLocationBox:  🔵  ....geoLocationBox.isOpen: ${geoLocationBox!.isOpen}');
      p('$aa Hive local data ready to rumble ....$aa');
      return '$aa Hive Initialized OK';
    }
  }

  static Future addGeofenceLocations(List<GeofenceLocation> requests) async {
    requests.forEach((element) async {
      await addGeofenceLocation(element);
    });
  }

  static Future addGeofenceLocation(GeofenceLocation location) async {
    await initializeHive();
    await geoLocationBox!.put(location.locationId, location.toJson());
    p('$aa GeofenceLocation added or changed: 🍎 '
        'record: ${location.toJson()}');
  }

  static Future addGeofenceLocationEvent(
      GeofenceLocationEvent locationEvent) async {
    await initializeHive();
    await geoLocationEventBox!
        .put(locationEvent.eventId, locationEvent.toJson());
    p('$aa GeofenceLocationEvent added or changed: 🍎 '
        'record: ${locationEvent.toJson()}');
  }

  static Future deleteGeofenceLocations() async {
    await initializeHive();
    await geoLocationBox!.deleteFromDisk();
    geoLocationBox = await Hive.openBox("geoLocationBox");
    p('$aa Hive geoLocationBox:  🔵  ....geoLocationBox.isOpen: ${geoLocationBox!.isOpen}');
    p('$aa GeofenceLocation deleted from Disk: 🍎');
  }

  static Future<List<GeofenceLocation>> getGeofenceLocations() async {
    await initializeHive();
    List<GeofenceLocation> locations = [];
    List values = geoLocationBox!.values.toList();
    values.forEach((element) {
      locations.add(GeofenceLocation.fromJson(element));
    });

    p('$aa getGeofenceLocations found 🔵 ${locations.length}');
    return locations;
  }
}
