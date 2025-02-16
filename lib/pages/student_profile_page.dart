import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:collegeapp/pages/student_home_page.dart';

class StudentProfilePage extends StatefulWidget {
  final String classId;
  final String studentId;

  const StudentProfilePage({
    super.key,
    required this.classId,
    required this.studentId,
    required String driverId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  String? _profileImageUrl;
  bool _isUploading = false;

  /// Fetch student profile data, including the profile picture URL
  Future<void> _fetchStudentData() async {
    DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('students')
        .doc(widget.studentId)
        .get();

    if (studentSnapshot.exists) {
      setState(() {
        _profileImageUrl = studentSnapshot.data() != null &&
                (studentSnapshot.data() as Map).containsKey('profileImageUrl')
            ? studentSnapshot['profileImageUrl']
            : null;
      });
    }
  }

  /// Upload the selected image to Cloudinary
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = "dnxfyvlei"; // Replace with your Cloudinary cloud name
    const uploadPreset = 'collegeapp';

    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      return decodedData['secure_url']; // Cloudinary returns a secure HTTPS URL
    } else {
      return null;
    }
  }

  /// Pick an image from the gallery and upload it to Cloudinary
  Future<void> _pickAndUploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    File imageFile = File(pickedFile.path);
    String? imageUrl = await _uploadImageToCloudinary(imageFile);

    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('students')
          .doc(widget.studentId)
          .update({'profileImageUrl': imageUrl});

      setState(() {
        _profileImageUrl = imageUrl;
        _isUploading = false;
      });
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image. Try again.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  /// Converts dynamic field to a string with proper type handling
  String convertToString(dynamic value) {
    if (value == null) {
      return 'N/A';
    } else if (value is int || value is double) {
      return value.toString();
    } else if (value is String) {
      return value;
    } else {
      return 'Invalid Data';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId)
            .collection('students')
            .doc(widget.studentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Student information not found."),
            );
          }

          final studentData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const AssetImage('lib/images/me2.png')
                                      as ImageProvider,
                            ),
                            if (_isUploading)
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                convertToString(studentData['name']),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Roll No: ${convertToString(studentData['rollNumber'])}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.deepPurple),
                          onPressed: _pickAndUploadImage,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Details Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ProfileDetailRow(
                          icon: Icons.email,
                          label: "Email",
                          value: convertToString(studentData['email']),
                        ),
                        ProfileDetailRow(
                          icon: Icons.phone,
                          label: "Phone",
                          value: convertToString(studentData['phone']),
                        ),
                        ProfileDetailRow(
                          icon: Icons.group,
                          label: "Role",
                          value: convertToString(studentData['role']),
                        ),
                        ProfileDetailRow(
                          icon: Icons.class_,
                          label: "Class ID",
                          value: widget.classId,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
              child: Text("$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
