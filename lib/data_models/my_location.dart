class MyLocation {
  String? myLocationId;
  String? date;
  double? latitude, longitude;

  MyLocation(
      {required this.myLocationId,
      required this.latitude,
      required this.date,
      required this.longitude});

  MyLocation.fromJson(Map data) {
    this.myLocationId = data['myLocationId'];
    this.date = data['date'];
    this.latitude = data['latitude'];
    this.longitude = data['longitude'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'myLocationId': myLocationId,
        'date': date,
        'latitude': latitude,
        'longitude': longitude,
      };
}
