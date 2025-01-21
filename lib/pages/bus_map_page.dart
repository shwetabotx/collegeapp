// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:latlong2/latlong.dart';

// class BusMapPage extends StatefulWidget {
//   const BusMapPage({super.key});

//   @override
//   BusMapPageState createState() => BusMapPageState();
// }

// class BusMapPageState extends State<BusMapPage> {
//   List<Marker> _busMarkers = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchBusLocations();
//     _simulateBusLocationUpdates(); // For testing, remove this in production
//   }

//   /// Fetch bus locations from Firestore and update markers in real-time.
//   void _fetchBusLocations() {
//     FirebaseFirestore.instance
//         .collection('buses')
//         .snapshots()
//         .listen((snapshot) {
//       List<Marker> updatedMarkers = [];
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final latitude = data['latitude'];
//         final longitude = data['longitude'];
//         final routeName = data['routeName'];

//         if (latitude != null && longitude != null) {
//           updatedMarkers.add(
//             Marker(
//               point: LatLng(latitude, longitude),
//               width: 50.0,
//               height: 50.0,
//               builder: (ctx) => Column(
//                 children: [
//                   Icon(Icons.directions_bus, color: Colors.red, size: 30),
//                   Container(
//                     color: Colors.white,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                     child: Text(
//                       routeName ?? 'Unknown',
//                       style: const TextStyle(fontSize: 10, color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       }

//       setState(() {
//         _busMarkers = updatedMarkers;
//       });
//     });
//   }

//   /// Simulate bus location updates in Firestore for testing purposes.
//   void _simulateBusLocationUpdates() {
//     Timer.periodic(const Duration(seconds: 5), (timer) {
//       FirebaseFirestore.instance.collection('buses').get().then((snapshot) {
//         for (var doc in snapshot.docs) {
//           final latitude = doc.data()['latitude'];
//           final longitude = doc.data()['longitude'];

//           // Generate new random nearby coordinates
//           final random = Random();
//           final newLatitude = latitude + (random.nextDouble() - 0.5) * 0.01;
//           final newLongitude = longitude + (random.nextDouble() - 0.5) * 0.01;

//           // Update Firestore with new location
//           FirebaseFirestore.instance.collection('buses').doc(doc.id).update({
//             'latitude': newLatitude,
//             'longitude': newLongitude,
//           });
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("College Bus Tracker")),
//       body: FlutterMap(
//         options: MapOptions(
//           center: LatLng(12.9716, 77.5946), // Default map center
//           zoom: 13.0, // Default zoom level
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayer(markers: _busMarkers),
//         ],
//       ),
//     );
//   }
// }
