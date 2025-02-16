import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/teacher_home_page.dart';

class TeacherAnnouncementPage extends StatefulWidget {
  const TeacherAnnouncementPage(
      {super.key, required this.teacherId, required this.classId});
  final String teacherId;
  final String classId;

  @override
  TeacherAnnouncementPageState createState() => TeacherAnnouncementPageState();
}

class TeacherAnnouncementPageState extends State<TeacherAnnouncementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements 📢"),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            // Check if the widget is still mounted before navigating
            if (mounted) {
              // Use Future.delayed to delay the navigation
              await Future.delayed(Duration(milliseconds: 100), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherHomePage(
                        teacherId: widget.teacherId,
                        classId: widget.classId,
                      ),
                    ),
                  );
                }
              });
            }
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
              child: const Text("Add Announcement 📄"),
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
                    'teacherId': widget.teacherId, // Current teacher ID
                    'classId': widget.classId, // Teacher's class ID
                  });
                  Navigator.pop(context);
                  // Ensure widget is still part of the widget tree before showing SnackBar
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Announcement added! ✅")),
                    );
                  }
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
              isEqualTo: widget.teacherId) // Filter by current teacher ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No announcements available. 📭"));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final announcement = snapshot.data!.docs[index];
            return _buildAnimatedCard(announcement, index);
          },
        );
      },
    );
  }

  // Function to build animated card with delete option
  Widget _buildAnimatedCard(DocumentSnapshot announcement, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 100)),
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
                leading: const Icon(Icons.announcement,
                    color: Colors.green, size: 40),
                title: Text(
                  announcement['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${announcement['content'] ?? 'No Content'}\n🗓️ Posted on: ${(announcement['timestamp'] as Timestamp).toDate().toString()}",
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Delete the announcement
                    await FirebaseFirestore.instance
                        .collection('announcements')
                        .doc(announcement.id)
                        .delete();

                    // Ensure the widget is still part of the widget tree
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
