// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:collegeapp/pages/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class StudentPostPage extends StatefulWidget {
  final String studentId;
  final String classId;

  const StudentPostPage({
    super.key,
    required this.studentId,
    required this.classId,
  });

  @override
  StudentPostPageState createState() => StudentPostPageState();
}

class StudentPostPageState extends State<StudentPostPage> {
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
      await FirebaseFirestore.instance.collection('studentposts').add({
        'studentId': widget.studentId,
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
        title: const Text(
          "Student Posts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  studentId: widget.studentId,
                  classId: widget.classId,
                  driverId: '',
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
                  classId: widget.classId, studentId: widget.studentId)),
        ],
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  final String classId;
  final String studentId;

  const PostsList({
    super.key,
    required this.classId,
    required this.studentId,
  });

  Future<String> _fetchStudentName(String studentId, String classId) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        return studentDoc['name'] ?? "Unknown Student";
      }
    } catch (e) {
      print("Error fetching student name: $e");
    }
    return "Unknown Student";
  }

  Future<void> _deletePost(String postId, BuildContext context) async {
    try {
      // Delete the post
      await FirebaseFirestore.instance
          .collection('studentposts')
          .doc(postId)
          .delete();

      // Optionally, delete all comments associated with this post
      var comments = await FirebaseFirestore.instance
          .collection('studentposts')
          .doc(postId)
          .collection('comments')
          .get();

      for (var comment in comments.docs) {
        await comment.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted successfully!")),
      );
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('studentposts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return FutureBuilder<String>(
              future: _fetchStudentName(doc['studentId'], doc['classId']),
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
                          nameSnapshot.data ?? "Unknown Student",
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
                          studentId: studentId,
                          classId: classId,
                          teacherId: '',
                        ),
                        if (doc['studentId'] == studentId)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deletePost(doc.id, context),
                          ),
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
  final String studentId;
  final String classId;

  const CommentSection({
    super.key,
    required this.postId,
    required this.studentId,
    required this.classId,
    required String teacherId,
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
          .collection('studentposts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'studentId': widget.studentId,
        'classId': widget.classId,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    } catch (e) {
      print("Error posting comment: $e");
    }
  }

  // Function to delete a comment
  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('studentposts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment deleted successfully!")),
      );
    } catch (e) {
      print("Error deleting comment: $e");
    }
  }

  Future<String> _fetchStudentName(String studentId, String classId) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        return studentDoc['name'] ?? "Unknown Student";
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
              .collection('studentposts')
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
                bool isOwner = doc['studentId'] ==
                    widget
                        .studentId; // Check if the current teacher is the comment owner
                return FutureBuilder<String>(
                  future: _fetchStudentName(doc['studentId'], doc['classId']),
                  builder: (context, teacherSnapshot) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teacherSnapshot.data ?? "Unknown Student",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(doc['comment']),
                                ],
                              ),
                            ),
                            if (isOwner) // Show the delete button only if the current teacher is the one who posted
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteComment(doc.id),
                              ),
                          ],
                        ),
                      ),
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
