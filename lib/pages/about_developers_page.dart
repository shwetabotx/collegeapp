import 'package:flutter/material.dart';

class AboutDevelopersPage extends StatelessWidget {
  const AboutDevelopersPage(
      {super.key,
      required String classId,
      required String studentId,
      required String teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About the Developers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            DeveloperInfo(
              name: 'Shweta',
              role: 'Lead Developer',
              description:
                  'Shweta is the lead developer, specializing in Flutter development and app architecture.',
              imageAsset: 'lib/images/shweta.png',
            ),
            SizedBox(height: 20),
            DeveloperInfo(
              name: 'Sneha',
              role: 'Backend Developer',
              description:
                  'Sneha handles the backend integration, working with Firestore and API development.',
              imageAsset: 'lib/images/sneha.png',
            ),
          ],
        ),
      ),
    );
  }
}

class DeveloperInfo extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final String imageAsset;

  const DeveloperInfo({
    super.key,
    required this.name,
    required this.role,
    required this.description,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(imageAsset),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
