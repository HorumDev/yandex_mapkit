import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:yandex_mapkit_example/examples/widgets/control_button.dart';
import 'package:yandex_mapkit_example/examples/widgets/map_page.dart';

class PedestrianPage extends MapPage {
  const PedestrianPage() : super('Pedestrian example');

  @override
  Widget build(BuildContext context) {
    return _Example();
  }
}

class _Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<_Example> {
  late final List<MapObject> mapObjects = [
    startPlacemark,
    stopByPlacemark,
    endPlacemark
  ];
  final Placemark startPlacemark = Placemark(
    mapId: MapObjectId('start_placemark'),
    point: Point(latitude: 55.7558, longitude: 37.6173),
    icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('lib/assets/route_start.png'),
            scale: 0.3
        )
    ),
  );
  final Placemark stopByPlacemark = Placemark(
    mapId: MapObjectId('stop_by_placemark'),
    point: Point(latitude: 45.0360, longitude: 38.9746),
    icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('lib/assets/route_stop_by.png'),
            scale: 0.3
        )
    ),
  );
  final Placemark endPlacemark = Placemark(
      mapId: MapObjectId('end_placemark'),
      point: Point(latitude: 46.4814, longitude: 40.0721),
      icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('lib/assets/route_end.png'),
              scale: 0.3
          )
      )
  );

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: YandexMap(
                  mapObjects: mapObjects
              )
          ),
          const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        ControlButton(
                          onPressed: _requestRoutes,
                          title: 'Build route',
                        ),
                      ]
                  )
              )
          )
        ]
    );
  }

  Future<void> _requestRoutes() async {
    print('Points: ${startPlacemark.point},${stopByPlacemark.point},${endPlacemark.point}');

    var resultWithSession = YandexPedestrian.requestRoutes(
        points: [
          RequestPoint(point: startPlacemark.point, requestPointType: RequestPointType.wayPoint),
          RequestPoint(point: stopByPlacemark.point, requestPointType: RequestPointType.viaPoint),
          RequestPoint(point: endPlacemark.point, requestPointType: RequestPointType.wayPoint),
        ],
        // drivingOptions: DrivingOptions(
        //     initialAzimuth: 0,
        //     routesCount: 5,
        //     avoidTolls: true
        // )
    );

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => _SessionPage(
                startPlacemark,
                endPlacemark,
                resultWithSession.session,
                resultWithSession.result
            )
        )
    );
  }
}


class _SessionPage extends StatefulWidget {
  final Future<PedestrianSessionResult> result;
  final PedestrianSession session;
  final Placemark startPlacemark;
  final Placemark endPlacemark;

  _SessionPage(this.startPlacemark, this.endPlacemark, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  late final List<MapObject> mapObjects = [
    widget.startPlacemark,
    widget.endPlacemark
  ];

  final List<PedestrianSessionResult> results = [];
  bool _progress = true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();

    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Pedestrian ${widget.session.id}')),
        body: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        YandexMap(
                            mapObjects: mapObjects
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                              children: <Widget>[
                                SizedBox(
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        !_progress ? Container() : TextButton.icon(
                                            icon: const CircularProgressIndicator(),
                                            label: const Text('Cancel'),
                                            onPressed: _cancel
                                        )
                                      ],
                                    )
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: _getList(),
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                          )
                      )
                  )
                ]
            )
        )
    );
  }

  List<Widget> _getList() {
    final list = <Widget>[];

    if (results.isEmpty) {
      list.add((Text('Nothing found')));
    }

    for (var r in results) {
      list.add(Container(height: 20));

      r.routes!.asMap().forEach((i, route) {
        list.add(Text('Route $i: ${route.metadata.weight.time.text}'));
      });

      list.add(Container(height: 20));
    }

    return list;
  }

  Future<void> _cancel() async {
    await widget.session.cancel();

    setState(() { _progress = false; });
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(PedestrianSessionResult result) async {
    setState(() { _progress = false; });

    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    setState(() { results.add(result); });
    setState(() {
      result.routes!.asMap().forEach((i, route) {
        mapObjects.add(Polyline(
          mapId: MapObjectId('route_${i}_polyline'),
          coordinates: route.geometry,
          strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          strokeWidth: 3,
        ));
      });
    });
  }
}