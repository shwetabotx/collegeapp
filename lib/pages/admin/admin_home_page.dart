// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/about_developers_page.dart';
import 'package:collegeapp/pages/admin/admin_settings_page.dart';
import 'package:collegeapp/pages/admin/student_promotion_page.dart';
import 'package:collegeapp/pages/admin/admin_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:collegeapp/pages/login_page.dart';
import 'package:collegeapp/pages/admin/add_delete.dart';
import 'package:collegeapp/pages/admin/view_users_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class AdminHomePage extends StatefulWidget {
  final String adminId; // Admin ID passed from login

  const AdminHomePage({super.key, required this.adminId});

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  String adminName = "Admin"; // Default name while fetching

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  /// Fetch admin's name from Firestore
  Future<void> fetchAdminName() async {
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminId)
          .get();

      if (adminDoc.exists) {
        setState(() {
          adminName = adminDoc['name'] ?? "Admin";
        });
      }
    } catch (e) {
      print("Error fetching admin name: $e");
    }
  }

  /// Generates a random alphanumeric string of the given length
  String generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Opens the Gmail app with prefilled email content for each user separately
  Future<void> openBulkGmailApp(List<Map<String, String>> users) async {
    for (var user in users) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: user['email'],
        queryParameters: {
          'subject': 'Login\tCredentials\tfor\tMJSB\tCollege',
          'body':
              "Hello\t${user['name']},\n\nHere\tare\tyour\tlogin\tdetails\tfor\tMJSB\tCollege:\n\nUsername:\t${user['username']}\nPassword:\t${user['password']}\n\nPlease\tkeep\tyour\tcredentials\tsafe.",
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        print('Could not open Gmail app');
      }
    }
  }

  /// Handles Excel file upload and uploads data to Firestore
  Future<void> _uploadExcelToFirestore(BuildContext context) async {
    bool confirmUpload = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Upload"),
          content:
              const Text("Are you sure you want to upload the Excel file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Proceed
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (confirmUpload) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent user from closing it
          builder: (context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Uploading Excel file..."),
                ],
              ),
            );
          },
        );

        try {
          var bytes = await file.readAsBytes();
          var excel = Excel.decodeBytes(bytes);

          List<Map<String, String>> users = [];

          for (var table in excel.tables.keys) {
            var sheet = excel.tables[table];
            if (sheet != null) {
              for (int i = 1; i < sheet.rows.length; i++) {
                var row = sheet.rows[i];

                if (row.length < 9) continue; // Skip invalid rows

                String classId = row[0]?.value.toString() ?? "";
                String department = row[1]?.value.toString() ?? "";
                String email = row[2]?.value.toString() ?? "";
                String name = row[3]?.value.toString() ?? "";
                String phone = row[5]?.value.toString() ?? "";
                String role = row[7]?.value.toString() ?? "";

                // Generate random username and password
                String generatedUsername =
                    name.split(' ')[0].toLowerCase() + generateRandomString(4);
                String generatedPassword = generateRandomString(8);

                Map<String, dynamic> data = {
                  "classId": classId,
                  "department": department,
                  "email": email,
                  "name": name,
                  "password": generatedPassword,
                  "phone": phone,
                  "username": generatedUsername,
                  "role": role,
                };

                if (role == "Student" && row.length > 9) {
                  data["driverId"] = row[8]?.value.toString() ?? "";
                  data["rollNumber"] = row[9]?.value.toString() ?? "";
                  await FirebaseFirestore.instance
                      .collection("classes")
                      .doc(classId)
                      .collection("students")
                      .doc(generatedUsername)
                      .set(data);
                } else if (role == "Teacher" && row.length > 8) {
                  String teacherId = row[8]?.value.toString() ?? "";
                  data["teacherId"] = teacherId;
                  await FirebaseFirestore.instance
                      .collection("classes")
                      .doc(classId)
                      .collection("teachers")
                      .doc(generatedUsername)
                      .set(data);
                }

                if (email.isNotEmpty) {
                  users.add({
                    "name": name,
                    "email": email,
                    "username": generatedUsername,
                    "password": generatedPassword,
                  });
                }
              }
            }
          }

          Navigator.pop(context); // Close loading dialog

          if (users.isNotEmpty) {
            openBulkGmailApp(users);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Excel data uploaded successfully!"),
            ),
          );
        } catch (e) {
          Navigator.pop(context); // Close loading dialog if an error occurs
          print("Error uploading Excel file: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload Excel file"),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
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
                    adminName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminProfilePage(
                      adminId: widget.adminId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About Us"),
              onTap: () {},
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
                      classId: '',
                      studentId: '',
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
                // Navigate to Teachers Setting Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminSettingsPage(
                      adminId: widget.adminId,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $adminName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    icon: Icons.group_add,
                    title: 'Add/Delete Users',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddDeletePage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.manage_accounts,
                    title: 'View Users',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewUsersPage(
                            adminId: widget.adminId,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.upload_file,
                    title: 'Upload Excel',
                    onTap: () => _uploadExcelToFirestore(context),
                  ),
                  _buildFeatureCard(
                    icon: Icons.arrow_upward,
                    title: 'Student Promotion',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentPromotionPage(
                            adminId: widget.adminId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Processes the uploaded Excel file
  Future<void> processExcelFile(File file) async {
    try {
      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          print(row.map((e) => e?.value).toList());
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Excel file processed successfully!")),
      );
    } catch (e) {
      print("Error processing Excel file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to process Excel file")),
      );
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.deepPurple),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
