import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAssignmentPage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const TeacherAssignmentPage(
      {super.key,
      required this.teacherId,
      required String currentClassId,
      required String major,
      required String year,
      required this.classId});

  @override
  TeacherAssignmentPageState createState() => TeacherAssignmentPageState();
}

class TeacherAssignmentPageState extends State<TeacherAssignmentPage> {
  List<String> classIds = [];
  String? selectedClassId;

  @override
  void initState() {
    super.initState();
    _fetchClassIds();
  }

  Future<void> _fetchClassIds() async {
    final classesSnapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      classIds = classesSnapshot.docs.map((doc) => doc.id).toList();
      if (classIds.isNotEmpty) {
        selectedClassId = classIds.first;
      }
    });
  }

  void _showAddAssignmentDialog() {
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
                    dueDateController.text.isNotEmpty &&
                    selectedClassId != null) {
                  await FirebaseFirestore.instance
                      .collection('classes')
                      .doc(selectedClassId)
                      .collection('assignments')
                      .add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'dueDate': dueDateController.text,
                    'teacherId': widget.teacherId,
                    'timestamp': Timestamp.now(),
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

  Widget _buildAssignmentsList() {
    if (selectedClassId == null) {
      return const Center(child: Text("No class selected."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(selectedClassId)
          .collection('assignments')
          .orderBy('timestamp', descending: true)
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
            return Card(
              child: ListTile(
                title: Text(assignment['title']),
                subtitle: Text(
                  "${assignment['description']}\nDue: ${assignment['dueDate']}",
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Assignments"),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherHomePage(
                  teacherId: widget.teacherId,
                  classId: widget.classId,
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
              "Select Class",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            classIds.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    value: selectedClassId,
                    isExpanded: true,
                    items: classIds.map((classId) {
                      return DropdownMenuItem(
                        value: classId,
                        child: Text(classId),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value;
                      });
                    },
                  ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showAddAssignmentDialog,
              child: const Text("Add Assignment"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Assignments for Selected Class",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAssignmentsList(),
          ],
        ),
      ),
    );
  }
}
