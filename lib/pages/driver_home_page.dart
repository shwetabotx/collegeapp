import 'package:collegeapp/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void dispose() {
    _stopSharingLocation(); // Ensure location sharing stops
    super.dispose();
  }

  Future<void> _startSharingLocation() async {
    // Check location services and permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSharing = true;
      });
    }

    // Stream location updates and send to Firestore
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      // Send GPS data to Firestore
      _firestore.collection('drivers_location').doc(widget.driverId).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _stopSharingLocation() async {
    // Cancel the stream subscription
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    if (mounted) {
      setState(() {
        _isSharing = false;
      });
    }

    // Stop Geolocator service explicitly
    try {
      await Geolocator.getLastKnownPosition(); // Attempt to stop service
    } catch (e) {
      debugPrint('Error stopping Geolocator: $e');
    }

    // Optionally remove the driver's location from Firestore
    // await _firestore
    //     .collection('drivers_location')
    //     .doc(widget.driverId)
    //     .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          if (_isSharing)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopSharingLocation,
            ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentPosition == null
                ? const Text('Waiting for GPS...')
                : Text(
                    'Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSharing ? null : _startSharingLocation,
              child: const Text('Start Sharing Location'),
            ),
          ],
        ),
      ),
    );
  }
}
