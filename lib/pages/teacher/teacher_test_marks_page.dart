import 'dart:io';
import 'package:collegeapp/pages/teacher/teacher_home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

class TeacherTestMarksPage extends StatefulWidget {
  const TeacherTestMarksPage(
      {super.key, required this.teacherId, required this.classId});
  final String teacherId;
  final String classId;

  @override
  TeacherTestMarksPageState createState() => TeacherTestMarksPageState();
}

class TeacherTestMarksPageState extends State<TeacherTestMarksPage> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _processExcel() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file first')));
      return;
    }

    var bytes = await _selectedFile!.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid Excel format')));
      return;
    }

    List<String> subjects =
        sheet.rows[0].skip(1).map((e) => e?.value.toString() ?? '').toList();

    for (int i = 1; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];
      String rollNumber = row[0]?.value.toString() ?? '';

      if (rollNumber.isEmpty) continue;

      List<Map<String, dynamic>> marksList = [];
      for (int j = 1; j < row.length; j++) {
        marksList.add({
          'subject': subjects[j - 1],
          'marks': int.tryParse(row[j]?.value.toString() ?? '0') ?? 0
        });
      }

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('students')
          .where('rollNumber', isEqualTo: rollNumber)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var studentDoc = querySnapshot.docs.first;
          studentDoc.reference.collection('marks').doc('internal_exam').set({
            'teacherId': widget.teacherId,
            'timestamp': FieldValue.serverTimestamp(),
            'marks': marksList,
          }, SetOptions(merge: true));
        }
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks uploaded successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Test Marks"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Select Excel File'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _processExcel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Process and Upload Marks'),
                  ),
                  if (_selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                          "Selected File: ${_selectedFile!.path.split('/').last}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
