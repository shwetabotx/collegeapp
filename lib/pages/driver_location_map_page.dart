import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverLocationMapPage extends StatefulWidget {
  const DriverLocationMapPage({super.key, required this.driverId});
  final String driverId;

  @override
  DriverLocationMapPageState createState() => DriverLocationMapPageState();
}

class DriverLocationMapPageState extends State<DriverLocationMapPage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  Position? _currentPosition;
  bool _isLocationFetched = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchDriverLocation();
  }

  Future<void> _fetchDriverLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Request location permission
    PermissionStatus permission = await Permission.location.request();
    if (permission.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is denied.')),
      );
      return;
    }
    if (permission.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is permanently denied.')),
      );
      openAppSettings();
      return;
    }

    // Fetch the current location of the driver
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );

    setState(() {
      _currentPosition = position;
      _isLocationFetched = true;
    });

    // Update the driver's location in Firebase Realtime Database
    _database.ref().child('drivers_location').child(widget.driverId).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Location Map'),
      ),
      body: _isLocationFetched
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      builder: (context) => Icon(
                        Icons.directions_bus,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
