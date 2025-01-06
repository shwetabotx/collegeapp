import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'year_selection_page.dart';

class MajorSelectionPage extends StatelessWidget {
  const MajorSelectionPage(
      {super.key, required this.teacherId, required this.classId});
  final String teacherId;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> majors = [
      {"name": "Arts Major", "icon": "📚"},
      {"name": "Commerce Major", "icon": "💼"},
      {"name": "Computer Science Major", "icon": "💻"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Major"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Logout logic
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TeacherHomePage(
                          teacherId: teacherId, // Pass teacherId
                          classId: classId,
                        )),
              );
            });
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select a Major",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: majors.length,
                  itemBuilder: (context, index) {
                    final major = majors[index];
                    return _buildMajorRow(
                        context, major['name']!, major['icon']!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMajorRow(BuildContext context, String major, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YearSelectionPage(major: major),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 60), // Full-width button
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                major,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
