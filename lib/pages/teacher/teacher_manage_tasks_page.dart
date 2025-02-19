import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/teacher/teacher_home_page.dart';
import 'package:flutter/material.dart';

class TeacherManageTasksPage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const TeacherManageTasksPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  TeacherManageTasksPageState createState() => TeacherManageTasksPageState();
}

class TeacherManageTasksPageState extends State<TeacherManageTasksPage> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();

  void _addTask() async {
    if (_taskTitleController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('teachers')
          .doc(widget.teacherId)
          .collection('tasks')
          .add({
        'title': _taskTitleController.text,
        'description': _taskDescController.text,
        'completed': false, // Initially, the task is not completed
        'timestamp': Timestamp.now(),
      });

      _taskTitleController.clear();
      _taskDescController.clear();
    }
  }

  void _deleteTask(String taskId) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('teachers')
        .doc(widget.teacherId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  void _toggleTaskCompletion(String taskId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('teachers')
        .doc(widget.teacherId)
        .collection('tasks')
        .doc(taskId)
        .update({'completed': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tasks"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(labelText: "Task Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskDescController,
              decoration: const InputDecoration(labelText: "Task Description"),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text("Add Task"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Task List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .doc(widget.classId)
                    .collection('teachers')
                    .doc(widget.teacherId)
                    .collection('tasks')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No tasks available."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data!.docs[index];
                      bool isCompleted = task['completed'];

                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: isCompleted,
                            onChanged: (newValue) {
                              _toggleTaskCompletion(task.id, isCompleted);
                            },
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(task['description']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
