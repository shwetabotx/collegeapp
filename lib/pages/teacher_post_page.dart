// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class TeacherPostPage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const TeacherPostPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  TeacherPostPageState createState() => TeacherPostPageState();
}

class TeacherPostPageState extends State<TeacherPostPage> {
  final TextEditingController _postController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadFileToCloudinary(File file) async {
    try {
      String cloudinaryUrl =
          "https://api.cloudinary.com/v1_1/dnxfyvlei/image/upload";
      String uploadPreset = "collegeapp";

      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        return jsonResponse['secure_url'];
      }
    } catch (e) {
      print("File upload error: $e");
    }
    return null;
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty && _selectedFile == null) {
      return;
    }

    setState(() {
      isUploading = true;
    });

    String? fileUrl;
    if (_selectedFile != null) {
      fileUrl = await _uploadFileToCloudinary(_selectedFile!);
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'teacherId': widget.teacherId,
        'classId': widget.classId,
        'fileUrl': fileUrl ?? "",
        'fileName': _fileName ?? "",
        'content': _postController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _postController.clear();
      setState(() {
        _selectedFile = null;
        _fileName = null;
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post uploaded successfully!")),
      );
    } catch (e) {
      print("Error uploading post: $e");
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Posts"),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherHomePage(
                  teacherId: widget.teacherId,
                  classId: widget.classId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  decoration: const InputDecoration(
                    labelText: "Write a post...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                _fileName != null
                    ? Text("Selected: $_fileName")
                    : const SizedBox.shrink(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickFile),
                    isUploading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _createPost, child: const Text("Post")),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
              child: PostsList(
                  classId: widget.classId, teacherId: widget.teacherId)),
        ],
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  final String classId;
  final String teacherId;

  const PostsList({
    super.key,
    required this.classId,
    required this.teacherId,
  });

  Future<String> _fetchTeacherName(String teacherId, String classId) async {
    try {
      DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        return teacherDoc['name'] ?? "Unknown Teacher";
      }
    } catch (e) {
      print("Error fetching teacher name: $e");
    }
    return "Unknown Teacher";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return FutureBuilder<String>(
              future: _fetchTeacherName(doc['teacherId'], doc['classId']),
              builder: (context, nameSnapshot) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameSnapshot.data ?? "Unknown Teacher",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(doc['content'],
                            style: const TextStyle(fontSize: 16)),
                        if (doc['fileUrl'] != "")
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(doc['fileUrl']),
                          ),
                        const SizedBox(height: 10),
                        CommentSection(
                            postId: doc.id,
                            teacherId: teacherId,
                            classId: classId),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class CommentSection extends StatefulWidget {
  final String postId;
  final String teacherId;
  final String classId;

  const CommentSection({
    super.key,
    required this.postId,
    required this.teacherId,
    required this.classId,
  });

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'teacherId': widget.teacherId,
        'classId': widget.classId,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    } catch (e) {
      print("Error posting comment: $e");
    }
  }

  Future<String> _fetchTeacherName(String teacherId, String classId) async {
    try {
      DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        return teacherDoc['name'] ?? "Unknown Teacher";
      }
    } catch (e) {
      print("Error fetching teacher name: $e");
    }
    return "Unknown Teacher";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                return FutureBuilder<String>(
                  future: _fetchTeacherName(doc['teacherId'], doc['classId']),
                  builder: (context, teacherSnapshot) {
                    return ListTile(
                      title: Text(teacherSnapshot.data ?? "Unknown Teacher"),
                      subtitle: Text(doc['comment']),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration:
                      const InputDecoration(labelText: "Write a comment..."),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _postComment),
            ],
          ),
        ),
      ],
    );
  }
}
