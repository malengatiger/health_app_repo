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
