import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/student/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewResourcesPage extends StatefulWidget {
  final String classId;
  final String studentId;

  const ViewResourcesPage(
      {super.key, required this.classId, required this.studentId});

  @override
  ViewResourcesPageState createState() => ViewResourcesPageState();
}

class ViewResourcesPageState extends State<ViewResourcesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Resources",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Logout logic
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentHomePage(
                        studentId: widget.studentId, // Pass teacherId
                        classId: widget.classId, driverId: '',
                      )),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("classes")
            .doc(widget.classId)
            .collection("resources")
            .orderBy("uploadedAt", descending: true) // Latest files first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No resources available."));
          }

          var resources = snapshot.data!.docs;

          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              var resource = resources[index];
              String title = resource["title"];
              String description = resource["description"];
              String fileUrl = resource["fileUrl"];
              String category = resource["category"];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: ListTile(
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category: $category"),
                      Text("Description: $description"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.blue),
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(fileUrl))) {
                        await launchUrl(Uri.parse(fileUrl));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Could not open file.")),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
