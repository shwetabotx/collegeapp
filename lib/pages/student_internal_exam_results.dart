import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/student_home_page.dart';
import 'package:flutter/material.dart';

class StudentInternalExamResultsPage extends StatefulWidget {
  const StudentInternalExamResultsPage(
      {super.key, required this.studentId, required this.classId});
  final String studentId;
  final String classId;

  @override
  StudentInternalExamResultsPageState createState() =>
      StudentInternalExamResultsPageState();
}

class StudentInternalExamResultsPageState
    extends State<StudentInternalExamResultsPage> {
  Map<String, dynamic>? studentMarks;

  // Fetch student marks from Firestore
  Future<void> _fetchMarks() async {
    try {
      // Get marks from the 'marks' collection for the student
      var marksSnapshot = await FirebaseFirestore.instance
          .collection('marks') // Root collection for marks
          .doc(widget.studentId) // Document for the current student
          .get();

      if (marksSnapshot.exists) {
        setState(() {
          studentMarks = marksSnapshot.data();
        });
      } else {
        setState(() {
          studentMarks = null; // No marks available
        });
      }
    } catch (e) {
      debugPrint("Error fetching marks: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Internal Exam Results"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  classId: widget.classId,
                  studentId: widget.studentId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentMarks == null
            ? Center(
                child: Text(
                  'No results available for this student yet.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : studentMarks!.isEmpty
                ? Center(
                    child: Text(
                      'No marks have been uploaded for this student.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: studentMarks!.length,
                    itemBuilder: (context, index) {
                      String subject = studentMarks!.keys.elementAt(index);
                      dynamic marks = studentMarks![subject];
                      return ListTile(
                        title: Text(subject),
                        subtitle: Text('Marks: $marks'),
                      );
                    },
                  ),
      ),
    );
  }
}
