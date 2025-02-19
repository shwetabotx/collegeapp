import 'package:collegeapp/pages/student/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentLinksPage extends StatefulWidget {
  const StudentLinksPage(
      {super.key, required this.classId, required this.studentId});

  final String classId;
  final String studentId;

  @override
  StudentLinksPageState createState() => StudentLinksPageState();
}

class StudentLinksPageState extends State<StudentLinksPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to launch URLs
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Links",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  classId: widget.classId,
                  studentId: widget.studentId,
                  driverId: '',
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _buildBody(context),
    );
  }

  // Helper function to create the animated body
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          // Use fade and slide animations for each item
          _controller.forward(); // Trigger animation
          return _buildSlideInCard(context, index);
        },
      ),
    );
  }

  // Helper function to create a slide-in card animation
  Widget _buildSlideInCard(BuildContext context, int index) {
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Starts from the right
      end: Offset.zero, // Ends at its original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: _buildLinkCard(
        context,
        title: _getLinkTitle(index),
        description: _getLinkDescription(index),
        url: _getLinkURL(index),
      ),
    );
  }

  // Helper function to create a reusable link card
  Widget _buildLinkCard(BuildContext context,
      {required String title,
      required String description,
      required String url}) {
    return Card(
      elevation: 8, // Giving the card a shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius:
            BorderRadius.circular(16), // Rounded corners for tap effect
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  //color: Colors.deepPurpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.link,
                  color: Colors.deepPurpleAccent,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.deepPurpleAccent),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get link title by index
  String _getLinkTitle(int index) {
    switch (index) {
      case 0:
        return "GCAS Portal";
      case 1:
        return "ABC ID Portal";
      case 2:
        return "College Website";
      case 3:
        return "Instagram";
      default:
        return "Unknown Link";
    }
  }

  // Helper function to get link description by index
  String _getLinkDescription(int index) {
    switch (index) {
      case 0:
        return "Access your GCAS portal for academic records.";
      case 1:
        return "Manage your ABC ID and services.";
      case 2:
        return "Visit the official college website.";
      case 3:
        return "Follow us on Instagram for the latest updates.";
      default:
        return "No description available.";
    }
  }

  // Helper function to get link URL by index
  String _getLinkURL(int index) {
    switch (index) {
      case 0:
        return "https://gcas.gujgov.edu.in";
      case 1:
        return "https://www.abc.gov.in";
      case 2:
        return "https://mjsbmc.ac.in";
      case 3:
        return "https://www.instagram.com/mjsbgirlscollege.2005/";
      default:
        return "";
    }
  }
}
