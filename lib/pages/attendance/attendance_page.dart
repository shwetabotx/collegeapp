import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AttendancePage extends StatefulWidget {
  final String major;
  final String year;

  const AttendancePage({super.key, required this.major, required this.year});

  @override
  // ignore: library_private_types_in_public_api
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Logger logger = Logger(); // Logger for debugging
  late final String classId;

  // Map to track attendance status for each student
  final Map<String, String> attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    classId = _generateClassId(widget.major, widget.year);
  }

  // Helper to generate classId based on major and year
  String _generateClassId(String major, String year) {
    final majorCode = {
          'Arts Major': 'BA',
          'Commerce Major': 'BCOM',
          'Computer Science Major': 'BCA',
        }[major] ??
        '';

    final yearCode = {
          'First Year': 'FY',
          'Second Year': 'SY',
          'Third Year': 'TY',
          'Fourth Year': 'LY',
        }[year] ??
        '';

    return '$yearCode$majorCode';
  }

  Future<void> _markAttendance(
      String studentId, String classId, String status) async {
    try {
      final date = DateTime.now();
      final attendanceDate = '${date.year}-${date.month}-${date.day}';

      final studentDoc = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('students')
          .doc(studentId);

      // Update attendance for the selected date
      await studentDoc.collection('attendance').doc(attendanceDate).set({
        'date': attendanceDate,
        'status': status,
      });

      if (mounted) {
        setState(() {
          attendanceStatus[studentId] = status; // Update attendance status
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marked as $status')),
        );
      }

      logger.i("Marked $status for student $studentId in class $classId");
    } catch (e) {
      logger.e("Error marking attendance: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark attendance')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.major} - ${widget.year} Attendance"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Mark Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .doc(classId)
                    .collection('students')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    logger.e("Error fetching students: ${snapshot.error}");
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No students found.'));
                  }

                  final students = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student =
                          students[index].data() as Map<String, dynamic>;
                      final studentId = students[index].id;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Roll Number: ${student['rollNumber'] ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  _buildAttendanceButton(
                                      studentId, classId, 'present'),
                                  const SizedBox(height: 8),
                                  _buildAttendanceButton(
                                      studentId, classId, 'absent'),
                                ],
                              ),
                            ],
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

  Widget _buildAttendanceButton(
      String studentId, String classId, String status) {
    // Get the button's background color based on the current status
    final bool isSelected = attendanceStatus[studentId] == status;
    final Color buttonColor = isSelected
        ? (status == 'present' ? Colors.green : Colors.red)
        : Colors.white;

    return ElevatedButton(
      onPressed: () {
        final currentStatus = attendanceStatus[studentId];
        // Toggle if clicked again
        if (currentStatus == status) {
          _markAttendance(studentId, classId, ''); // Clear the status
        } else {
          _markAttendance(studentId, classId, status); // Update the status
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
