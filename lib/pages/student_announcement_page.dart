import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class StudentAnnouncementsPage extends StatelessWidget {
  final String classId; // Pass the student's class ID
  final Logger _logger = Logger(); // Initialize the logger

  StudentAnnouncementsPage(
      {required this.classId, super.key, required String studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements 📢"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .where('classId', isEqualTo: classId) // Filter by class ID
            .snapshots()
            .handleError((error) {
          // Log errors using logger
          _logger.e("Error in announcements stream", error: error);
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while waiting for data
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Log and display an error message
            _logger.e("StreamBuilder error", error: snapshot.error);
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Log if no announcements are available
            _logger.w("No announcements found for classId: $classId");
            return const Center(child: Text("No announcements available 📰"));
          }

          // Retrieve the list of announcements from the snapshot
          final announcements = snapshot.data!.docs;

          // Sort the announcements manually by timestamp (descending)
          announcements.sort((a, b) {
            final timestampA = (a['timestamp'] as Timestamp).toDate();
            final timestampB = (b['timestamp'] as Timestamp).toDate();
            return timestampB.compareTo(timestampA);
          });

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return _buildAnimatedCard(announcement, index);
            },
          );
        },
      ),
    );
  }

  // Function to build animated card with emoji and smooth animation
  Widget _buildAnimatedCard(DocumentSnapshot announcement, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500 + (index * 100)),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.announcement,
                  color: Colors.blue,
                  size: 40,
                ),
                title: Text(
                  "${announcement['title'] ?? 'No Title'} ", // Added emoji
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${announcement['content'] ?? 'No Content'} \n🗓️ ${(announcement['timestamp'] as Timestamp).toDate().toString()}", // Added emoji
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
