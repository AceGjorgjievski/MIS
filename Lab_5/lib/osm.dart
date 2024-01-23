import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:exam_schedule_google_maps/google_maps.dart';

import 'exam_schedule.dart';
import 'exam_schedule_calendar.dart';
import 'login_screen.dart';

import 'package:geocoding/geocoding.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class OSM extends StatefulWidget {
  final List<ExamSchedule> examSchedules;

  const OSM({super.key, required this.examSchedules});

  List<ExamSchedule> get getExamSchedules => examSchedules;

  @override
  State<OSM> createState() => _OSMState();
}

class _OSMState extends State<OSM> {
  String currentLocation = 'Current Location of the User';
  late String lat;
  late String long;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoggedIn = false;

  List<Marker> markers = [];
  MapController mapController = MapController();
  Marker? myLocation;

  List<LatLng> routePoints = [];
  bool isVisible = false;

  // PolylineLayerOptions? polyLineLayer;

  @override
  void initState() {
    super.initState();
    _updateAuthState();
  }

  void _updateAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OSM'),
        backgroundColor: Colors.cyan[300],
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Flexible(
                child: FlutterMap(
                  mapController: mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(42.00453, 21.40806),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'mk.ukim.finki.mis2023',
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(
                              Uri.parse('https://openstreetmap.org/copyright')),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: markers,
                    ),
                    MarkerLayer(
                      markers: widget.examSchedules.map((examSchedule) {
                        return Marker(
                          point: LatLng(
                            examSchedule.location.locationLatitude.toDouble(),
                            examSchedule.location.locationLongitude.toDouble(),
                          ),
                          width: 1000,
                          height: 1000,
                          child: GestureDetector(
                            onTap: () {
                              _showExamDialog(examSchedule);
                            },
                            child: const Icon(
                              Icons.pin_drop,
                              color: Colors.cyan,
                              size: 50,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    PolylineLayer(
                      polylineCulling: false,
                      polylines: [
                        Polyline(
                            points: routePoints,
                            color: Colors.blue,
                            strokeWidth: 9),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: TextButton(
        child: const Text('Add your location'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.cyan[300]!,
          ),
        ),
        onPressed: () async {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            _showLocationServiceDisabledMessage();
            return;
          }
          if (!isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
            return;
          }

          await _getCurrentLocation().then((value) => {
                lat = "${value.latitude.toStringAsFixed(6)}",
                long = "${value.longitude.toStringAsFixed(6)}",
                // lat = "41.99646", //Skopje lat
                // long = "21.43141", //Skopje long
                // lat = "52.520008", //Berlin lat
                // long = "13.404954", //Berlin long

                setState(() {
                  currentLocation = 'Latitude: $lat,Longitude: $long';
                  print("Current location: " + currentLocation);
                })
              });
          _liveLocation();
          _showDropPinOfMyLocation(lat, long);
        },
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission are permanently denied, we cannot request permission.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        currentLocation = 'Latitude: $lat,\nLongitude: $long';
      });
    });
  }

  void _showDropPinOfMyLocation(String lat, String long) {
    if (lat != null && lat.isNotEmpty && long != null && long.isNotEmpty) {
      myLocation = Marker(
        point: LatLng(double.parse(lat), double.parse(long)),
        width: 1000,
        height: 1000,
        child: GestureDetector(
          onTap: () {
            _showMyLocationDialog(lat, long);
          },
          child: const Icon(
            Icons.pin_drop,
            color: Colors.red,
            size: 50,
          ),
        ),
      );
      setState(() {
        markers = List.from(markers)..add(myLocation!);
      });
      mapController.move(LatLng(double.parse(lat), double.parse(long)), 13);
    }
  }

  void _showMyLocationDialog(String lat, String long) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('My Location'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Latitude: $lat'),
              Text('Longitude: $long'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  markers = [];
                  routePoints = [];
                  myLocation = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Remove Location'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showExamDialog(ExamSchedule examSchedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(examSchedule.subjectName ?? 'No Subject Name'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${examSchedule.formattedDateTime}'),
              Text('Location: ${examSchedule.location.locationName}'),
              if (myLocation != null)
                TextButton(
                  onPressed: () {
                    _showNavigation(
                      examSchedule.location.locationLatitude.toString(),
                      examSchedule.location.locationLongitude.toString(),
                      myLocation!.point.latitude,
                      myLocation!.point.longitude,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.red[300]!,
                  )),
                  child: const Text(
                    'Navigation',
                  ),
                )
              else
                Text(
                  'Please add your location first\nif you want to navigate here.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          actions: [
            if (!isLoggedIn)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.cyan[300]!,
                )),
                child: const Text('Show exam schedule'),
              ),
            if (isLoggedIn)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExamScheduleCalendar(
                              examSchedules: widget.getExamSchedules,
                            )),
                  );
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.cyan[300]!,
                )),
                child: const Text('Show exam schedule'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showNavigation(
      String latEnd, String longEnd, double latStart, double longStart) async {
    var url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$longStart,$latStart;$longEnd,$latEnd?steps=true&annotations=true&geometries=geojson&overview=full');
    var response = await http.get(url);
    print(response.body);
    setState(() {
      routePoints = [];
      var ruter =
          jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
      for (int i = 0; i < ruter.length; i++) {
        var reep = ruter[i].toString();
        reep = reep.replaceAll("[", "");
        reep = reep.replaceAll("]", "");
        var lat1 = reep.split(',');
        var long1 = reep.split(",");
        routePoints.add(LatLng(double.parse(lat1[1]), double.parse(long1[0])));
      }

      LatLngBounds bounds = LatLngBounds.fromPoints(routePoints);
      mapController.fitCamera(CameraFit.bounds(bounds: bounds));

      isVisible = !isVisible;
      print(routePoints);
    });
  }

  void _showLocationServiceDisabledMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Please enable location services to use this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
