import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherTimeTablePage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const TeacherTimeTablePage(
      {super.key, required this.teacherId, required this.classId});

  @override
  TeacherTimeTablePageState createState() => TeacherTimeTablePageState();
}

class TeacherTimeTablePageState extends State<TeacherTimeTablePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, List<Map<String, String>>> timetableEntries = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
  };

  final _subjectController = TextEditingController();
  final _timeController = TextEditingController();
  String selectedDay = 'Monday';

  void addEntry() {
    if (_subjectController.text.isNotEmpty && _timeController.text.isNotEmpty) {
      setState(() {
        timetableEntries[selectedDay]!.add({
          'subject': _subjectController.text.trim(),
          'time': _timeController.text.trim(),
        });
      });
      _subjectController.clear();
      _timeController.clear();
    }
  }

  void submitTimetable() async {
    try {
      final timetableRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('teachers')
          .doc(widget.teacherId)
          .collection('timetables')
          .doc('timetable_data');

      await timetableRef.set({
        'entries': timetableEntries,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        timetableEntries.forEach((key, value) {
          value.clear();
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetable submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting timetable: $e')),
      );
    }
  }

  Stream<DocumentSnapshot> getTimetableStream() {
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('teachers')
        .doc(widget.teacherId)
        .collection('timetables')
        .doc('timetable_data')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Timetable'),
        backgroundColor: Colors.deepPurple,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // Logout logic
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TeacherHomePage(
                        teacherId: 'teacherId',
                        classId: 'classId',
                      )),
            );
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form for adding timetable entries
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Day selection dropdown with a better design
                      DropdownButtonFormField<String>(
                        value: selectedDay,
                        decoration: InputDecoration(
                          labelText: 'Select Day',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedDay = value!;
                          });
                        },
                        items: timetableEntries.keys.map((String day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Input fields for subject and time
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: addEntry,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add Entry'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: submitTimetable,
                        icon: const Icon(Icons.save, size: 20),
                        label: const Text('Submit Timetable'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Display added timetable entries in a table format
            const Text(
              'Your Timetable Entries:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (timetableEntries[selectedDay]!.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Day')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Time')),
                    ],
                    rows: timetableEntries[selectedDay]!
                        .map(
                          (entry) => DataRow(
                            cells: [
                              DataCell(Text(selectedDay)),
                              DataCell(Text(entry['subject'] ?? '')),
                              DataCell(Text(entry['time'] ?? '')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Display existing timetable from Firestore as columns for each day
            StreamBuilder<DocumentSnapshot>(
              stream: getTimetableStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                      child: Text('No timetable entries available.'));
                }

                final timetableData = snapshot.data!;
                final entries =
                    (timetableData['entries'] as Map<String, dynamic>)
                        .map((day, value) {
                  return MapEntry(
                    day,
                    List<Map<String, dynamic>>.from(
                        value.map((item) => item as Map<String, dynamic>)),
                  );
                });

                // Create a list of rows where each row corresponds to a set of subject-time pairs
                List<List<String>> combinedEntries = [];
                List<String> days = [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday'
                ];

                // Ensure that we have entries for all 6 days
                for (String day in days) {
                  if (!entries.containsKey(day)) {
                    entries[day] = [];
                  }
                }

                // Find the maximum number of rows (subjects) across all days
                int maxRows = entries.values
                    .map((list) => list.length)
                    .reduce((a, b) => a > b ? a : b);

                // Create the data table with the combined entries
                for (int i = 0; i < maxRows; i++) {
                  List<String> row = [];
                  for (String day in days) {
                    if (i < entries[day]!.length) {
                      row.add(
                          "${entries[day]![i]['subject'] ?? ''}\n${entries[day]![i]['time'] ?? ''}");
                    } else {
                      row.add(""); // Empty if no entry for that day
                    }
                  }
                  combinedEntries.add(row);
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      columns: days
                          .map((day) => DataColumn(label: Text(day)))
                          .toList(),
                      rows: combinedEntries
                          .map(
                            (row) => DataRow(
                              cells: row.map((entry) {
                                return DataCell(Text(entry));
                              }).toList(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
