import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';

class TeacherTestMarksPage extends StatefulWidget {
  const TeacherTestMarksPage(
      {super.key, required this.teacherId, required this.classId});
  final String teacherId;
  final String classId;

  @override
  TeacherTestMarksPageState createState() => TeacherTestMarksPageState();
}

class TeacherTestMarksPageState extends State<TeacherTestMarksPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStudent;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  List<Map<String, dynamic>> subjectMarksList = []; // Store subjects and marks
  List<Map<String, dynamic>> students = []; // List of students with ID and name

  // Fetch students from Firestore
  Future<void> _fetchStudents() async {
    try {
      var studentSnapshot = await FirebaseFirestore.instance
          .collection('classes') // Collection name: classes
          .doc(widget.classId) // Use classId for the relevant class
          .collection('students') // Fetch from 'students' subcollection
          .get();

      setState(() {
        students = studentSnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }
  }

  // Add subject and marks to the list
  void _addSubjectMarks() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        subjectMarksList.add({
          'subject': _subjectController.text,
          'marks': int.parse(_marksController.text),
        });

        // Clear input fields after adding the subject and marks
        _subjectController.clear();
        _marksController.clear();
      });
    }
  }

  // Save all marks in a single document for the selected student
  Future<void> _saveMarks() async {
    if (_selectedStudent == null || subjectMarksList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a student and add marks')),
      );
      return;
    }

    try {
      // Prepare the marks data to store in Firestore
      Map<String, dynamic> marksData = {
        'teacherId': widget.teacherId,
        'timestamp': FieldValue.serverTimestamp(),
        'marks': subjectMarksList,
      };

      // Save to Firestore under the specified student in the 'marks' subcollection
      await FirebaseFirestore.instance
          .collection('classes') // Root collection
          .doc(widget.classId) // Class document
          .collection('students') // Students subcollection
          .doc(_selectedStudent) // Specific student document
          .collection('marks') // Marks subcollection
          .doc('internal_exam') // Example: 'internal_exam' as a single document
          .set(marksData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Marks for ${_selectedStudent!} saved successfully')),
      );

      // Clear the input fields and subjectMarksList after saving
      setState(() {
        subjectMarksList.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving marks: $e')),
      );
      debugPrint("Error saving marks: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch students when the page loads
    _fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Test Marks"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Logout logic
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TeacherHomePage(
                        teacherId: widget.teacherId, // Pass teacherId
                        classId: widget.classId,
                      )),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown to select student
              students.isEmpty
                  ? const CircularProgressIndicator() // Show loading if students are being fetched
                  : DropdownButtonFormField<String>(
                      value: _selectedStudent,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStudent = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a student';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student['id'] as String,
                          child: Text(student['name'] as String),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 16),

              // Text field for Subject Name
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Enter Subject Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Text field for Marks
              TextFormField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Marks',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter marks';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) < 0 || int.parse(value) > 100) {
                    return 'Marks should be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Button to add subject and marks
              ElevatedButton(
                onPressed: _addSubjectMarks,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Add Subject and Marks'),
              ),
              const SizedBox(height: 16),

              // Display the entered subjects and marks
              Expanded(
                child: ListView.builder(
                  itemCount: subjectMarksList.length,
                  itemBuilder: (context, index) {
                    var entry = subjectMarksList[index];
                    return ListTile(
                      title: Text(entry['subject']),
                      subtitle: Text('Marks: ${entry['marks']}'),
                    );
                  },
                ),
              ),

              // Submit Button to save all marks
              ElevatedButton(
                onPressed: _saveMarks,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Submit All Marks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
