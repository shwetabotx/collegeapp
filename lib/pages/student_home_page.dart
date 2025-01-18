import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/attendance_tracking_page.dart';
import 'package:collegeapp/pages/student_announcement_page.dart';
//import 'package:collegeapp/pages/student_assignment_page.dart';
import 'package:collegeapp/pages/student_timetable_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'razorpay_payment.dart';

class StudentHomePage extends StatefulWidget {
  final String classId;
  final String studentId;

  const StudentHomePage({
    super.key,
    required this.classId,
    required this.studentId,
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String studentName = "Student"; // Default name in case fetching fails

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  Future<void> _fetchStudentName() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('students')
          .doc(widget.studentId)
          .get();

      if (snapshot.exists) {
        setState(() {
          studentName = snapshot.data()?['name'] ?? "Student";
        });
      }
    } catch (e) {
      debugPrint("Error fetching student name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
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
        actions: [
          IconButton(
            onPressed: () {
              // Logout logic
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                          'lib/images/girl1.png'), // Add profile picture
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Welcome, $studentName!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Explore your dashboard for updates and resources.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Features Section
              ...[
                _buildFeatureTile(
                  title: "Bus Tracking",
                  subtitle: "Track your bus in real time",
                  icon: Icons.directions_bus,
                  color: Colors.deepPurple.shade300,
                  onTap: () {
                    // Navigate to Bus Tracking
                  },
                ),
                _buildFeatureTile(
                  title: "Attendance",
                  subtitle: "Check your attendance records",
                  icon: Icons.access_alarm,
                  color: Colors.purple.shade400,
                  onTap: () {
                    // Navigate to Attendance
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceTrackingPage(
                            classId: widget.classId,
                            studentId: widget.studentId),
                      ),
                    );
                  },
                ),
                _buildFeatureTile(
                  title: "Time-Table",
                  subtitle: "Your Weekly Time-Table",
                  icon: Icons.calendar_month,
                  color: Colors.deepPurple.shade400,
                  onTap: () {
                    // Navigate to Time-Table
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentTimeTablePage(
                          classId: widget.classId,
                        ),
                      ),
                    );
                  },
                ),
                _buildFeatureTile(
                  title: "Announcements",
                  subtitle: "View important updates",
                  icon: Icons.announcement,
                  color: Colors.purpleAccent,
                  onTap: () {
                    // Navigate to Announcements
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentAnnouncementsPage(classId: widget.classId),
                      ),
                    );
                  },
                ),
                _buildFeatureTile(
                  title: "Assignments",
                  subtitle: "Track your assignments",
                  icon: Icons.assignment,
                  color: Colors.deepPurple.shade800,
                  onTap: () {
                    // Navigate to Assignments
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentAssignmentsPage(classId: widget.classId),
                      ),
                    );*/
                  },
                ),
                _buildFeatureTile(
                  title: "Fees",
                  subtitle: "Pay your college fees",
                  icon: Icons.currency_rupee,
                  color: Colors.deepPurple.shade400,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RazorpayPage(
                            classId: widget.classId,
                            studentId: widget.studentId),
                      ),
                    );
                  },
                ),
                _buildFeatureTile(
                  title: "Student Discussion",
                  subtitle: "Collaborate with peers",
                  icon: Icons.forum,
                  color: Colors.deepPurple.shade600,
                  onTap: () {
                    // Navigate to Student Discussion
                  },
                ),
                _buildFeatureTile(
                  title: "Important Links",
                  subtitle: "Access useful resources",
                  icon: Icons.link,
                  color: Colors.purple.shade300,
                  onTap: () {
                    // Navigate to Important Links
                  },
                ),
                _buildFeatureTile(
                  title: "Test Results",
                  subtitle: "View your academic progress",
                  icon: Icons.grade,
                  color: Colors.purpleAccent.shade700,
                  onTap: () {
                    // Navigate to Test Results
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
    );
  }
}
