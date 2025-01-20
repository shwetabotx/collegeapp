import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherHomeworkPage extends StatelessWidget {
  final String teacherId;
  final String classId;

  const TeacherHomeworkPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homework 📝"),
        backgroundColor: Colors.deepPurple,
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
              "Submit Homework 📝",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddHomeworkDialog(context);
              },
              child: const Text("Add Homework ➕"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Assigned Homework 📑",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAssignedHomeworkList(),
          ],
        ),
      ),
    );
  }

  // Function to display the "Add Homework" dialog
  void _showAddHomeworkDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Homework 📚"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              TextField(
                controller: dueDateController,
                decoration:
                    const InputDecoration(labelText: "Due Date (YYYY-MM-DD)"),
                keyboardType: TextInputType.datetime,
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
                    descriptionController.text.isNotEmpty &&
                    dueDateController.text.isNotEmpty) {
                  // Save homework to Firestore
                  await FirebaseFirestore.instance.collection('homework').add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'dueDate': dueDateController.text,
                    'timestamp': Timestamp.now(),
                    'teacherId': teacherId,
                    'classId': classId,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Homework added! 🎉")),
                  );
                }
              },
              child: const Text("Add Homework"),
            ),
          ],
        );
      },
    );
  }

  // Function to display the list of assigned homework with animations and emojis
  Widget _buildAssignedHomeworkList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('homework')
          .where('teacherId', isEqualTo: teacherId)
          .where('classId', isEqualTo: classId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No homework assigned yet. 🥳"));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final homework = snapshot.data!.docs[index];
            return _buildAnimatedCard(homework, index);
          },
        );
      },
    );
  }

  // Function to build animated card with delete button
  Widget _buildAnimatedCard(DocumentSnapshot homework, int index) {
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
                leading: const Icon(Icons.book, color: Colors.blue, size: 40),
                title: Text(
                  homework['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${homework['description'] ?? 'No Description'}\n🗓️ Due Date: ${homework['dueDate'] ?? 'No Due Date'}",
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Delete homework from Firestore
                    await FirebaseFirestore.instance
                        .collection('homework')
                        .doc(homework.id)
                        .delete();
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
