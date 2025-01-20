import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/teacher_home_page.dart';

class TeacherAssignmentPage extends StatelessWidget {
  final String teacherId;
  final String classId;

  const TeacherAssignmentPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments 📚"),
        backgroundColor: Colors.deepOrange,
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
              "Submit Assignment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddAssignmentDialog(context);
              },
              child: const Text("Add Assignment"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Your Assignments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAssignmentsList(),
          ],
        ),
      ),
    );
  }

  // Function to display the "Add Assignment" dialog
  void _showAddAssignmentDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Assignment"),
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
                  // Save assignment to Firestore
                  await FirebaseFirestore.instance
                      .collection('assignments')
                      .add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'dueDate': dueDateController.text,
                    'timestamp': Timestamp.now(),
                    'teacherId': teacherId, // Current teacher ID
                    'classId': classId, // Class ID
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Assignment added!")),
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

  // Function to display the list of assignments
  Widget _buildAssignmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('assignments')
          .where('teacherId',
              isEqualTo: teacherId) // Filter by current teacher ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No assignments available."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final assignment = snapshot.data!.docs[index];
            return _buildAnimatedCard(assignment, index);
          },
        );
      },
    );
  }

  // Function to build animated card with delete option
  Widget _buildAnimatedCard(DocumentSnapshot assignment, int index) {
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
                title: Text(assignment['title']),
                subtitle: Text(
                  "${assignment['description']}\nDue: ${assignment['dueDate']}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (assignment['timestamp'] as Timestamp)
                          .toDate()
                          .toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Delete the assignment
                        await FirebaseFirestore.instance
                            .collection('assignments')
                            .doc(assignment.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Assignment deleted! ❌")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
