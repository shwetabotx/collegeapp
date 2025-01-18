import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAnnouncementPage extends StatelessWidget {
  const TeacherAnnouncementPage(
      {super.key, required this.teacherId, required this.classId});
  final String teacherId;
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcement 📢"),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherHomePage(
                  teacherId: teacherId,
                  classId: classId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Announcements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddAnnouncementDialog(context);
              },
              child: const Text("Add Announcement"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your Announcements",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAnnouncementsList(),
          ],
        ),
      ),
    );
  }

  // Function to display the "Add Announcement" dialog
  void _showAddAnnouncementDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Announcement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('announcements')
                      .add({
                    'title': titleController.text,
                    'content': contentController.text,
                    'timestamp': Timestamp.now(),
                    'teacherId': teacherId, // Current teacher ID
                    'classId': classId, // Teacher's class ID
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Announcement added!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Function to display the list of announcements
  Widget _buildAnnouncementsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('teacherId',
              isEqualTo: teacherId) // Filter by current teacher ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No announcements available."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final announcement = snapshot.data!.docs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(announcement['title']),
                subtitle: Text(announcement['content']),
                trailing: Text(
                  (announcement['timestamp'] as Timestamp).toDate().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
