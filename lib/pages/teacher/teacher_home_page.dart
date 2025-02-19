import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/about_developers_page.dart';
import 'package:collegeapp/pages/teacher/teacher_assignment_page.dart';
import 'package:collegeapp/pages/teacher/teacher_homework_page.dart';
import 'package:collegeapp/pages/teacher/teacher_manage_tasks_page.dart';
import 'package:collegeapp/pages/teacher/teacher_post_page.dart';
import 'package:collegeapp/pages/teacher/teacher_profile_page.dart';
import 'package:collegeapp/pages/teacher/teacher_test_marks_page.dart';
import 'package:collegeapp/pages/teacher/upload_resources_page.dart';
import 'package:flutter/material.dart';
import 'package:collegeapp/pages/teacher/teacher_announcement_page.dart';
import 'package:collegeapp/pages/teacher/teacher_time_table.dart';
import 'attendance/major_selection_page.dart';
import '../login_page.dart';

class TeacherHomePage extends StatelessWidget {
  final String teacherId;
  final String classId;

  // Constructor to accept teacherId and classId
  const TeacherHomePage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  Future<Map<String, String>> fetchTeacherDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        return {
          'name': data?['name'] ?? 'Unknown Name',
          'department': data?['department'] ?? 'Unknown Department',
          'profileImageUrl': data?['profileImageUrl'] ??
              'lib/images/me2.png', // Fetch profile image URL
        };
      }
    } catch (e) {
      debugPrint('Error fetching teacher details: $e');
    }
    return {
      'name': 'Unknown Name',
      'department': 'Unknown Department',
      'profileImageUrl': 'lib/images/me2.png', // Default image
    };
  }

  // function to fetch the total number of students
  Future<int> fetchTotalStudents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('students')
          .get();

      return snapshot
          .size; // Returns the number of documents (students) in the class
    } catch (e) {
      debugPrint('Error fetching total students: $e');
      return 0; // Return 0 if an error occurs
    }
  }

// function to fetch the number of pending tasks
  Future<int> fetchPendingTasksCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .doc(teacherId)
          .collection('tasks')
          .where('completed', isEqualTo: false)
          .get();

      return snapshot.size; // Returns the number of pending tasks
    } catch (e) {
      debugPrint('Error fetching pending tasks: $e');
      return 0; // Return 0 if an error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      drawer: FutureBuilder<Map<String, String>>(
        future: fetchTeacherDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final teacherDetails = snapshot.data ?? {};
          final teacherName = teacherDetails['name']!;
          final teacherDepartment = teacherDetails['department']!;
          final profileImageUrl = teacherDetails['profileImageUrl']!;

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.green),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            profileImageUrl), // Display the fetched profile image
                      ),
                      const SizedBox(height: 10),
                      Text(
                        teacherName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        teacherDepartment,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () {
                    // Navigate to profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherProfilePage(
                          classId: classId,
                          teacherId: teacherId,
                        ),
                      ),
                    );
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
                          classId: classId,
                          teacherId: teacherId,
                          studentId: '',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notifications"),
                  onTap: () {
                    // Navigate to notifications page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text("Help & Support"),
                  onTap: () {
                    // Navigate to help page
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
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text("No"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
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
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Dashboard Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FutureBuilder<int>(
                    future: fetchTotalStudents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildDashboardCard("Total Students",
                            "Loading...", Icons.group, context);
                      } else if (snapshot.hasError) {
                        return _buildDashboardCard(
                            "Total Students", "Error", Icons.group, context);
                      } else {
                        return _buildDashboardCard("Total Students",
                            snapshot.data.toString(), Icons.group, context);
                      }
                    },
                  ),

                  // to display pending tasks
                  FutureBuilder<int>(
                    future: fetchPendingTasksCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildDashboardCard("Pending Tasks",
                            "Loading...", Icons.pending_actions, context);
                      } else if (snapshot.hasError) {
                        return _buildDashboardCard("Pending Tasks", "Error",
                            Icons.pending_actions, context);
                      } else {
                        return _buildDashboardCard(
                            "Pending Tasks",
                            snapshot.data.toString(),
                            Icons.pending_actions,
                            context);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Features",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureCard(
                    "Manage Tasks", Icons.list_alt, Colors.blue, context),
                _buildFeatureCard("Mark Attendance", Icons.check_circle,
                    Colors.orange, context),
                _buildFeatureCard("Announcement", Icons.announcement,
                    const Color.fromARGB(255, 24, 209, 169), context),
                _buildFeatureCard(
                    "Time-Table", Icons.calendar_month, Colors.pink, context),
                _buildFeatureCard("Assign Homework", Icons.assignment,
                    Colors.purple, context),
                _buildFeatureCard(
                    "Assignments", Icons.menu_book, Colors.red, context),
                _buildFeatureCard(
                    "Upload Resources", Icons.note, Colors.teal, context),
                //_buildFeatureCard(
                //"Messages", Icons.message, Colors.cyan, context),
                _buildFeatureCard("Internal Marks", Icons.star,
                    const Color.fromARGB(255, 101, 47, 228), context),
                _buildFeatureCard("Discussion Corner", Icons.chat,
                    const Color.fromARGB(255, 101, 47, 228), context),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "Powered by College App",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick add action
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, String value, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Tapped on $title')));
      },
      child: Card(
        color: Colors.green.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "Manage Tasks") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherManageTasksPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Mark Attendance") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MajorSelectionPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Announcement") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherAnnouncementPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Time-Table") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherTimeTablePage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Assignments") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherAssignmentPage(
                      teacherId: teacherId,
                      classId: classId,
                      // currentClassId: '',
                      // major: '',
                      // year: '',
                    )),
          );
        } else if (title == "Assign Homework") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherHomeworkPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Internal Marks") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherTestMarksPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Upload Resources") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => UploadResourcesPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        } else if (title == "Discussion Corner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeacherPostPage(
                      teacherId: teacherId,
                      classId: classId,
                    )),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
