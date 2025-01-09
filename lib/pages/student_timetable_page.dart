import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentTimeTablePage extends StatelessWidget {
  const StudentTimeTablePage(
      {super.key, required this.classId, required String studentId});
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Timetable"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Your Timetable ->",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimeTableTable(),
          ],
        ),
      ),
    );
  }

  // Function to display the timetable in a table format with days as columns
  Widget _buildTimeTableTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('timetables')
          .where('classId', isEqualTo: classId) // Filter by classId
          .snapshots(),
      builder: (context, snapshot) {
        // Error handling and loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No timetable entries available."));
        }

        // Process timetable entries and group by day
        var timetableData = _groupEntriesByDay(snapshot.data!.docs);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Make it horizontally scrollable
          child: Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FixedColumnWidth(120),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(120),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(120),
              6: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                children: [
                  const TableCell(
                      child: Text('Subject', textAlign: TextAlign.center)),
                  const TableCell(
                      child: Text('Monday', textAlign: TextAlign.center)),
                  const TableCell(
                      child: Text('Tuesday', textAlign: TextAlign.center)),
                  const TableCell(
                      child: Text('Wednesday', textAlign: TextAlign.center)),
                  const TableCell(
                      child: Text('Thursday', textAlign: TextAlign.center)),
                  const TableCell(
                      child: Text('Friday', textAlign: TextAlign.center)),
                  const TableCell(
                      child: Text('Saturday', textAlign: TextAlign.center)),
                ],
              ),
              // Loop through the timetable data for each subject
              for (var entry in timetableData.entries)
                TableRow(
                  children: [
                    TableCell(
                        child: Text(entry.key, textAlign: TextAlign.center)),
                    for (var day in [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday'
                    ])
                      TableCell(
                          child: Text(entry.value[day] ?? '',
                              textAlign: TextAlign.center)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // Function to group timetable entries by day
  Map<String, Map<String, String>> _groupEntriesByDay(
      List<QueryDocumentSnapshot> docs) {
    Map<String, Map<String, String>> groupedByDay = {};

    for (var doc in docs) {
      var timetable = doc.data() as Map<String, dynamic>;
      var entries = timetable['entries'] as List<dynamic>?;

      if (entries != null) {
        for (var entry in entries) {
          var subject = entry['subject'];
          var time = entry['time'];
          var day = entry['day'];

          if (!groupedByDay.containsKey(subject)) {
            groupedByDay[subject] = {
              'Monday': '',
              'Tuesday': '',
              'Wednesday': '',
              'Thursday': '',
              'Friday': '',
              'Saturday': '',
            };
          }

          // Add the subject and time to the corresponding day
          if (groupedByDay[subject] != null) {
            groupedByDay[subject]?[day] = '$time';
          }
        }
      }
    }

    return groupedByDay;
  }
}
