class GeofenceLocation {
  String? locationId, name;
  double? latitude, longitude;
  double? radius;

  GeofenceLocation(
      {this.locationId, this.name, this.latitude, this.longitude, this.radius});

  GeofenceLocation.fromJson(Map data) {
    this.locationId = data['locationId'];
    this.name = data['name'];
    this.radius = data['radius'];

    if (data['latitude'] is int) {
      this.latitude = data['latitude'] * 1.0;
    } else {
      this.latitude = data['latitude'];
    }
    if (data['longitude'] is int) {
      this.longitude = data['longitude'] * 1.0;
    } else {
      this.longitude = data['longitude'];
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'locationId': locationId,
        'name': name,
        'radius': radius,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class GeofenceLocationEvent {
  String? eventId;
  String? date;
  GeofenceLocation? geofenceLocation;
  bool? entered, dwelled, exited;
  double? radius;

  GeofenceLocationEvent(
      {required this.eventId,
      required this.geofenceLocation,
      required this.date,
      required this.entered,
      required this.dwelled,
      required this.exited,
      this.radius});

  GeofenceLocationEvent.fromJson(Map data) {
    this.eventId = data['eventId'];
    this.date = data['date'];
    this.entered = data['entered'];
    this.dwelled = data['dwelled'];
    this.exited = data['exited'];
    this.radius = data['radius'];

    if (data['geofenceLocation'] != null) {
      this.geofenceLocation =
          GeofenceLocation.fromJson(data['geofenceLocation']);
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eventId': eventId,
        'date': date,
        'entered': entered,
        'dwelled': dwelled,
        'exited': exited,
        'radius': radius,
        'geofenceLocation':
            geofenceLocation == null ? null : geofenceLocation!.toJson()
      };
}

class ActivityEvent {
  String? eventId;
  String? date, type, confidence;
  double? latitude, longitude;

  ActivityEvent(
      {required this.eventId,
      required this.latitude,
      required this.date,
      required this.longitude,
      required this.type,
      required this.confidence});

  ActivityEvent.fromJson(Map data) {
    this.eventId = data['eventId'];
    this.date = data['date'];
    this.latitude = data['latitude'];
    this.longitude = data['longitude'];
    this.type = data['type'];
    this.confidence = data['confidence'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eventId': eventId,
        'date': date,
        'latitude': latitude,
        'longitude': longitude,
        'confidence': confidence,
        'type': type,
      };
}
