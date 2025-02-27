import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/razorpay_payment.dart';
import 'package:collegeapp/pages/student/student_settings_page.dart';
import 'package:flutter/material.dart';
import '../login_page.dart';
import 'package:collegeapp/pages/about_developers_page.dart';
import 'package:collegeapp/pages/student/student_attendance_page.dart';
import 'package:collegeapp/pages/driver/driver_location_map_page.dart';
import 'package:collegeapp/pages/student/student_internal_exam_results.dart';
import 'package:collegeapp/pages/student/student_announcement_page.dart';
import 'package:collegeapp/pages/student/student_assignment_page.dart';
import 'package:collegeapp/pages/student/student_homework_page.dart';
import 'package:collegeapp/pages/student/student_manage_tasks_page.dart';
import 'package:collegeapp/pages/student/student_post_page.dart';
import 'package:collegeapp/pages/student/student_profile_page.dart';
import 'package:collegeapp/pages/student/student_timetable_page.dart';
import 'package:collegeapp/pages/student/student_links_page.dart';
import 'package:collegeapp/pages/student/view_resources_page.dart';

class StudentHomePage extends StatefulWidget {
  final String classId;
  final String studentId;
  final String driverId;

  const StudentHomePage({
    super.key,
    required this.classId,
    required this.studentId,
    required this.driverId,
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String studentName = "Student";
  String profileImageUrl = ""; // Default empty, fallback to asset image

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
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
          profileImageUrl = snapshot.data()?['profileImageUrl'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error fetching student data: $e");
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    studentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Other drawer items remain unchanged
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentProfilePage(
                      classId: widget.classId,
                      studentId: widget.studentId,
                      driverId: '',
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About Us"),
              onTap: () {
                // Navigate to About Us Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("About Devlopers"),
              onTap: () {
                // Navigate to About Us Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutDevelopersPage(
                      classId: widget.classId,
                      studentId: widget.studentId,
                      teacherId: '',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                // Navigate to About Us Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentSettingsPage(
                      classId: widget.classId,
                      studentId: widget.studentId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text(
                          "Are you sure you want to log out?\nYou might miss us."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner with Profile Picture
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
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('lib/images/me2.png')
                              as ImageProvider,
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

              // Existing Features List (Kept intact)
              _buildFeatureTile(
                title: "Manage Tasks",
                subtitle: "Set your goals and tasks",
                icon: Icons.list_alt,
                color: Colors.deepPurple.shade800,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentManageTasksPage(
                        classId: widget.classId,
                        studentId: widget.studentId,
                      ),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                title: "Bus Tracking",
                subtitle: "Track your bus in real time",
                icon: Icons.directions_bus,
                color: Colors.deepPurple.shade300,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverLocationMapPage(
                        driverId: widget.driverId,
                        studentId: widget.studentId,
                        classId: widget.classId,
                      ),
                    ),
                  );
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
                          classId: widget.classId, studentId: widget.studentId),
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
                        studentId: widget.studentId,
                      ),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                title: "Discussion Corner",
                subtitle: "Discuss",
                icon: Icons.chat,
                color: Colors.deepPurple.shade400,
                onTap: () {
                  //Navigate to Time-Table
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentPostPage(
                        classId: widget.classId,
                        studentId: widget.studentId,
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
                      builder: (context) => StudentAnnouncementsPage(
                        classId: widget.classId,
                        studentId: widget.studentId,
                      ),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                title: "Assignments",
                subtitle: "Track your assignments",
                icon: Icons.menu_book,
                color: Colors.deepPurple.shade800,
                onTap: () {
                  // Navigate to Assignments
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAssignmentPage(
                        classId: widget.classId,
                        studentId: widget.studentId,
                      ),
                    ),
                  );
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
                          classId: widget.classId, studentId: widget.studentId),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                title: "Homework",
                subtitle: "View your homework",
                icon: Icons.assignment,
                color: Colors.purpleAccent.shade700,
                onTap: () {
                  // Navigate to Homework
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentHomeworkPage(
                          classId: widget.classId, studentId: widget.studentId),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                title: "View Resources",
                subtitle: "Get your resources on a click!",
                icon: Icons.note,
                color: Colors.deepPurple.shade600,
                onTap: () {
                  // Navigate to View Resources
                  // Navigate to Important Links
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewResourcesPage(
                              classId: widget.classId,
                              studentId: widget.studentId,
                            )),
                  );
                },
              ),
              _buildFeatureTile(
                title: "Important Links",
                subtitle: "Access useful resources' links",
                icon: Icons.link,
                color: Colors.purple.shade300,
                onTap: () {
                  // Navigate to Important Links
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentLinksPage(
                              classId: widget.classId,
                              studentId: widget.studentId,
                            )),
                  );
                },
              ),
              _buildFeatureTile(
                title: "Internal Exam Results",
                subtitle: "View your academic progress",
                icon: Icons.grade,
                color: Colors.purpleAccent.shade700,
                onTap: () {
                  // Navigate to Test Results
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentInternalExamResultsPage(
                              studentId: widget.studentId,
                              classId: widget.classId,
                            )),
                  );
                },
              ),
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
          leading: Icon(icon, size: 32, color: color),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle:
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
    );
  }
}
