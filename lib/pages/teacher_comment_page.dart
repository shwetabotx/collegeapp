// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherCommentPage extends StatefulWidget {
  final String postId;
  final String teacherId;
  final String classId;

  const TeacherCommentPage({
    super.key,
    required this.postId,
    required this.teacherId,
    required this.classId,
  });

  @override
  TeacherCommentPageState createState() => TeacherCommentPageState();
}

class TeacherCommentPageState extends State<TeacherCommentPage> {
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
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
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

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return FutureBuilder<String>(
                      future:
                          _fetchTeacherName(doc['teacherId'], doc['classId']),
                      builder: (context, teacherSnapshot) {
                        return ListTile(
                          title:
                              Text(teacherSnapshot.data ?? "Unknown Teacher"),
                          subtitle: Text(doc['comment']),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
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
                IconButton(
                    icon: const Icon(Icons.send), onPressed: _postComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
