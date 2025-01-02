import 'package:flutter/material.dart';
import 'login_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Student Dashboard"),
        backgroundColor: Colors.deepPurpleAccent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              });
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with a profile icon
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/student_background.jpg'), // Add your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 20,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/profile_picture.jpg'), // Add profile picture
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 100,
                  child: Text(
                    'Welcome, Student!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Feature cards in GridView
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap:
                    true, // So it doesn't take up more space than necessary
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    icon: Icons.directions_bus,
                    title: 'Bus Tracking',
                    gradientColors: [
                      Colors.deepPurple.shade400,
                      Colors.purpleAccent
                    ],
                    onTap: () {
                      // Navigate to Bus Tracking page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.access_alarm,
                    title: 'Attendance',
                    gradientColors: [
                      Colors.purpleAccent,
                      Colors.deepPurple.shade300
                    ],
                    onTap: () {
                      // Navigate to Attendance page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.announcement,
                    title: 'Announcements',
                    gradientColors: [Colors.deepPurple.shade500, Colors.purple],
                    onTap: () {
                      // Navigate to Announcements page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.attach_money,
                    title: 'Fees',
                    gradientColors: [
                      Colors.deepPurple.shade600,
                      Colors.purple.shade200
                    ],
                    onTap: () {
                      // Navigate to Fees page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.forum,
                    title: 'Student Discussion',
                    gradientColors: [
                      Colors.deepPurple.shade700,
                      Colors.purpleAccent
                    ],
                    onTap: () {
                      // Navigate to Discussion page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.link,
                    title: 'Important Links',
                    gradientColors: [
                      Colors.deepPurple.shade800,
                      Colors.purple.shade400
                    ],
                    onTap: () {
                      // Navigate to Important Links page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.assignment,
                    title: 'Assignments',
                    gradientColors: [
                      Colors.deepPurple.shade900,
                      Colors.purple.shade500
                    ],
                    onTap: () {
                      // Navigate to Assignments page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.grade,
                    title: 'Test Results',
                    gradientColors: [
                      Colors.purpleAccent,
                      Colors.deepPurple.shade400
                    ],
                    onTap: () {
                      // Navigate to Test Results page
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.show_chart,
                    title: 'Growth Tracking',
                    gradientColors: [Colors.deepPurple.shade300, Colors.purple],
                    onTap: () {
                      // Navigate to Growth Tracking page
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
