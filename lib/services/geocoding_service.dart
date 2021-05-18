import 'package:geocoding/geocoding.dart';
import 'package:health_app_repo/functions_and_shit.dart';

class GeocodingService {
  static const mm = 'Ⓜ️ Ⓜ️ Ⓜ️ Ⓜ️ Ⓜ️ GeocodingService: Ⓜ️';

  static Future<Placemark?>? getPlacemark({
    required double latitude,
    required double longitude,
  }) async {
    pp('$mm getPlacemark using geocoding .... ');
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    placemarks.forEach((element) {
      pp('$mm PLACEMARK: ♦️ ♦️ ♦️ ${element.toJson()} ♦️');
    });

    if (placemarks.isNotEmpty) {
      pp('$mm getPlacemark using geocoding .... ${placemarks.elementAt(0).toJson()}');
      return placemarks.elementAt(0);
    } else {
      return null;
    }
  }
}
