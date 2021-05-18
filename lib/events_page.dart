import 'package:flutter/material.dart';
import 'package:health_app_repo/services/hive_db.dart';
import 'package:health_app_repo/util/functions.dart';

import 'functions_and_shit.dart';
import 'geofence_location.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<GeofenceLocationEvent> _geofenceEvents = [];
  static const mm = '🥬 🥬 🥬 🥬 🥬  EventsPage: ';
  bool busy = false;
  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  Future _getEvents() async {
    pp('$mm getGeofenceEvents: getting events from local disk ...');
    setState(() {
      busy = true;
    });
    _geofenceEvents = await localDB.getGeofenceEvents();
    _geofenceEvents.sort((a, b) => b.date!.compareTo(a.date!));
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Geofence Events',
            style: Styles.blackBoldSmall,
          ),
          backgroundColor: Colors.brown[100],
          elevation: 0,
          bottom: PreferredSize(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Number of Events'),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        '${_geofenceEvents.length}',
                        style: Styles.blackBoldMedium,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  )
                ],
              ),
              preferredSize: Size.fromHeight(40)),
        ),
        backgroundColor: Colors.brown[100],
        body: busy
            ? Center(
                child: Container(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.pink,
                  ),
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                        itemCount: _geofenceEvents.length,
                        itemBuilder: (context, index) {
                          var event = _geofenceEvents.elementAt(index);
                          return EventCard(event: event);
                        }),
                  ),
                ],
              ));
  }
}

class EventCard extends StatelessWidget {
  final GeofenceLocationEvent event;
  const EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    var icon = Icon(Icons.arrow_forward);
    if (event.dwelled!) {
      icon = Icon(Icons.directions_walk);
    }
    if (event.exited!) {
      icon = Icon(Icons.arrow_back);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(Icons.waves_rounded),
                ),
                Flexible(
                  child: Text(
                    event.geofenceLocation!.name!,
                    style: Styles.blackBoldSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  event.entered!
                      ? Row(
                          children: [
                            Text('Entered', style: Styles.tealBoldSmall),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(Icons.directions_walk),
                          ],
                        )
                      : event.dwelled!
                          ? Row(
                              children: [
                                Text('Dwelled', style: Styles.blueBoldSmall),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(Icons.pan_tool_rounded),
                              ],
                            )
                          : Row(
                              children: [
                                Text(
                                  'Exited',
                                  style: Styles.pinkBoldSmall,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(Icons.arrow_back),
                              ],
                            ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    '${getFormattedDateShortWithTime(event.date!, context)}',
                    style: Styles.blackBoldSmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 12,
            )
          ],
        ),
      ),
    );
  }
}
