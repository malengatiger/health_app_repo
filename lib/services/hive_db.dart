import 'package:health_app_repo/functions_and_shit.dart';
import 'package:health_app_repo/geofence_location.dart';
import 'package:health_app_repo/util/util.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

final LocalDB localDB = LocalDB.instance;

class LocalDB {
  static const APP_ID = 'anchorAppID';
  bool dbConnected = false;
  int cnt = 0;

  String databaseName = 'anchor001a';
  Box? geoLocationBox;
  Box? geoLocationEventBox;
  Box? activityBox;

  static const aa = '🔵 🔵 🔵 🔵 🔵 LocalDB(Hive): ';
  static final LocalDB instance = LocalDB._privateConstructor();

  LocalDB._privateConstructor() {
    pp('$aa ... LocalDB._privateConstructor has been initialized : 🌺 🌺 🌺 🌺 🌺 '
        '${DateTime.now().toIso8601String()} 🌺');
  }

  Future initializeHive() async {
    p('$aa initializeHive: 🔵 Connecting to Hive, getting document directory on device ... ');
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();

    Hive.init(appDocumentDirectory.path);
    p('$aa Hive local data will be stored here ... '
        ' 🍎 🍎 ${appDocumentDirectory.path}');

    geoLocationBox = await Hive.openBox("geoLocationBox");
    geoLocationEventBox = await Hive.openBox("geoLocationEventBox");
    activityBox = await Hive.openBox("geoLocationEventBox");
    p('$aa Hive geoLocationBox:  🔵  ....geoLocationBox.isOpen: ${geoLocationBox!.isOpen}');
    p('$aa Hive geoLocationEventBox:  🔵  ....geoLocationEventBox.isOpen: ${geoLocationEventBox!.isOpen}');
    p('$aa Hive activityBox:  🔵  ....activityBox.isOpen: ${activityBox!.isOpen}');

    p('$aa Hive local data ready to rumble ....$aa');
    return '\n\n$aa Hive Initialized OK\n';
  }

  Future addGeofenceLocations(List<GeofenceLocation> requests) async {
    requests.forEach((element) async {
      await addGeofenceLocation(element);
    });
  }

  Future addGeofenceLocation(GeofenceLocation location) async {
    await geoLocationBox!.put(location.locationId, location.toJson());
    p('$aa GeofenceLocation added or changed: 🍎 '
        'record: ${location.toJson()}');
  }

  Future addActivity(ActivityEvent activity) async {
    p('$aa ActivityEvent about to be added to disk ............ : 🍎 ');
    await activityBox!.put(DateTime.now().toIso8601String(), activity.toJson());
    p('$aa ActivityEvent added : 🍎 '
        'record: ${activity.toJson()}');
  }

  Future addGeofenceLocationEvent(GeofenceLocationEvent locationEvent) async {
    await geoLocationEventBox!
        .put(locationEvent.eventId, locationEvent.toJson());
    p('$aa GeofenceLocationEvent added or changed: 🍎 '
        'record: ${locationEvent.toJson()}');
  }

  Future deleteGeofenceLocations() async {
    await geoLocationBox!.deleteFromDisk();
    geoLocationBox = await Hive.openBox("geoLocationBox");
    p('$aa Hive geoLocationBox:  🔵  ....geoLocationBox.isOpen: ${geoLocationBox!.isOpen}');
    p('$aa GeofenceLocations deleted from Disk: 🍎');
  }

  Future<List<GeofenceLocation>> getGeofenceLocations() async {
    List<GeofenceLocation> locations = [];
    List values = geoLocationBox!.values.toList();
    values.forEach((element) {
      locations.add(GeofenceLocation.fromJson(element));
    });

    p('$aa getGeofenceLocations found 🔵 ${locations.length}');
    return locations;
  }

  Future<List<ActivityEvent>> getActivities() async {
    List<ActivityEvent> activities = [];
    List values = activityBox!.values.toList();
    values.forEach((element) {
      activities.add(ActivityEvent.fromJson(element));
    });

    p('$aa activityEvents found 🔵 ${activities.length}');
    return activities;
  }

  Future<GeofenceLocation?>? getGeofenceLocationById(String id) async {
    GeofenceLocation? location;
    List values = geoLocationBox!.values.toList();
    values.forEach((element) {
      var loc = GeofenceLocation.fromJson(element);
      if (loc.locationId == id) {
        location = loc;
      }
    });

    return location;
  }

  Future<List<GeofenceLocationEvent>> getGeofenceEvents() async {
    List<GeofenceLocationEvent> events = [];
    List values = geoLocationEventBox!.values.toList();
    values.forEach((element) {
      events.add(GeofenceLocationEvent.fromJson(element));
    });

    p('$aa getGeofenceLocationEvents found 🔵 ${events.length}');
    return events;
  }

  Future deleteGeofenceLocationEvents() async {
    await geoLocationEventBox!.deleteFromDisk();
    geoLocationEventBox = await Hive.openBox("geoLocationEventBox");
    p('$aa Hive geoLocationEventBox:  🔵  .... '
        'geoLocationEventBox.isOpen: ${geoLocationEventBox!.isOpen}');
    p('$aa GeofenceLocationEvents deleted from Disk: 🍎');
  }
}
