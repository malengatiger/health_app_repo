class GeofenceLocation {
  String? locationId, name;
  double? latitude, longitude;

  GeofenceLocation({this.locationId, this.name, this.latitude, this.longitude});

  GeofenceLocation.fromJson(Map data) {
    this.locationId = data['locationId'];
    this.name = data['name'];

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
        'latitude': latitude,
        'longitude': longitude,
      };
}

class GeofenceLocationEvent {
  String? eventId;
  String? date;
  GeofenceLocation? geofenceLocation;
  bool? entered, dwelled, exited;

  GeofenceLocationEvent(
      {required this.eventId,
      required this.geofenceLocation,
      required this.date,
      required this.entered,
      required this.dwelled,
      required this.exited});

  GeofenceLocationEvent.fromJson(Map data) {
    this.eventId = data['eventId'];
    this.date = data['date'];
    this.entered = data['entered'];
    this.dwelled = data['dwelled'];
    this.exited = data['exited'];

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
        'geofenceLocation':
            geofenceLocation == null ? null : geofenceLocation!.toJson()
      };
}
