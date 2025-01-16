import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentTimeTablePage extends StatelessWidget {
  const StudentTimeTablePage({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Timetable 🗓️"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Your Timetable",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimeTableTable(),
          ],
        ),
      ),
    );
  }

  // Function to display the timetable grouped by day
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
          scrollDirection: Axis.vertical, // Make it vertically scrollable
          child: Table(
            border: TableBorder.all(),
            children: [
              const TableRow(
                children: [
                  TableCell(child: Text('Day', textAlign: TextAlign.center)),
                  TableCell(
                      child: Text('Subject', textAlign: TextAlign.center)),
                  TableCell(child: Text('Time', textAlign: TextAlign.center)),
                ],
              ),
              // Loop through the timetable data for each day
              for (var day in timetableData.keys)
                TableRow(
                  children: [
                    TableCell(child: Text(day, textAlign: TextAlign.center)),
                    TableCell(
                      child: Column(
                        children: timetableData[day]!
                            .map((entry) => Text(entry['subject'] ?? '',
                                textAlign: TextAlign.center))
                            .toList(),
                      ),
                    ),
                    TableCell(
                      child: Column(
                        children: timetableData[day]!
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
      },
    );
  }

  // Function to group timetable entries by day
  Map<String, List<Map<String, String>>> _groupEntriesByDay(
      List<QueryDocumentSnapshot> docs) {
    Map<String, List<Map<String, String>>> groupedByDay = {};

    for (var doc in docs) {
      var timetable = doc.data() as Map<String, dynamic>;
      var entries = timetable['entries'] as List<dynamic>?;

      if (entries != null) {
        for (var entry in entries) {
          var subject = entry['subject'];
          var time = entry['time'];
          var day = entry['day'];

          if (!groupedByDay.containsKey(day)) {
            groupedByDay[day] = [];
          }

          groupedByDay[day]!.add({
            'subject': subject,
            'time': time,
          });
        }
      }
    }

    return groupedByDay;
  }
}
