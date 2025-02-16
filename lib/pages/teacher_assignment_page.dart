import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class TeacherAssignmentPage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const TeacherAssignmentPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  TeacherAssignmentPageState createState() => TeacherAssignmentPageState();
}

class TeacherAssignmentPageState extends State<TeacherAssignmentPage> {
  List<String> classIds = [];
  String? selectedClassId;
  DateTime? selectedDueDate; // Store the selected date

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

  // Function to show date picker
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDueDate) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  void _showAddAssignmentDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectDueDate(context),
                child: Text(selectedDueDate == null
                    ? "Select Due Date"
                    : "Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDueDate!)}"),
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
                    selectedDueDate != null &&
                    selectedClassId != null) {
                  await FirebaseFirestore.instance
                      .collection('classes')
                      .doc(selectedClassId)
                      .collection('assignments')
                      .add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'dueDate': Timestamp.fromDate(
                        selectedDueDate!), // Store as Timestamp
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
            final assignmentId = assignment.id;

            // Convert Timestamp to readable Date
            Timestamp dueDateTimestamp = assignment['dueDate'];
            String formattedDueDate =
                DateFormat('yyyy-MM-dd').format(dueDateTimestamp.toDate());

            return Card(
              child: ListTile(
                title: Text(assignment['title']),
                subtitle: Text(
                  "${assignment['description']}\nDue: $formattedDueDate",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteAssignment(assignmentId);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to delete an assignment
  Future<void> _deleteAssignment(String assignmentId) async {
    if (selectedClassId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(selectedClassId)
          .collection('assignments')
          .doc(assignmentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting assignment: $e")),
      );
    }
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
              "Assignments",
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
