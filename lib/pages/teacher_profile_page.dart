import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherProfilePage extends StatefulWidget {
  final String classId;
  final String teacherId;

  const TeacherProfilePage({
    super.key,
    required this.classId,
    required this.teacherId,
  });

  @override
  TeacherProfilePageState createState() => TeacherProfilePageState();
}

class TeacherProfilePageState extends State<TeacherProfilePage> {
  String? _profileImageUrl;
  bool _isUploading = false;

  /// Fetch teacher profile data, including the profile picture URL
  Future<void> _fetchTeacherData() async {
    DocumentSnapshot teacherSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('teachers')
        .doc(widget.teacherId)
        .get();

    if (teacherSnapshot.exists) {
      setState(() {
        _profileImageUrl = teacherSnapshot.data() != null &&
                (teacherSnapshot.data() as Map).containsKey('profileImageUrl')
            ? teacherSnapshot['profileImageUrl']
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
          .collection('teachers')
          .doc(widget.teacherId)
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
    _fetchTeacherData();
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
          "Teacher Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId)
            .collection('teachers')
            .doc(widget.teacherId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Teacher information not found."),
            );
          }

          final teacherData = snapshot.data!;
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
                                convertToString(teacherData['name']),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Role: ${convertToString(teacherData['role'])}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.green),
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
                          value: convertToString(teacherData['email']),
                        ),
                        ProfileDetailRow(
                          icon: Icons.phone,
                          label: "Phone",
                          value: convertToString(teacherData['phone']),
                        ),
                        ProfileDetailRow(
                          icon: Icons.class_,
                          label: "Class ID",
                          value: widget.classId,
                        ),
                        ProfileDetailRow(
                          icon: Icons.person,
                          label: "Teacher ID",
                          value: convertToString(teacherData['teacherId']),
                        ),
                        ProfileDetailRow(
                          icon: Icons.school,
                          label: "Department",
                          value: convertToString(teacherData['department']),
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
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
