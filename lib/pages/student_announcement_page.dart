import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class StudentAnnouncementsPage extends StatelessWidget {
  final String classId; // Pass the student's class ID
  final Logger _logger = Logger(); // Initialize the logger

  StudentAnnouncementsPage({required this.classId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .where('classId', isEqualTo: classId) // Filter by class ID
            .orderBy('timestamp', descending: true) // Sort by timestamp
            .snapshots()
            .handleError((error) {
          // Log errors using logger
          _logger.e("Error in announcements stream", error);
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while waiting for data
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Log and display an error message
            _logger.e("StreamBuilder error", snapshot.error);
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Log if no announcements are available
            _logger.w("No announcements found for classId: $classId");
            return const Center(child: Text("No announcements available."));
          }

          // Retrieve the list of announcements from the snapshot
          final announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    announcement['title'] ?? "Untitled",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    announcement['content'] ?? "No content available.",
                  ),
                  trailing: Text(
                    (announcement['timestamp'] as Timestamp)
                        .toDate()
                        .toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
