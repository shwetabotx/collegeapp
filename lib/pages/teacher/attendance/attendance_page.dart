import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AttendancePage extends StatefulWidget {
  final String major;
  final String year;

  const AttendancePage({super.key, required this.major, required this.year});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  final Logger logger = Logger();
  late final String classId;
  final Map<String, String> attendanceStatus = {};
  final TextEditingController presentController = TextEditingController();
  final TextEditingController absentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    classId = _generateClassId(widget.major, widget.year);
  }

  String _generateClassId(String major, String year) {
    final majorCode = {
          'Arts Major': 'BA',
          'Commerce Major': 'BCOM',
          'Computer Science Major': 'BS',
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

      await studentDoc.collection('attendance').doc(attendanceDate).set({
        'date': attendanceDate,
        'status': status,
      });

      if (mounted) {
        setState(() {
          attendanceStatus[studentId] = status;
        });
      }

      logger.i("Marked $status for student $studentId in class $classId");
    } catch (e) {
      logger.e("Error marking attendance: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark attendance')),
        );
      }
    }
  }

  Future<void> _updateAttendanceByRollNumbers(
      String rollNumbers, String status) async {
    try {
      List<String> rollNumberList =
          rollNumbers.split(',').map((e) => e.trim()).toList();

      // Fetch all students in the class
      final studentsQuery = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('students')
          .get();

      Set<String> allRollNumbers =
          studentsQuery.docs.map((doc) => doc['rollNumber'].toString()).toSet();

      Set<String> inputRollNumbers = rollNumberList.toSet();

      // Determine the opposite status
      String oppositeStatus = status == 'present' ? 'absent' : 'present';
      Set<String> remainingRollNumbers =
          allRollNumbers.difference(inputRollNumbers);

      // Prepare batch write
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final date = DateTime.now();
      final attendanceDate = '${date.year}-${date.month}-${date.day}';

      // Mark entered roll numbers with the given status
      for (var student in studentsQuery.docs) {
        if (inputRollNumbers.contains(student['rollNumber'].toString())) {
          DocumentReference attendanceDoc =
              student.reference.collection('attendance').doc(attendanceDate);
          batch.set(attendanceDoc, {'date': attendanceDate, 'status': status});
        }
      }

      // Mark remaining roll numbers with the opposite status
      for (var student in studentsQuery.docs) {
        if (remainingRollNumbers.contains(student['rollNumber'].toString())) {
          DocumentReference attendanceDoc =
              student.reference.collection('attendance').doc(attendanceDate);
          batch.set(attendanceDoc,
              {'date': attendanceDate, 'status': oppositeStatus});
        }
      }

      // Commit batch write to Firestore in one operation
      await batch.commit();

      if (mounted) {
        setState(() {
          for (var student in studentsQuery.docs) {
            String studentId = student.id;
            if (inputRollNumbers.contains(student['rollNumber'].toString())) {
              attendanceStatus[studentId] = status;
            } else {
              attendanceStatus[studentId] = oppositeStatus;
            }
          }
        });
      }

      logger.i("Successfully updated attendance in batch.");
    } catch (e) {
      logger.e("Error updating attendance by roll numbers: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark attendance')),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: presentController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Roll Number for Present',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _updateAttendanceByRollNumbers(
                        presentController.text, 'present');
                    presentController.clear();
                  },
                  child: const Text('Mark Present'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: absentController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Roll Number for Absent',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _updateAttendanceByRollNumbers(
                        absentController.text, 'absent');
                    absentController.clear();
                  },
                  child: const Text('Mark Absent'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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

                  final students = snapshot.data!.docs.toList();
                  students.sort((a, b) {
                    int rollA = int.tryParse(a['rollNumber'] ?? '0') ?? 0;
                    int rollB = int.tryParse(b['rollNumber'] ?? '0') ?? 0;
                    return rollA.compareTo(rollB);
                  });

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student =
                          students[index].data() as Map<String, dynamic>;
                      final studentId = students[index].id;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Roll No: ${student['rollNumber'] ?? 'N/A'}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: attendanceStatus[studentId] ==
                                              'present'
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      _markAttendance(
                                          studentId, classId, 'present');
                                    },
                                    tooltip: 'Mark Present',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.cancel,
                                      color: attendanceStatus[studentId] ==
                                              'absent'
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      _markAttendance(
                                          studentId, classId, 'absent');
                                    },
                                    tooltip: 'Mark Absent',
                                  ),
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
}
