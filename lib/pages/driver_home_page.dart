import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key, required this.driverId});
  final String driverId;

  @override
  DriverHomePageState createState() => DriverHomePageState();
}

class DriverHomePageState extends State<DriverHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Position? _currentPosition;
  bool _isSharing = false;

  @override
  void dispose() {
    super.dispose();
    _stopSharingLocation();
  }

  Future<void> _startSharingLocation() async {
    // Check location services and permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    // Stream location updates and send to Firestore
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });

      // Send GPS data to Firestore with the actual driver ID
      _firestore.collection('drivers_location').doc(widget.driverId).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  void _stopSharingLocation() {
    setState(() {
      _isSharing = false;
    });
    // Optionally remove the driver's location from Firestore
    _firestore.collection('drivers_location').doc(widget.driverId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard'),
        actions: [
          if (_isSharing)
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _stopSharingLocation,
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentPosition == null
                ? Text('Waiting for GPS...')
                : Text(
                    'Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSharing ? null : _startSharingLocation,
              child: Text('Start Sharing Location'),
            ),
          ],
        ),
      ),
    );
  }
}
