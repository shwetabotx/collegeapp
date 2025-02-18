// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/admin/add_delete.dart';
import 'package:collegeapp/pages/admin/view_users_page.dart';
import 'package:collegeapp/pages/login_page.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
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

      if (users.isNotEmpty) {
        openBulkGmailApp(users);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Excel data uploaded successfully!"),
        ),
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
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('lib/images/me2.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ("Admin"),
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
                // Navigate to Profile Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                // Navigate to Settings Page
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          builder: (context) => const ViewUsersPage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.upload_file,
                    title: 'Upload Excel',
                    onTap: () => _uploadExcelToFirestore(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
