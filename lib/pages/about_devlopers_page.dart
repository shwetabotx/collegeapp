import 'package:collegeapp/pages/student_home_page.dart';
import 'package:flutter/material.dart';

class AboutDevelopersPage extends StatelessWidget {
  AboutDevelopersPage({
    super.key,
    required this.classId,
    required this.studentId,
  });

  final String classId;
  final String studentId;

  final List<Map<String, String>> developers = [
    {
      'name': 'John Doe',
      'role': 'Frontend Developer',
      'image': 'https://via.placeholder.com/150',
      'bio':
          'Passionate about creating stunning UIs and seamless user experiences.',
    },
    {
      'name': 'Jane Smith',
      'role': 'Backend Developer',
      'image': 'https://via.placeholder.com/150',
      'bio': 'Expert in building scalable and efficient backend systems.',
    },
    {
      'name': 'Alice Brown',
      'role': 'Mobile Developer',
      'image': 'https://via.placeholder.com/150',
      'bio': 'Loves crafting beautiful and responsive mobile apps.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developers'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  classId: classId,
                  studentId: studentId,
                  driverId: '',
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meet Our Team',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              ...developers.map((dev) => _buildDeveloperCard(dev)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(Map<String, String> developer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  developer['image']!,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      developer['name']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      developer['role']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      developer['bio']!,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
