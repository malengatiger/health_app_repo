import 'dart:async';

import 'package:geofence_service/geofence_service.dart';

import '../data_models/geofence_location.dart';
import '../util/functions_and_shit.dart';
import 'hive_db.dart';

final ServiceLeGeofence serviceLeGeofence = ServiceLeGeofence.instance;

class ServiceLeGeofence {
  static const mm = '🌀 🌀 🌀 🌀 ServiceLeGeofence: 🌀 ';
  static final ServiceLeGeofence instance =
      ServiceLeGeofence._privateConstructor();

  ServiceLeGeofence._privateConstructor() {
    pp('$mm ... ServiceLeGeofence._privateConstructor has been initialized : 🌺 🌺 🌺 🌺 🌺 '
        '${DateTime.now().toIso8601String()} 🌺');
    _init();
  }

  static const INTERVAL = 5000,
      ACCURACY = 100,
      LOITERING = 20000,
      STATUS_CHANGE_DELAY = 1000,
      RADIUS = 100.0;

  late GeofenceService geofenceService;

  _init() {
    pp('$mm ... GeofenceService is about to set up configuration settings. 🛎 🛎 🛎 🛎 ');
    geofenceService = GeofenceService.instance.setup(
        interval: INTERVAL,
        accuracy: ACCURACY,
        loiteringDelayMs: LOITERING,
        statusChangeDelayMs: STATUS_CHANGE_DELAY,
        useActivityRecognition: true,
        allowMockLocations: false,
        geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

    pp('$mm ... GeofenceService.instance.setup: configuration settings has completed OK. 🛎 '
        'isRunningService: 🌺 ${geofenceService.isRunningService} 🌺');
    try {
      geofenceService
          .addGeofenceStatusChangedListener(_onGeofenceStatusChanged);
      geofenceService.addActivityChangedListener(_onActivityChanged);
      geofenceService.addStreamErrorListener(_onError);
    } catch (e) {
      pp('👿 👿 👿 👿 👿 👿 👿 geofenceService.addStreamErrorListener: $e 👿 👿 ');
    }
  }

  StreamController<Geofence> _geofenceStreamController =
      StreamController<Geofence>.broadcast();
  Stream<Geofence> get geofenceStream => _geofenceStreamController.stream;

  StreamController<ActivityEvent> _activityStreamController =
      StreamController<ActivityEvent>.broadcast();

  Stream<ActivityEvent> get activityStream => _activityStreamController.stream;

  close() {
    _geofenceStreamController.close();
    _activityStreamController.close();
  }

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Position position) async {
    pp('\n\n$mm  🧡 🧡 🧡 _onGeofenceStatusChanged 🔊 🔊 🔊 🔊 🔊 🔊  geofence: ${geofence.toMap()}');
    pp('$mm _onGeofenceStatusChanged 🔊 geofenceRadius: ${geofenceRadius.toMap()}');
    pp('$mm _onGeofenceStatusChanged 🔊 geofenceStatus: 💚 ${geofenceStatus.toString()} 💚 \n');

    bool entered = false, dwelled = false, exited = false;

    if (geofence.status.toString().contains('ENTER')) {
      entered = true;
    }
    if (geofence.status.toString().contains('DWELL')) {
      dwelled = true;
    }
    if (geofence.status.toString().contains('EXIT')) {
      exited = true;
    }

    var geo = GeofenceLocation(
        locationId: geofence.data['locationId'],
        name: geofence.data['name'],
        latitude: geofence.latitude,
        longitude: geofence.longitude,
        radius: geofenceRadius.length);

    var locationEvent = GeofenceLocationEvent(
        eventId: geofence.timestamp!.toIso8601String(),
        geofenceLocation: geo,
        date: geofence.timestamp!.toIso8601String(),
        entered: entered,
        dwelled: dwelled,
        exited: exited,
        radius: geofenceRadius.length);

    await localDB.addGeofenceLocationEvent(locationEvent);
    pp('$mm _onGeofenceStatusChanged: 🔵 🔵 🔵 🔵 🔵 🔵 added event to local disk: 🌺  ${locationEvent.toJson()}  🌺 ');

    _geofenceStreamController.sink.add(geofence);
  }

  void _onActivityChanged(Activity prevActivity, Activity currActivity) async {
    pp('\n\n$mm _onActivityChanged: 🌀 🌀 🌀 previous Activity:  😎 ${prevActivity.toMap()}  😎 ');
    pp('$mm _onActivityChanged: 🌀 🌀 🌀 current Activity:  😎 ${currActivity.toMap()} 😎 \n');

    var pos = await Geolocator.getCurrentPosition();
    var event = ActivityEvent(
        eventId: DateTime.now().toIso8601String(),
        latitude: pos.latitude,
        date: DateTime.now().toIso8601String(),
        longitude: pos.longitude,
        type: currActivity.type.toString(),
        confidence: currActivity.confidence.toString());

    if (currActivity.confidence == ActivityConfidence.HIGH) {
      pp('$mm _onActivityChanged: 🌀 🌀 🌀 saving activity event on disk ... 😎 😎 ${event.toJson()} 😎 😎');
      localDB.addActivity(event);
    }

    _activityStreamController.sink.add(event);
  }

  void _onError(dynamic error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      pp('👿 👿 👿 👿 Undefined error: $error');
      return;
    }

    pp('$mm 👿 👿 👿 👿 👿 👿 👿 👿 👿 👿 👿 👿 👿 ErrorCode: $errorCode 👿 👿 👿 ');
    throw Exception('$errorCode');
  }

  List<Geofence> geofences = [];
  List<GeofenceLocation> locations = [];

  Future buildGeofences({required List<GeofenceLocation> locations}) async {
    pp('$mm buildGeofences: requesting permission to build 🛎 ${locations.length} geofences ...');
    this.locations = locations;

    int cnt = 0;
    locations.forEach((element) async {
      if (element.name != null) {
        var fence = Geofence(
            id: element.name!,
            latitude: element.latitude!,
            longitude: element.longitude!,
            data: element.toJson(),
            radius: [
              // GeofenceRadius(id: 'radius_100m', length: 100),
              GeofenceRadius(id: 'radius_200m', length: 200),
              // GeofenceRadius(id: 'radius_300m', length: 300)
            ]);

        geofences.add(fence);
        cnt++;
        pp('\t$mm buildGeofences: ✅ #$cnt Geofence created : ${fence.id}');
      }
    });

    geofenceService.addGeofenceList(geofences);
    geofenceService.addGeofenceStatusChangedListener(
        (geofence, geofenceRadius, geofenceStatus, position) =>
            _onGeofenceStatusChanged(
                geofence, geofenceRadius, geofenceStatus, position));

    pp('$mm buildGeofences:  ✅  ✅  ✅  🌺 ${geofences.length} geofences  '
        '🌺 added to service 🛎 ');

    pp('$mm buildGeofences:  ✅  ✅  ✅  starting the GeofenceService with 🛎 🛎 ${geofences.length} geofences 🛎 🛎 ');
    geofenceService.start(geofences).catchError(_onError);
    return geofences;
  }
}
