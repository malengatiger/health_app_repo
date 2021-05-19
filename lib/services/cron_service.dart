import 'package:cron/cron.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:health_app_repo/data_models/my_location.dart';
import 'package:health_app_repo/services/hive_db.dart';
import 'package:health_app_repo/util/functions.dart';
import 'package:health_app_repo/util/functions_and_shit.dart';

final CronService cronService = CronService.instance;

/*
For example, a Cron time string of 0 10 15 * * executes a command on the 15th of each month at 10:00 A.M. UTC.

 30 * * * *	Execute a command at 30 minutes past the hour, every hour.
 ## 0 13 * * 1	Execute a command at 1:00 p.m. UTC every Monday.
 star/5 * * * *	Execute a command every five minutes.
star/2 * * *	Execute a command every second hour, on the hour.

	Descriptor	Acceptable values
1	Minute	0 to 59, or * (no specific value)
2	Hour	0 to 23, or * for any value. All times UTC.
3	Day of the month	1 to 31, or * (no specific value)
4	Month	1 to 12, or * (no specific value)
5	Day of the week	0 to 7 (0 and 7 both represent Sunday), or * (no specific value)

 */
class CronService {
  static const mm = '🕖 🕗 🕘 🕙 🕚 CronService: 🌀 ';
  final cron = Cron();
  static final CronService instance = CronService._privateConstructor();

  CronService._privateConstructor() {
    pp('$mm ... CronService._privateConstructor has been initialized : 🌺 🌺 🌺 🌺 🌺 '
        '${DateTime.now().toIso8601String()} 🌺');
    // _init();
  }
  void _init() async {
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      pp('$mm doin da boogie every minute   1️⃣  ${DateTime.now().toIso8601String()}  1️⃣ ');
    });
    cron.schedule(Schedule.parse('8-11 * * * *'), () async {
      pp('$mm doin da boogie between every 8 and 11 minutes');
    });
  }

  bool started = false;
  void startMyLocationScheduler(
      int minutes, Function(String) onSchedule) async {
    var cronString = '*/$minutes  * * * *';
    pp('$mm startMyLocationScheduler called with $minutes minutes as the parameter: '
        '${DateTime.now().toIso8601String()}');
    if (!started) {
      await _schedule(
          cronString: cronString, minutes: minutes, onSchedule: onSchedule);
    } else {
      pp('$mm location scheduler is already started 🔵 🔵 ... no need to start fresh? 🔵 🔵');
    }
  }

  Position? previousPosition;
  Future _schedule(
      {required String cronString,
      required int minutes,
      required Function(String) onSchedule}) async {
    var scheduledTask = cron.schedule(Schedule.parse(cronString), () async {
      pp('$mm startMyLocationScheduler: 🔵 doin da boogie every  🅿️ $minutes  🅿️ minutes ${DateTime.now().toIso8601String()}');
      pp('$mm startMyLocationScheduler: 🔵 getting my current location  🌍 🌍 🌍 🌍 ....');
      try {
        var pos = await Geolocator.getCurrentPosition();
        if (previousPosition == null) {
          await addLocation(pos);
          onSchedule(
              'Location added at: ${getFormattedDateHourMinSec(DateTime.now().toIso8601String())}');
        } else {
          var distance = Geolocator.distanceBetween(previousPosition!.latitude,
              previousPosition!.longitude, pos.latitude, pos.longitude);
          if (distance > 50) {
            await addLocation(pos);
            onSchedule(
                'Location added at: ${getFormattedDateHourMinSec(DateTime.now().toIso8601String())}');
          } else {
            pp('$mm We are less than 👿 50 👿 metres from previous location:  😡 $distance  😡 metres}');
          }
        }
        previousPosition = pos;
      } catch (e) {
        pp('$mm 👿👿👿 we have a problem here, Boss! 👿👿👿 $e');
      }
    });
    pp('$mm scheduledTask.schedule.minutes: ${scheduledTask.schedule.minutes}');
    started = true;
  }

  Future<String> addLocation(Position pos) async {
    var date = DateTime.now().toIso8601String();
    var myLoc = MyLocation(
        myLocationId: date,
        latitude: pos.latitude,
        date: date,
        longitude: pos.longitude);

    await localDB.addMyLocation(myLoc);
    pp('$mm startMyLocationScheduler: 🔵 MyLocation has been added at $date  🌍 🌍 🌍 🌍  ');
    return date;
  }
}
