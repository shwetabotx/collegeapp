import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherHomeworkPage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const TeacherHomeworkPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  TeacherHomeworkPageState createState() => TeacherHomeworkPageState();
}

class TeacherHomeworkPageState extends State<TeacherHomeworkPage> {
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

  void _showAddHomeworkDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Homework"),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDueDate == null
                              ? "Select Due Date"
                              : "Due Date: ${selectedDueDate!.toLocal()}"
                                  .split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedDueDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
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
                          .collection('homework')
                          .add({
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'dueDate': selectedDueDate!.toIso8601String(),
                        'teacherId': widget.teacherId,
                        'timestamp': Timestamp.now(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Homework added!")),
                      );
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHomeworkList() {
    if (selectedClassId == null) {
      return const Center(child: Text("No class selected."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(selectedClassId)
          .collection('homework')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No homework available."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final homework = snapshot.data!.docs[index];
            return Card(
              child: ListTile(
                title: Text(homework['title']),
                subtitle: Text(
                  "${homework['description']}\nDue: ${homework['dueDate'].toString().split('T')[0]}",
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
        title: const Text("Teacher Homework"),
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
              onPressed: _showAddHomeworkDialog,
              child: const Text("Add Homework"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Homework for Selected Class",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildHomeworkList(),
          ],
        ),
      ),
    );
  }
}
