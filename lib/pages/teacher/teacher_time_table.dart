import 'package:collegeapp/pages/teacher/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherTimeTablePage extends StatefulWidget {
  const TeacherTimeTablePage(
      {super.key, required this.teacherId, required this.classId});
  final String teacherId;
  final String classId;

  @override
  TeacherTimeTablePageState createState() => TeacherTimeTablePageState();
}

class TeacherTimeTablePageState extends State<TeacherTimeTablePage> {
  // Controllers for subject, time, and day input
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  // List to store timetable entries
  List<Map<String, String>> timetableEntries = [];
  List<Map<String, String>> submittedTimetableEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSubmittedTimetable();
  }

  // Function to fetch and load the existing timetable from Firestore
  void _loadSubmittedTimetable() async {
    try {
      var timetableRef = FirebaseFirestore.instance.collection('timetables');

      var querySnapshot = await timetableRef
          .where('teacherId', isEqualTo: widget.teacherId)
          .where('classId', isEqualTo: widget.classId)
          .get();

      List<Map<String, String>> fetchedTimetableEntries = [];
      for (var doc in querySnapshot.docs) {
        var entries = doc['entries'] as List<dynamic>;
        for (var entry in entries) {
          fetchedTimetableEntries.add({
            'subject': entry['subject'],
            'time': entry['time'],
            'day': entry['day'],
          });
        }
      }

      setState(() {
        submittedTimetableEntries = fetchedTimetableEntries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading timetable: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time-Table 🗓️"),
        backgroundColor: Colors.green,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Timetable",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddTimeTableDialog(context);
              },
              child: const Text("Add Timetable Entry"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitTimetable,
              child: const Text("Submit Timetable"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your Timetable Entries",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildGroupedTimeTableTable(submittedTimetableEntries),
            const SizedBox(height: 16),
            const Text(
              "New Timetable Entries",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildGroupedTimeTableTable(timetableEntries),
          ],
        ),
      ),
    );
  }

  // Function to display the "Add Timetable" dialog
  void _showAddTimeTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Timetable Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: "Time"),
              ),
              TextField(
                controller: _dayController,
                decoration:
                    const InputDecoration(labelText: "Day (e.g., Monday)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_subjectController.text.isNotEmpty &&
                    _timeController.text.isNotEmpty &&
                    _dayController.text.isNotEmpty) {
                  // Add timetable entry to the list
                  setState(() {
                    timetableEntries.add({
                      'subject': _subjectController.text,
                      'time': _timeController.text,
                      'day': _dayController.text,
                    });
                  });

                  // Clear input fields
                  _subjectController.clear();
                  _timeController.clear();
                  _dayController.clear();

                  // Close the dialog
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Timetable entry added!")),
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

  // Function to submit all timetable entries to Firestore
  void _submitTimetable() async {
    if (timetableEntries.isNotEmpty) {
      try {
        // Reference to the collection where the timetable is stored
        var timetableRef = FirebaseFirestore.instance.collection('timetables');

        // First, delete any existing timetable for the teacher and class
        var querySnapshot = await timetableRef
            .where('teacherId', isEqualTo: widget.teacherId)
            .where('classId', isEqualTo: widget.classId)
            .get();

        // Delete the existing timetable if found
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }

        // Create a new document for the timetable and add the entries
        var timetableDocRef = timetableRef.doc();

        // Add timetable entries as an array to the new document
        await timetableDocRef.set({
          'teacherId': widget.teacherId,
          'classId': widget.classId,
          'entries': timetableEntries,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Timetable submitted successfully!")),
        );

        // Clear the list after submission
        setState(() {
          timetableEntries.clear();
        });

        // Reload the submitted timetable data
        _loadSubmittedTimetable();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting timetable: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No timetable entries to submit")),
      );
    }
  }

  // Function to group timetable entries by day
  Map<String, List<Map<String, String>>> _groupByDay(
      List<Map<String, String>> entries) {
    Map<String, List<Map<String, String>>> groupedByDay = {};

    for (var entry in entries) {
      String day = entry['day']!;
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [];
      }
      groupedByDay[day]!.add({
        'subject': entry['subject']!,
        'time': entry['time']!,
      });
    }
    return groupedByDay;
  }

  // Function to build a grouped timetable table
  Widget _buildGroupedTimeTableTable(List<Map<String, String>> entries) {
    Map<String, List<Map<String, String>>> groupedEntries =
        _groupByDay(entries);

    if (groupedEntries.isEmpty) {
      return const Center(child: Text("No timetable entries available."));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Enable vertical scrolling
      child: Table(
        border: TableBorder.all(),
        children: [
          const TableRow(
            children: [
              TableCell(child: Text('Day', textAlign: TextAlign.center)),
              TableCell(child: Text('Subject', textAlign: TextAlign.center)),
              TableCell(child: Text('Time', textAlign: TextAlign.center)),
            ],
          ),
          for (var day in groupedEntries.keys)
            TableRow(
              children: [
                TableCell(child: Text(day, textAlign: TextAlign.center)),
                TableCell(
                  child: Column(
                    children: groupedEntries[day]!
                        .map((entry) => Text(entry['subject'] ?? '',
                            textAlign: TextAlign.center))
                        .toList(),
                  ),
                ),
                TableCell(
                  child: Column(
                    children: groupedEntries[day]!
                        .map((entry) => Text(entry['time'] ?? '',
                            textAlign: TextAlign.center))
                        .toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
