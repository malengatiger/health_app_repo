import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app_repo/util/functions.dart';
import 'package:health_app_repo/util/functions_and_shit.dart';

class HealthPage extends StatefulWidget {
  @override
  _HealthPageState createState() => _HealthPageState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED
}

class _HealthPageState extends State<HealthPage> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  static const mm = '🌸 🌸 🌸 🌸 🌸  HealthPage: ';
  var totalSteps = 0, totalDistance = 0;
  String? startDate, endDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    pp('$mm Get everything HEALTH from the last 7 days ................');
    startDate = DateTime.now().subtract(Duration(days: 7)).toIso8601String();
    endDate = DateTime.now().toIso8601String();

    HealthFactory health = HealthFactory();
    pp('$mm Define the HEALTH types to get');

    List<HealthDataType> types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    setState(() => _state = AppState.FETCHING_DATA);

    pp('$mm You MUST request health.requestAuthorization access to the data types before reading them');
    bool accessWasGranted = await health.requestAuthorization(types);
    pp('$mm accessWasGranted: 🛎 🛎 🛎 $accessWasGranted 🛎 🛎 🛎');
    int steps = 0;

    if (accessWasGranted) {
      try {
        pp('$mm  Fetch new data ...');
        _healthDataList = await health.getHealthDataFromTypes(
            DateTime.parse(startDate!), DateTime.parse(endDate!), types);
      } catch (e) {
        pp("$mm 👿 👿 👿 👿 👿 👿 👿 Caught exception in getHealthDataFromTypes:  👿 $e");
      }
//HealthDataPoint - value: 130.0, unit: HealthDataUnit.COUNT,
// dateFrom: 2020-11-07 18:17:26.412,
// dateTo: 2020-11-07 18:24:37.551,
// dataType: HealthDataType.STEPS, platform: PlatformType.IOS

      pp('$mm  Filter out duplicates');
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      List<HealthDataPoint> stepsDataPoints = [];
      List<HealthDataPoint> walkingDataPoints = [];
      pp('$mm  Aggregate STEPS and DISTANCE_WALKING_RUNNING dataPoints');
      _healthDataList.forEach((x) {
        if (x.type == HealthDataType.STEPS) {
          stepsDataPoints.add(x);
        }
        if (x.type == HealthDataType.DISTANCE_WALKING_RUNNING) {
          walkingDataPoints.add(x);
        }
        if (x.type == HealthDataType.BLOOD_GLUCOSE) {
          pp("\n\n$mm 🛎 🛎 🛎 🛎 🛎 🛎 🛎 🛎 🛎 🛎 🛎 🛎 🛎 "
              "HealthDataType.BLOOD_GLUCOSE ... Yebo!!!! 🛎 🛎 🛎 🛎 🛎\n\n");
        }
      });

      stepsDataPoints.forEach((dataPoint) {
        totalSteps += dataPoint.value.round();
      });
      walkingDataPoints.forEach((dataPoint) {
        totalDistance += dataPoint.value.round();
      });

      pp("$mm Total Steps Accumulated: 🛎 $totalSteps 🛎");
      pp("$mm Total Distance Walked/Ran: 🛎 $totalDistance metres 🛎");

      pp('$mm  Update the UI to display the results');
      setState(() {
        _state =
            _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      pp(" 👿  👿  👿  👿  👿 health.requestAuthorization: 👿 Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {
    return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          return Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.directions_walk),
              title: Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Text(
                        "${p.typeString}",
                        style: Styles.blueBoldSmall,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Row(
                    children: [
                      Text("${p.value.round()}"),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
              // trailing: Text('${p.unitString}'),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 60, child: Text('From')),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                          '${getFormattedDateShortWithTime(p.dateFrom.toIso8601String(), context)}'),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(width: 60, child: Text('To')),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                          '${getFormattedDateShortWithTime(p.dateTo.toIso8601String(), context)}'),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Text('Press the download button to fetch data');
  }

  Widget _authorizationNotGranted() {
    return Text('''Authorization not given.
        For Android please check your OAUTH2 client ID is correct in Google Developer Console.
         For iOS check your permissions in Apple Health.''');
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA)
      return _contentFetchingData();
    else if (_state == AppState.AUTH_NOT_GRANTED)
      return _authorizationNotGranted();

    return _contentNotFetched();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              _fetchData();
            },
          )
        ],
        bottom: PreferredSize(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Total Steps',
                        style: Styles.whiteSmall,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${getFormattedNumber(totalSteps, context)}',
                      style: Styles.whiteBoldLarge,
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Total Distance (Metres)',
                        style: Styles.whiteSmall,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${getFormattedNumber(totalDistance, context)}',
                      style: Styles.whiteBoldLarge,
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                SizedBox(
                  height: 20,
                ),
                startDate == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Start Date',
                                style: Styles.whiteSmall,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              '${getFormattedDateShortWithTime(startDate!, context)}',
                              style: Styles.whiteBoldSmall,
                            )
                          ],
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                endDate == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: Text(
                                  'End Date',
                                  style: Styles.whiteSmall,
                                )),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              '${getFormattedDateShortWithTime(endDate!, context)}',
                              style: Styles.whiteBoldSmall,
                            )
                          ],
                        ),
                      ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
            preferredSize: Size.fromHeight(300)),
      ),
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: _content(),
        ),
      ),
    );
  }
}
