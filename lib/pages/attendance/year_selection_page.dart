import 'package:flutter/material.dart';
import 'attendance_page.dart';

class YearSelectionPage extends StatelessWidget {
  final String major;
  const YearSelectionPage({super.key, required this.major});

  @override
  Widget build(BuildContext context) {
    final List<String> years = [
      "First Year",
      "Second Year",
      "Third Year",
      "Fourth Year",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("$major - Select Year"),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select a Year for $major",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    return _buildYearRow(context, major, year);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearRow(BuildContext context, String major, String year) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendancePage(major: major, year: year),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 60), // Full-width button
        ),
        child: Row(
          children: [
            const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                year,
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
