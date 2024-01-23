import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  String currentLocation = 'Current Location of the User';
  late String lat;
  late String long;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google maps'),
          backgroundColor: Colors.cyan[300],
        ),
        body: Column(
          children: [
            Text(
              currentLocation,
              style: TextStyle(fontSize: 20),
            ),
            TextButton(
              onPressed: () {
                _getCurrentLocation().then((value) => {
                      lat = "${value.latitude.toStringAsFixed(6)}",
                      long = "${value.longitude.toStringAsFixed(6)}",
                      setState(() {
                        currentLocation = 'Latitude: $lat,Longitude: $long';
                      })
                    });
                print("Current location: "+currentLocation);
                _liveLocation();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.cyan[300]!,
                ),
              ),
              child: const Text('Get Current Location'),
            ),
            TextButton(
                onPressed: () {
                  _openMap(lat, long);
                },
                child: const Text('Open Google Map')),
          ],
        ));
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

  Future<void> _openMap(String lat, String long) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$long';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      await launchUrl(uri);
    } catch (e) {
      throw 'Could not launch $googleMapsUrl';
    }
  }

}
