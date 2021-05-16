import 'package:flutter/material.dart';
import 'package:health_app_repo/util/functions.dart';

import 'geofence_location.dart';

class EventsPage extends StatelessWidget {
  final List<GeofenceLocationEvent> events;

  const EventsPage({Key? key, required this.events}) : super(key: key);

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
                        '${events.length}',
                        style: Styles.blackBoldMedium,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
              preferredSize: Size.fromHeight(40)),
        ),
        backgroundColor: Colors.brown[100],
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events.elementAt(index);
                    return Card(
                      elevation: 4,
                      child: ListTile(
                        leading: event.entered!
                            ? Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.teal,
                              )
                            : Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: Colors.pink,
                              ),
                        title: Text(event.geofenceLocation!.name!),
                        subtitle: Row(
                          children: [
                            event.entered!
                                ? Text('Entered', style: Styles.tealBoldSmall)
                                : Text(
                                    'Exited',
                                    style: Styles.pinkBoldSmall,
                                  ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                                '${getFormattedDateShortWithTime(event.date!, context)}'),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}
