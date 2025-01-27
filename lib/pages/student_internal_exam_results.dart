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
  List<Map<String, dynamic>> studentMarks = [];

  // Fetch student marks from Firestore
  Future<void> _fetchMarks() async {
    try {
      var marksSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('students')
          .doc(widget.studentId)
          .collection('marks')
          .doc('internal_exam')
          .get();

      if (marksSnapshot.exists) {
        var data = marksSnapshot.data();
        if (data != null && data.containsKey('marks')) {
          setState(() {
            studentMarks = List<Map<String, dynamic>>.from(data['marks']);
          });
        }
      } else {
        setState(() {
          studentMarks = [];
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
        title: const Text(
          "Internal Exam Results",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  classId: widget.classId,
                  studentId: widget.studentId,
                  driverId: '',
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentMarks.isEmpty
            ? Center(
                child: Text(
                  'No results available for this student yet.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Internal Exam Results:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: studentMarks.length,
                      itemBuilder: (context, index) {
                        var entry = studentMarks[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                entry['subject'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              entry['subject'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Marks: ${entry['marks']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
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
