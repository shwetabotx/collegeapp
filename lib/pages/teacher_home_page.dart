import 'attendance/major_selection_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

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
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/profile_placeholder.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Teacher Name",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "Mathematics Department",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              onTap: () {
                // Navigate to profile page
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
                // Logout logic
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                // Logout logic here
              },
            ),
          ],
        ),
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
            // Horizontal scrolling for the Dashboard cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDashboardCard(
                      "Total Classes", "5", Icons.class_, context),
                  _buildDashboardCard(
                      "Total Students", "120", Icons.group, context),
                  _buildDashboardCard(
                      "Pending Tasks", "3", Icons.pending_actions, context),
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
                    "Manage Classes", Icons.class_, Colors.blue, context),
                _buildFeatureCard("Mark Attendance", Icons.check_circle,
                    Colors.orange, context),
                _buildFeatureCard("Assign Homework", Icons.assignment,
                    Colors.purple, context),
                _buildFeatureCard(
                    "Grade Assignments", Icons.grade, Colors.red, context),
                _buildFeatureCard("Upload Resources", Icons.upload_file,
                    Colors.teal, context),
                _buildFeatureCard(
                    "Messages", Icons.message, Colors.cyan, context),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: const Text(
                "Powered by College App",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for quick add (e.g., create new assignment or announcement)
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dashboard Card with onTap method
  Widget _buildDashboardCard(
      String title, String value, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add your desired action for the dashboard card tap
        // Example: Navigate to a detailed view page or show a dialog
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Tapped on $title')));
      },
      child: Card(
        color: Colors.green.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.green),
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

  // Feature Card with onTap method
  Widget _buildFeatureCard(
      String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Perform an action based on the feature card tapped
        // Example: Navigate to the respective feature's page
        if (title == "Manage Classes") {
          // Navigate to Manage Classes page

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on Manage Classes')));
        } else if (title == "Mark Attendance") {
          // Navigate to Mark Attendance page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MajorSelectionPage()),
          );
        } else if (title == "Assign Homework") {
          // Navigate to Assign Homework page
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on Assign Homework')));
        } else if (title == "Grade Assignments") {
          // Navigate to Grade Assignments page
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on Grade Assignments')));
        } else if (title == "Upload Resources") {
          // Navigate to Upload Resources page
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on Upload Resources')));
        } else if (title == "Messages") {
          // Navigate to Messages page
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Tapped on Messages')));
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
